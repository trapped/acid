require 'acid/config'
require 'acid/worker'
require 'yaml'
require 'logger'

LOG ||= Logger.new($stdout)

module Acid
  def self.start(id, dir, out = $stdout, cfg = ['acid.yml'])
    file = ''
    cfg.each do |name|
      file = File.join dir, name
      if File.exist?(file)
        break
      end
    end
    if file.length == 0
      return -1
    end
    config = Acid::Config.new
    config.read(file)
    # Run setup commands
    if config.setup.length > 0
      setup_worker = Acid::Worker.new(id, config.env, config.shell)
      LOG.info("Acid##{id}") { "Executing setup for #{file}" }
      config.setup.each { |command|
        result = setup_worker.run command, out
        # Command returns failure code, stop
        if result > 0
          LOG.info("Acid##{id}") { "Command exited with #{result}, stopping" }
          return result
        end
      }
    end
    # Run exec commands
    if config.exec.length > 0
      exec_worker = Acid::Worker.new(id, config.env, config.shell)
      LOG.info("Acid##{id}") { "Executing exec for file #{file}" }
      config.exec.each { |command|
        result = exec_worker.run command, out
        # Command returns failure code, stop
        if result > 0
          LOG.info("Acid##{id}") { "Command exited with #{result}, stopping" }
          return result
        end
      }
    end
  end
end
