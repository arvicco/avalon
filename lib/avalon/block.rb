module Avalon

  # Block contains details about block found by the pool
  class Block

    extend Extractable

    attr_accessor :data

    # Field formats: name => [width, original name, type/conversion]
    FIELDS = {
      :height => [6, "height", :i],  # not in miner status string...
      :time => [19, "time", ->(t){ my_time(t, :absolute_date)}],
      :received => [8, "received_time", ->(t){ my_time(t)}],
      :reward => [6, "fee", ->(x){ (25 + x/100_000_000.0).round(3)}],
      :txns => [4, "n_tx", :i],
      :size => [3, "size", ->(x){ x/1024 }],
      :relayed_by => [13, "relayed_by", :s],
      :chain => [5, "main_chain", ->(x){ x ? 'main' : 'orphan' }],
      :conf => [4, "confirmations", :i],
      :hash => [56, "hash", ->(x){ x.sub(/^0*/,'')}],
    }

    def self.print_headers
      puts FIELDS.map {|name, (width,_,_ )| name.to_s.ljust(width)}.join(' ')
    end

    def initialize hash, ip
      # {"hash" : "0000000000000029714fcc1f7bcd43cd13286b665f759eb018cfc539841623a4",
      #    "version" : 2,
      #    "confirmations" : 0,
      #    "size" : 249181,
      #    "height" : 238605,
      #    "merkleroot" : "844f841c3fc276023a561503fc21d064bd898d6c9530d34a864efe70f67bfde8",
      #    "tx" : [..]
      #    "time" : 1369877473,
      #    "nonce" : 3370559418,
      #    "bits" : "1a016164",
      #    "difficulty" : 12153411.70977583,
      #    "previousblockhash" : "0000000000000004d388fd4e7bd6aa1c3f3eeae0ceadd7a0bc51ee1fee0be910"}
      bitcoind_info = Bitcoind.getblock hash, "| grep -v -E '^        .*,'"
      bitcoind_info.delete('tx')
      # pp bitcoind_info
      @data = self.class.extract_data_from( bitcoind_info )

      #{"hash"=>"00000000000000783be7e82df4d8a71bf1fd8073d2bbd60f2b8638e4d042d32c",
      #  "ver"=>2,
      #  "size"=>232091,
      #  "height"=>238557,
      #  "prev_block"=> "00000000000000b277cace9f2556fb8e0545038e83d20846cc4e3a3f61d0f2f2",
      #  "mrkl_root"=> "0a9a292c93ad732e55eeb25633d3e7580894faea908876f2d17589e127e904cd",
      #  "time"=>1369850827,
      #  "bits"=>436298084,
      #  "fee"=>41058500,
      #  "nonce"=>825834732,
      #  "n_tx"=>504,
      #  "block_index"=>386930,
      #  "main_chain"=>true,
      #  "received_time"=>1369850888,
      #  "relayed_by"=>"37.251.86.21"}
      blockchain_info = Blockchain.rawblock hash.rjust(64, '0')
      @data.merge! self.class.extract_data_from( blockchain_info )
    end

    def to_s
      FIELDS.map {|key, (width, _, _ )| @data[key].to_s.ljust(width)}.join(" ")
    end

  end
end
