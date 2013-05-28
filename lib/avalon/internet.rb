module Avalon

  # Internet is a node encapsulating information about Internet connectivity
  class Internet < Node

    def poll verbose=true
      self[:google] = ping 'www.google.com'
      self[:speedtest] = ping 'www.speedtest.net'
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
