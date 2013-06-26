module Avalon
  # Global Config
  class Config
    extend Utils # Helper methods

    DEFAULT_SOUNDS =       {
      restart: 'Frog.aiff',
      failure: 'Glass.aiff',
      perf_low: 'Glass.aiff',
      last_share: 'Glass.aiff',
      temp_high: 'Ping.aiff',
      temp_low: 'Ping.aiff',
      block_found: ['Dog.aiff', 'Purr.aiff', 'Dog.aiff'],
      block_updated: ['Purr.aiff', 'Purr.aiff', 'Purr.aiff']
    }

    def self.load env
      config_file = find_file( '../../../config/monitor.yml', '~/.avalon/monitor.yml')

      raise "No config file: ~/.avalon/monitor.yml" unless File.exist? config_file

      @config = YAML::load_file(config_file)[env]
      @config[:environment] = env
      @config[:block_file] =  find_file( '../../../config/blocks.yml', '~/.avalon/blocks.yml') ||
        File.expand_path('~/.avalon/blocks.yml')

      # Setting defaults
      @config[:alert_sounds] = DEFAULT_SOUNDS.merge(@config[:alert_sounds] || {})
      @config[:alert_last_share] ||= 2
      @config[:alert_after] ||= @config[:status_fails_to_alarm] || 2
      @config[:alert_temp_high] ||= @config[:alert_temp] || 55
      @config[:alert_temp_low] ||= 30
    end

    def self.config
      @config
    end

    def self.[] key
      @config[key]
    end

  end
end
