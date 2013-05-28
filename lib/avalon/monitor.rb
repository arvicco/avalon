require "avalon/miner"

module Avalon
  class Monitor

    def initialize miners, verbose=true
      @miners = miners
      @verbose = verbose
    end

    def run
      loop do

        Avalon::Miner.print_headers if @verbose

        # Update miner status
        @miners.each {|miner| miner.check_status(@verbose)}

        # Report miner errors (if any)
        @miners.each {|miner| miner.report_errors}

        sleep 20

      end
    end

  end
end
