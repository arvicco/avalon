module Avalon
  # Pool is a node encapsulating pool software
  class Eloipool < Node

    def initialize ip, frequency
      @ip = ip
      @update_frequency = frequency
      @update_num = 0
      @block_file = Avalon::Config[:block_file]
      @blocks = load_blocks || {}
      super()
    end

    def poll verbose=true
      self[:ping] = ping @ip

      self[:found] = `ssh #{@ip} "cat solo/logs/pool.log | grep BLKHASH | wc -l"`.to_i

      update_old_block

      puts "#{self}" if verbose
    end

    # Check for any exceptional situations, sound alarm if any
    def report
      if self[:ping].nil?
        alarm "Eloipool at #{@ip} not responding to ping"
      elsif self[:found] > @blocks.size
        add_new_blocks `ssh #{@ip} "cat solo/logs/pool.log | grep BLKHASH"`
        alarm "Eloipool found #{@found} blocks", "Dog.aiff", "Purr.aiff", "Dog.aiff"
      elsif @blocks[@blocks.keys.last].pending?
        update_block @blocks[@blocks.keys.last] do
          alarm "Eloipool last block updated", "Purr.aiff", "Purr.aiff", "Purr.aiff"
        end
      end
    end

    def save_blocks
      dump = @blocks.values.map(&:data)
      File.open(@block_file, "w") {|file| YAML.dump(dump, file)}
    end

    def load_blocks print = true
      if File.exist?(@block_file)
        Block.print_headers
        dump = YAML::load_file(@block_file)
        Hash[
          *dump.map do |data|
            block = Block.new data
            puts block
            [data[:hash], block]
          end.flatten
        ]
      end
    end

    def update_old_block
      if rand(@update_frequency) == 0 # update once per @frequency polls
        hash = @blocks.keys[@update_num]
        if @blocks[hash]
          @update_num += 1
          update_block(@blocks[hash], true)
        else
          @update_num = 0
        end
      end
    end

    def update_block block, print = true
      if (block.pending? ? block.blockchain_update : block.bitcoind_update )
        if print
          Block.print_headers
          puts block
        end
        save_blocks
        yield block if block_given?
      end
    end

    # Add new blocks from pool log
    def add_new_blocks pool_log, print = true
      Block.print_headers if print
      pool_log.split(/\n/).each do |line|
        hash = line.chomp.match(/\h*$/).to_s
        unless @blocks[hash]
          @blocks[hash] = Block.new(hash)
          puts @blocks[hash] if print
          @pending_hash = hash
        end
      end
      save_blocks
    end

    def to_s
      "Eloipool: " + @data.map {|name, value| "#{name}:#{value}"}.join(" ")
    end

    def inspect
      @data.map {|name, value| "#{name}:#{value}"}.join(" ")
    end

  end
end
