module Avalon

  class Monitor

    # List of nodes to monitor
    def initialize nodes, verbose=true
      @nodes = nodes
      @verbose = verbose
    end

    def run
      loop do

        Avalon::Miner.print_headers if @verbose

        # Check status for all nodes
        @nodes.each {|node| node.check_status(@verbose)}

        # Report node errors (if any)
        @nodes.each {|node| node.report_errors}

        sleep 20

      end
    end

  end
end
