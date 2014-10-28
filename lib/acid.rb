require 'yaml'

module Acid
  require 'acid/config'
  require 'acid/executor'

  def self.start(dir)
    config = Acid::Config.new
    config.read(File.join(dir, 'acid.yml'))

    puts "Shell: #{config.shell}" if config.shell != nil
    (printf "Setup:\n\t";        puts config.setup .join("\n\t")) if config.setup != nil
    (printf "Environment:\n\t";  puts config.env   .join("\n\t")) if config.env   != nil
    (printf "Build:\n\t";        puts config.exec  .join("\n\t")) if config.exec  != nil
  end
end
