module Avalon

  class Monitor

    # List of nodes to monitor
    def initialize nodes, timeout, verbose=true
      @nodes = nodes
      @timeout = timeout
      @verbose = verbose
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
