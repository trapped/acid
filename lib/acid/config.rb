require 'yaml'

module Acid::Config
  # Shell executable name for running commands (needs to be in PATH)
  def self.shell
    @shell ||= 'bash'
  end

  # Commands to execute before building
  def self.setup
    @setup ||= nil
  end

  # Environmental variables to set before building
  def self.env
    @env ||= nil
  end

  # Commands to execute to build
  def self.exec
    @exec ||= nil
  end

  # Parses the acid.yml file in the current directory
  def self.read(path)
    (YAML.load_file path).each { |name, val| instance_variable_set("@#{name}", val) }
  end
end