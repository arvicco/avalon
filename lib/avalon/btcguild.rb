require 'faraday'
require 'json'

module Avalon

  # Extracts Btcguild pool info
  class Btcguild < Node

    API_URL = 'http://www.btcguild.com'
    API_PATH = 'api.php?api_key='

    def initialize monitor, ping_url, api_key
      @ping_url, @api_key = ping_url, api_key

      @conn ||= Faraday.new(:url => API_URL) do |faraday|
        # faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      super()
    end

    def get
      reply = @conn.get "#{API_PATH}#{@api_key}"
      if reply.success? && !(reply.body =~ /too many API requests/)
        JSON.parse(reply.body, :symbolize_names => true)
      else
        {}
      end
    end

    def poll verbose=true
      @data[:ping] = ping @ping_url

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
      "BTC Guild: #{pool_speed}TH/s ping:#{self[:ping]} diff:#{diff}M " +
        "unpaid(24h) btc: #{unpaid}(#{past24}) nmc: #{unpaid_nmc}(#{past24_nmc})"
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
      access :user, :past_24h_rewards, 2
    end

    def unpaid
      access :user, :unpaid_rewards, 3
    end

    def past24_nmc
      access :user, :past_24h_rewards_nmc, 1
    end

    def unpaid_nmc
      access :user, :unpaid_rewards_nmc, 2
    end

    def pool_speed
      access :pool, :pool_speed, 1, 1000.0
    end

    def diff
      access :pool, :difficulty, 1, 1000_000.0
    end

  end
end
