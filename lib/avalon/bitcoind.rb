require 'json'

module Avalon

  # Block contains details about block found by the pool
  class Bitcoind

    # Class methods
    class << self

      def method_missing *args
        rpc = "bitcoind -rpcuser=#{config[:rpcuser]} -rpcpassword=#{config[:rpcpassword]}"
        result = `ssh #{config[:ip]} "#{rpc} #{args.join(' ')}"`
        JSON.parse(result) unless result.empty?
      end

      def config
        Avalon::Config[:bitcoind] || {}
      end
    end
  end
end
