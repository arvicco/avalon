module Avalon
  # Global Config
  class Config
    extend Utils # Helper methods

    def self.load env
      config_file = find_file( '../../../config/monitor.yml', '~/.avalon/monitor.yml')

      raise "No config file: ~/.avalon/monitor.yml" unless File.exist? config_file

      @config = YAML::load_file(config_file)[env]
      @config[:environment] = env
      @config[:block_file] =  find_file( '../../../config/blocks.yml', '~/.avalon/blocks.yml') ||
        File.expand_path('~/.avalon/blocks.yml')

      @config[:alert_sounds] ||= {
        failure: 'Glass.aiff',
        restart: 'Frog.aiff',
        temp_high: 'Ping.aiff',
        block_found: ['Dog.aiff', 'Purr.aiff', 'Dog.aiff'],
        block_updated: ['Purr.aiff', 'Purr.aiff', 'Purr.aiff']
      }
    end

    def self.[] key
      @config[key]
    end

  end
end
