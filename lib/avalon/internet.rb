module Avalon

  # Internet is a node encapsulating information about Internet connectivity
  class Internet < Node

    IP_REGEXP = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/

    def initialize monitor, *sites
      sites.map! do |site|
        name = site =~ IP_REGEXP ? site : site.split(/\./)[-2]
        [name.to_sym, site]
      end
      @sites = Hash[ *sites.flatten ]
      super()
    end

    def poll verbose=true
      @sites.each {|name, site| self[name] = ping site }
      puts "#{self}" if verbose
    end

    # Check for any exceptional situations with Node, sound alarm if any
    def report
      @data.each do |target, ping|
        alarm "Ping #{target} failed, check your Internet connection" unless ping
      end
    end

    def to_s
      "Internet: " + @data.map {|name, value| "#{name}:#{value}"}.join(" ")
    end

  end
end
