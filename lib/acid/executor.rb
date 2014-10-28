require 'open3'
require 'colorize'

class Acid::Executor
  # Executes a single command
  def run(env=[], shell, command)
    puts "Running #{command}..."
    # Capture stdout and stderr separately http://ruby-doc.org/stdlib-2.1.4/libdoc/open3/rdoc/Open3.html#method-c-popen3
    Open3.popen3(env, shell, command) { |stdin, stdout, stderr, wait_thr|
      puts "Started using #{shell}, PID is #{wait_thr.pid}"
      stdin.close # We don't need it and the process might wait for it to close if it needs input
      # Loop while the child process is alive (nonblocking) http://stackoverflow.com/a/14381862/2386865
      while Process.waitpid(wait_thr.pid, Process::WNOHANG) == nil
        readable = IO.select([stdout, stderr])[0]
        readable.each do |stream|
          if stream == stderr
            # Print errors in red
            print stderr.read.colorize(:red)
          else
            print stream.read
          end
        end
      end
      puts "Exited with code #{wait_thr.value}"
    }
  end
end
