require 'yaml'

module Acid
  require 'acid/config'
  require 'acid/executor'

  def self.start(dir)
    config = Acid::Config.new
    config.read(File.join(dir, 'acid.yml'))

    puts "Shell: #{config.shell}" if config.shell != nil
    (printf "Setup:\n\t"; puts config.setup .join("\n\t")) if config.setup != nil
    (puts "Environment:"; config.env.each { |key, value| puts "\t#{key}: #{value}" }) if config.env != nil
    (printf "Build:\n\t"; puts config.exec  .join("\n\t")) if config.exec != nil

    if config.setup.length > 0
      setup_executor = Acid::Executor.new(config.env, config.shell)
      puts "\nExecuting Setup:\n"
      config.setup.each { |command|
        setup_executor.run command
        puts
      }
    end
  end
end
