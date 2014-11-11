require 'yaml'
require 'logger'

module Acid
  LOG = Logger.new($stdout)

  require 'acid/config'
  require 'acid/executor'

  def self.start(dir)
    file = File.join(dir, 'acid.yml')
    config = Acid::Config.new
    config.read(file)

    # Run setup commands
    if config.setup.length > 0
      setup_executor = Acid::Executor.new(config.env, config.shell)
      LOG.log(Logger::INFO, "Executing setup for #{file}", 'Acid') if LOG
      config.setup.each { |command|
        result = setup_executor.run command, $stdout
        # Command returns failure code, stop
        if result > 0
          LOG.log(Logger::INFO, "Command exited with #{result}, stopping", 'Acid') if LOG
          exit 1
        end
      }
    end
    # Run exec commands
    if config.exec.length > 0
      exec_executor = Acid::Executor.new(config.env, config.shell)
      LOG.log(Logger::INFO, "Executing exec for file #{file}", 'Acid') if LOG
      config.exec.each { |command|
        result = exec_executor.run command, $stdout
        # Command returns failure code, stop
        if result > 0
          LOG.log(Logger::INFO, "Command exited with #{result}, stopping", 'Acid') if LOG
          exit 1
        end
      }
    end
  end
end
