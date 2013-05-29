module Avalon

  class Monitor

    # List of nodes to monitor
    def initialize opts
      @nodes = opts[:nodes].map {|args| Avalon::Node.create(*args)}
      @timeout = opts[:timeout] || 30
      @verbose = opts[:verbose]
    end

    def run
      loop do

        Avalon::Miner.print_headers if @verbose

        # Check status for all nodes
        @nodes.each {|node| node.poll(@verbose)}

        # Report node errors (if any)
        @nodes.each {|node| node.report}

        sleep @timeout

      end
    end

  end
end
