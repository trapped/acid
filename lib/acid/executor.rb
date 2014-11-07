require 'open3'
require 'colorize'

class Acid::Executor
  # Creates a new Acid::Executor with the provided environment and shell
  def initialize(env=[], shell)
    @env = env
    @shell = shell
  end

  # Creates a thread that pipes streams until killed
  def capture(stream_from, stream_to, &filter)
    return Thread.new {
      while true # TODO: Using waitpid to check if the thread is alive kills it, but just looping like this is dangerous
        r = stream_from.read
        if filter
          r = filter.call(r)
        end
        stream_to.write r
      end
    }
  end

  # Executes a single command
  def run(command)
    puts "Running '#{command}'...".yellow
    # Capture stdout and stderr separately http://ruby-doc.org/stdlib-2.1.4/libdoc/open3/rdoc/Open3.html#method-c-popen3
    Open3.popen3(@env, [@shell, command].join(' ')) { |stdin, stdout, stderr, wait_thr|
      puts "Started using #{@shell.split(' ')[0]}, PID is #{wait_thr.pid}".green; puts
      stdin.close # We don't need it and the process might wait for it to close if it needs input
      # Loop while the child process is alive (nonblocking) http://stackoverflow.com/a/14381862/2386865
      begin
        # Print stdout and stderr to console
        thr_out = self.capture(stdout, $stdout)
        thr_err = self.capture(stderr, $stdout) { |text| text.red }
        wait_thr.join
        thr_out.kill; thr_err.kill
      rescue Errno::ECHILD, Errno::EINVAL
        # Process exited
      end
      val = wait_thr.value
      if val != nil
        puts; puts "Exited with code #{val.exitstatus}".green; puts
        return val.exitstatus
      else
        puts; puts "Process vanished, exit code unavailable".yellow; puts
        return -1
      end
    }
  end
end
