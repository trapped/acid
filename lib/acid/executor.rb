module Acid
  module Executor
    extend self
    def run(command)
      puts "Running #{command}..."
    end
  end
end
