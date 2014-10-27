require 'yaml'
require 'acid/config'
require 'acid/executor'

module Acid
  def self.start(dir)
    Acid::Config.read(File.join(dir, 'acid.yml'))
    printf "Setup:\n\t"; puts Acid::Config.setup.join("\n\t")
    printf "Environment:\n\t"; puts Acid::Config.env.join("\n")
    printf "Build:\n\t"; puts Acid::Config.exec.join("\n")
  end
end