require 'faraday'
require 'json'

module Avalon

  # Extracts Btcguild pool info
  class Btcguild < Node

    def initialize mining_url, api_url, api_path, api_key
      @mining_url, @api_url, @api_path, @api_key = mining_url, api_url, api_path, api_key

      @conn ||= Faraday.new(:url => @api_url) do |faraday|
        # faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      super()
    end

    def get
      reply = @conn.get "#{@api_path}#{@api_key}"
      if reply.success? && !(reply.body =~ /too many API requests/)
        JSON.parse(reply.body, :symbolize_names => true)
      else
        {}
      end
    end

    def poll verbose=true
      @data[:ping] = ping @mining_url

      if @data[:ping]
        @data.merge!(get || {})
        if @data[:workers] && @data[:workers].keys.include?(:'1')
          @data[:workers] = Hash[*@data[:workers].map {|_, h| [h.delete(:worker_name), h]}.flatten]
        end
      end
      puts "#{self}" if verbose
    end

    # Check for any exceptional situations, sound alarm if any
    def report
      if self[:ping].nil?
        alarm "BTC Guild not responding to ping"
      else
      end
    end

    def to_s
      "BTC Guild: #{pool_hash}TH/s ping:#{self[:ping]} diff:#{diff}M " +
        "24h(unpaid) btc: #{past24}(#{unpaid}) nmc: #{past24_nmc}(#{unpaid_nmc})"
        end

    ### Convenience data accessors
    def access key1, key2, precision=nil, divider=1
      if @data[key1] && @data[key1][key2]
        if precision
          (@data[key1][key2]/divider).round(precision)
        else
          (@data[key1][key2]/divider)
        end
      end
    end

    def past24
      access :user, :past_24h_rewards, 3
    end

    def unpaid
      access :user, :unpaid_rewards, 4
    end

    def past24_nmc
      access :user, :past_24h_rewards_nmc, 1
    end

    def unpaid_nmc
      access :user, :unpaid_rewards_nmc, 2
    end

    def pool_hash
      access :pool, :pool_speed, 1, 1000.0
    end

    def diff
      access :pool, :difficulty, 1, 1000_000.0
    end

  end
end
