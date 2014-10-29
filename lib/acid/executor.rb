require 'open3'
require 'colorize'

class Acid::Executor
  # Creates a new Acid::Executor with the provided environment and shell
  def initialize(env=[], shell)
    @env = env
    @shell = shell
  end
  # Executes a single command
  def run(command)
    puts "Running '#{command}'..."
    # Capture stdout and stderr separately http://ruby-doc.org/stdlib-2.1.4/libdoc/open3/rdoc/Open3.html#method-c-popen3
    Open3.popen3(@env, [@shell, command].join(' ')) { |stdin, stdout, stderr, wait_thr|
      puts "Started using #{@shell.split(' ')[0]}, PID is #{wait_thr.pid}"
      stdin.close # We don't need it and the process might wait for it to close if it needs input
      # Loop while the child process is alive (nonblocking) http://stackoverflow.com/a/14381862/2386865
      begin
        while Process.waitpid(wait_thr.pid, Process::WNOHANG) == nil
          readable = IO.select([stdout, stderr])[0]
          readable.each do |stream|
            if stream == stderr
              # Print errors in red
              print stderr.read.to_s.red
            else
              print stream.read
            end
          end
        end
      rescue Errno::ECHILD, Errno::EINVAL
        # Process exited
      end
      val = wait_thr.value
      if val != nil
        puts "Exited with code #{val.exitstatus}"
      else
        # TODO: Why is the Process::Status returned by wait_thr.value nil? Maybe the process terminated too quickly?
        puts "Process vanished, exit code unavailable"
      end
    }
  end
end
