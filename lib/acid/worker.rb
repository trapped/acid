require 'open3'
require 'colorize'
require 'logger'
require 'thread'
require 'pry'

module Acid
  class Worker
    # Creates a new Acid::Worker with the provided environment and shell
    def initialize(id, env = {}, shell)
      @id = id
      @env = env
      @shell = shell
    end

    # Creates a thread that pipes streams until killed
    def capture(stream_from, stream_to, lock, &filter)
      LOG.info("Acid::Worker##{@id}") { "Starting capture thread (#{stream_from.inspect}->#{stream_to.inspect})" }
      Thread.new {
        lock.synchronize {
          begin
            while !stream_from.eof? # TODO: Using waitpid to check if the thread is alive might kill it, but just looping is dangerous
              r = stream_from.read
              if filter # yield() syntax is less expensive performance-wise
                r = filter.call(r)
              end
              stream_to.write r
            end
          rescue IOError => e
            LOG.error("Acid::Worker##{@id}") { "IO Error while reading from stream (#{e.message})" }
            exit # Kill the thread
          end
        }
      }
    end

    # Executes a single command
    def run(command, output = $stdout, dir = Dir.pwd, prompt = nil)
      LOG.info("Acid::Worker##{@id}") { "Running '#{command}' in '#{dir}'..." }
      output.sync = true
      if ENV['PRY']
        binding.pry
      end
      # Capture stdout and stderr separately http://ruby-doc.org/stdlib-2.1.4/libdoc/open3/rdoc/Open3.html#method-c-popen3
      Open3.popen3(@env, [@shell, '"' + command.gsub("'", %q(\\\')).gsub('"', %q(\\\")) + '"'].join(' '), chdir: dir) { |stdin, stdout, stderr, wait_thr|
        LOG.info("Acid::Worker##{@id}") { "Using #{@shell.split(' ')[0]}, PID is #{wait_thr.pid}" }
        stdin.close # We don't need it and the process might wait for it to close if it needs input
        if prompt
          # Print prompt
          output.puts prompt.to_s + command
        end
        # Loop while the child process is alive (nonblocking) http://stackoverflow.com/a/14381862/2386865
        begin
          locks = { stdout_lock: Mutex.new, stderr_lock: Mutex.new }
          # Print stdout and stderr to console
          thr_out = self.capture(stdout, output, locks[:stdout_lock])
          thr_err = self.capture(stderr, output, locks[:stderr_lock]) { |text| text.red }
          wait_thr.join
          # Prevent thread death race
          locks.values.each do |lock|
                lock.synchronize {}
          end
          sleep(0.001)
        rescue Errno::ECHILD, Errno::EINVAL
          # Process exited
        end
        val = wait_thr.value
        if val != nil
          LOG.info("Acid::Worker##{@id}") { "Exited with code #{val.exitstatus}" }
          return val.exitstatus
        else
          LOG.error("Acid::Worker##{@id}") { 'Process vanished, exit code unavailable' }
          return -1
        end
      }
    end
  end
end
