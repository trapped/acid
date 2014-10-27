require 'yaml'

module Acid
  module Config
    extend self
    # Shell executable name for running commands (needs to be in PATH)
    def shell
      @shell ||= 'bash'
    end

    # Commands to execute before building
    def setup
      @setup ||= nil
    end

    # Environmental variables to set before building
    def env
      @env ||= nil
    end

    # Commands to execute to build
    def exec
      @exec ||= nil
    end

    # Parses the acid.yml file in the current directory
    def read(path)
      (YAML.load_file path).each { |name, val| instance_variable_set("@#{name}", val) }
    end
  end
end