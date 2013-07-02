module Avalon

  class Monitor

    attr_reader :nodes, :switches, :pool

    # List of nodes to monitor
    def initialize opts
      @timeout = opts[:timeout] || 30
      @verbose = opts[:verbose]
      @switches = (opts[:switches] || []).map {|args| Avalon::Switch.new(*args)}
      @nodes = opts[:nodes].map {|args| Avalon::Node.create(self, *args)}
      @pool = @nodes.find {|node| node.is_a?(Avalon::Btcguild)}
    end

    def run
      loop do

        # Check status for all nodes
        @nodes.inject(false) do |headers_printed, node|
          # Print miners headers once first miner encountered
          if @verbose && node.is_a?(Avalon::Miner) && !headers_printed
            Avalon::Miner.print_headers
            headers_printed = true
          end
          node.poll(@verbose)
          headers_printed
        end

        # Report node errors (if any)
        @nodes.each {|node| node.report}

        if @verbose
          unit_hash = @nodes.reduce(0) {|hash, node| hash + (node.unit_hash || 0)}
          pool_hash = @nodes.reduce(0) {|hash, node| hash + (node.pool_hash || 0)}
          puts "Total hash rate (from pool): #{unit_hash} (#{pool_hash}) MH/s"
        end

        sleep @timeout

      end
    end

  end
end
