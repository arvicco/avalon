module Avalon
  # Pool is a node encapsulating pool software
  class Eloipool < Node

    def initialize ip
      @ip = ip
      @found = 0
      super()
    end

    def poll verbose=true
      self[:ping] = `ping -c 1 #{@ip}` =~ / 0.0% packet loss/

      self[:found] = `ssh #{@ip} "cat solo/logs/pool.log | grep accepted | wc -l"`.to_i

      puts "#{self}" if verbose
    end

    # Check for any exceptional situations, sound alarm if any
    def report
      if self[:ping].nil?
        alarm "Eloipool at #{@ip} not responding to ping"
      elsif self[:found] > @found
        @found = self[:found]
        puts `ssh #{@ip} "cat solo/logs/pool.log | grep accepted"`
        alarm "Eloipool found #{@found} blocks", "Purr.aiff", 3
      end
    end

    def to_s
      "Eloipool #{@ip}: " + @data.map {|name, value| "#{name}:#{value}"}.join(" ")
    end

    def inspect
      @data.map {|name, value| "#{name}:#{value}"}.join(" ")
    end

  end
end
