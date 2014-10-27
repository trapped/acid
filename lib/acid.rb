require 'yaml'

module Acid
  require 'acid/config'
  require 'acid/executor'

  def self.start(dir)
    config = Acid::Config.new
    config.read(File.join(dir, 'acid.yml'))
    
    printf "Setup:\n\t"; puts config.setup.join("\n\t")
    printf "Environment:\n\t"; puts config.env.join("\n")
    printf "Build:\n\t"; puts config.exec.join("\n")
  end
end