require 'acid/config'
require 'acid/worker'
require 'yaml'
require 'logger'

LOG ||= Logger.new($stdout)

module Acid
  def self.start(id, dir, out = $stdout, cfg = ['acid.yml'])
    file = ''
    cfg.each do |name|
      if File.exist? File.join(dir, name)
        file = File.join dir, name
        break
      end
    end
    if !file || file.empty?
      return 999
    end
    config = Acid::Config.new
    if !config.read(file)
      return 999
    end
    # Run setup commands
    if config.setup && config.setup.length > 0
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
    if config.exec && config.exec.length > 0
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
