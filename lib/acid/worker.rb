require 'open3'
require 'colorize'
require 'logger'

class Acid::Worker
  # Creates a new Acid::Worker with the provided environment and shell
  def initialize(id, env=[], shell)
    @id = id
    @env = env
    @shell = shell
  end

  # Creates a thread that pipes streams until killed
  def capture(stream_from, stream_to, &filter)
    LOG.info('Acid::Worker#'+@id) { 'Starting capture thread' }
    Thread.new {
      while true # TODO: Using waitpid to check if the thread is alive kills it, but just looping like this is dangerous
        r = stream_from.read
        if filter # yield() syntax is less expensive performance-wise
          r = filter.call(r)
        end
        stream_to.write r
      end
    }
  end

  # Executes a single command
  def run(command, output = $stdout)
    LOG.info('Acid::Worker#'+@id) { "Running '#{command}'..." }
    # Capture stdout and stderr separately http://ruby-doc.org/stdlib-2.1.4/libdoc/open3/rdoc/Open3.html#method-c-popen3
    Open3.popen3(@env, [@shell, '"' + command.gsub("'", %q(\\\')).gsub('"', %q(\\\")) + '"'].join(' ')) { |stdin, stdout, stderr, wait_thr|
      LOG.info('Acid::Worker#'+@id) { "Using #{@shell.split(' ')[0]}, PID is #{wait_thr.pid}" }
      stdin.close # We don't need it and the process might wait for it to close if it needs input
      # Loop while the child process is alive (nonblocking) http://stackoverflow.com/a/14381862/2386865
      begin
        # Print stdout and stderr to console
        thr_out = self.capture(stdout, output)
        thr_err = self.capture(stderr, output) { |text| text.red }
        wait_thr.join
        thr_out.kill; thr_err.kill
      rescue Errno::ECHILD, Errno::EINVAL
        # Process exited
      end
      val = wait_thr.value
      if val != nil
        LOG.info('Acid::Worker#'+@id) { "Exited with code #{val.exitstatus}" }
        return val.exitstatus
      else
        LOG.error('Acid::Worker#'+@id) { 'Process vanished, exit code unavailable' }
        return -1
      end
    }
  end
end
