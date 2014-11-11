require 'open3'
require 'colorize'
require 'logger'

class Acid::Executor
  # Creates a new Acid::Executor with the provided environment and shell
  def initialize(env=[], shell)
    @env = env
    @shell = shell
  end

  # Creates a thread that pipes streams until killed
  def capture(stream_from, stream_to, &filter)
    Acid::LOG.log(Logger::DEBUG, 'Starting capture thread', 'Acid::Executor') if Acid::LOG
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
  def run(command, output)
    Acid::LOG.log(Logger::DEBUG, "Running '#{command}'...", 'Acid::Executor') if Acid::LOG
    # Capture stdout and stderr separately http://ruby-doc.org/stdlib-2.1.4/libdoc/open3/rdoc/Open3.html#method-c-popen3
    Open3.popen3(@env, [@shell, '"' + command.gsub("'", %q(\\\')).gsub('"', %q(\\\")) + '"'].join(' ')) { |stdin, stdout, stderr, wait_thr|
      Acid::LOG.log(Logger::DEBUG, "Using #{@shell.split(' ')[0]}, PID is #{wait_thr.pid}", 'Acid::Executor') if Acid::LOG
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
        Acid::LOG.log(Logger::DEBUG, "Exited with code #{val.exitstatus}", 'Acid::Executor') if Acid::LOG
        return val.exitstatus
      else
        Acid::LOG.log(Logger::ERROR, 'Process vanished, exit code unavailable', 'Acid::Executor') if Acid::LOG
        return -1
      end
    }
  end
end
