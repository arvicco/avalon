require 'faraday'
require 'json'

module Avalon

  # Block contains details about block found by the pool
  class Blockchain

    # Class methods
    class << self

      # Establish Faraday connection on first call
      def conn
        @conn ||= Faraday.new(:url => 'http://blockchain.info') do |faraday|
          # faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
      end

      def rawblock block_hash
        get "rawblock/#{block_hash}"
      end

      def get path
        reply = conn.get "#{path}?format=json"
        JSON.parse(reply.body) if reply.success?
      end
    end
  end
end
