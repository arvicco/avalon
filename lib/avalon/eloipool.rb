module Avalon
  # Pool is a node encapsulating pool software
  class Eloipool < Node

    def initialize ip
      @ip = ip
      @found = 0
      @blocks = {}
      super()
    end

    def poll verbose=true
      self[:ping] = ping @ip

      self[:found] = `ssh #{@ip} "cat solo/logs/pool.log | grep BLKHASH | wc -l"`.to_i

      puts "#{self}" if verbose
    end

    # Check for any exceptional situations, sound alarm if any
    def report
      if self[:ping].nil?
        alarm "Eloipool at #{@ip} not responding to ping"
      elsif self[:found] > @found
        @found = self[:found]
        add_new_blocks `ssh #{@ip} "cat solo/logs/pool.log | grep BLKHASH"`
        alarm "Eloipool found #{@found} blocks", "Dog.aiff", "Purr.aiff", "Dog.aiff"
      end
    end

    # Add new blocks from pool log
    def add_new_blocks pool_log
      Block.print_headers
      pool_log.split(/\n/).drop(17).each do |line|
        hash = line.chomp.match(/\h*$/).to_s
        unless @blocks[hash]
          @blocks[hash] = Block.new(hash, @ip)
          puts @blocks[hash]
        end
      end
    end

    def to_s
      "Eloipool: " + @data.map {|name, value| "#{name}:#{value}"}.join(" ")
    end

    def inspect
      @data.map {|name, value| "#{name}:#{value}"}.join(" ")
    end

  end
end
