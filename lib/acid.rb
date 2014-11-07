require 'yaml'

module Acid
  require 'acid/config'
  require 'acid/executor'

  def self.start(dir)
    config = Acid::Config.new
    config.read(File.join(dir, 'acid.yml'))

    puts "Shell: #{config.shell}" if config.shell != nil
    (printf "Setup:\n\t"; puts config.setup .join("\n\t")) if config.setup != nil
    (puts 'Environment:'; config.env.each { |key, value| puts "\t#{key}: #{value}" }) if config.env != nil
    (printf "Build:\n\t"; puts config.exec  .join("\n\t")) if config.exec != nil
    # Run setup commands
    if config.setup.length > 0
      setup_executor = Acid::Executor.new(config.env, config.shell)
      puts "\nExecuting Setup:\n".blue.bold
      config.setup.each { |command|
        result = setup_executor.run command
        # Command returns failure code, stop
        if result > 0
          puts "\nCommand exited with #{result}, stopping".red
          exit 1
        end
      }
    end
    # Run exec commands
    if config.exec.length > 0
      exec_executor = Acid::Executor.new(config.env, config.shell)
      puts "\nExecuting Exec:\n".blue.bold
      config.exec.each { |command|
        result = exec_executor.run command
        # Command returns failure code, stop
        if result > 0
          puts "\nCommand exited with #{result}, stopping".red
          exit 1
        end
      }
    end
  end
end
