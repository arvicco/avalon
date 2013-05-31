module Avalon
  # Global Config
  class Config

    def self.load env
      config_file = File.expand_path('../../../config/monitor.yml', __FILE__)
      raise "No config file: #{config_file}" unless File.exist? config_file

      @config = YAML::load_file(config_file)[env]
    end

    def self.[] key
      @config[key]
    end

  end
end
