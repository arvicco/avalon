module Avalon

  class Monitor

    attr_reader :nodes, :switches

    # List of nodes to monitor
    def initialize opts
      @timeout = opts[:timeout] || 30
      @verbose = opts[:verbose]
      @switches = (opts[:switches] || []).map {|args| Avalon::Switch.new(*args)}
      @nodes = opts[:nodes].map {|args| Avalon::Node.create(*args)}
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
          total_hash = @nodes.reduce(0) {|hash, node| hash + (node[:mhs] || 0)}
          puts "Total hash rate: #{total_hash} MHash/sec"
        end

        sleep @timeout

      end
    end

  end
end
