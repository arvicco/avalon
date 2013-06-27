# encoding: utf-8

module Avalon
  # "STATUS=S,When=1368715953,Code=11,Msg=Summary,Description=cgminer 2.10.5|
  #  SUMMARY,Elapsed=58219,MHS av=70827.84,Found Blocks=0,Getworks=1899,Accepted=14755,
  #  Rejected=162,Hardware Errors=2352,Utility=15.21,Discarded=3529,Stale=0,Get Failures=0,
  #  Local Work=1068039,Remote Failures=0,Network Blocks=107,Total MH=4123494727.5140,
  #  Work Utility=992.58,Difficulty Accepted=944320.00000000,Difficulty Rejected=10368.00000000,
  #  Difficulty Stale=0.00000000,Best Share=7493180|\u0000"

  # Miner is a node encapsulating a single Avalon unit
  class Miner < Node

    extend Extractable

    # Field formats: name => [width, pattern, type/conversion]
    FIELDS = {
      :ping => [8, /./, nil],  # not in miner status string...
      :mhs => [6, /(?<=MHS av=)[\d\.]*/, :i],
      :uptime => [9, /(?<=Elapsed=)[\d\.]*/, ->(x){ my_time(x, :relative_time)}],
      :last => [8, /(?<=Status=Alive,).*?Last Share Time=[\d\.]*/,
                ->(x){ convert_last(x)}],
      :miner => [5, /(?<=Description=cgminer )[\d\.]*/, :s],
      :freq => [4, /(?<=frequency=)[\d\.]*/, :i],
      :'°C' => [2, /(?<=Temperature=)[\d\.]*/, :i],
      :fan2 => [4, /(?<=fan2=)[\d\.]*/, :i],
      :fan3 => [4, /(?<=fan3=)[\d\.]*/, :i],
      :wu => [4, /(?<=,Work Utility=)[\d\.]*/, :i],
      :getworks => [8, /(?<=Getworks=)[\d\.]*/, :i],
      :accepted => [8, /(?<=,Accepted=)[\d\.]*/, :i],
      :rejected => [8, /(?<=Rejected=)[\d\.]*/, :i],
      :stale => [6, /(?<=Stale=)[\d\.]*/, :i],
      :errors => [6, /(?<=Hardware Errors=)[\d\.]*/, :i],
      :blocks => [6, /(?<=Network Blocks=)[\d\.]*/, :i],
      #      :found => [2, /(?<=Found Blocks=)[\d\.]*/, :i],
    }

    # Last share converter (Miner-specific)
    def self.convert_last x
      y = x[/(?<=Last Share Time=)[\d\.]*/]

      if y.nil? || y == '0'
        "never"
      else
        my_time(Time.now.getgm.to_i-y.to_i, :relative_time)
      end
    end

    def self.print_headers
      puts "\nMiner status as of #{Time.now.getlocal.asctime}:\n#    " +
        FIELDS.map {|name, (width,_,_ )| name.to_s.ljust(width)}.join(' ')
    end

    def initialize ip, min_speed, config=Avalon::Config.config
      @ip = ip
      @min_speed = min_speed * 1000 # Gh/s to Mh/s
      @config = config
      @fails = 0
      super()
    end

    def get_api call
      self[:ping] ? `bash -ic "echo -n '#{call}' | nc #{@ip} 4028"` : ""
    end

    def poll verbose=true
      self[:ping] = ping @ip

      status = get_api('summary') + get_api('pools') + get_api('devs') + get_api('stats')
      # p get_api('summary')
      # pools = get_api('pools')
      # p pools[FIELDS[:last][1]]
      # devs = get_api('devs')
      # p devs

      data = self.class.extract_data_from(status)

      if data.empty?
        @data = {}
      else
        @data.merge! data
      end

      puts "#{self}" if verbose
    end

    def upminutes
      duration(self[:uptime])
    end

    def temp
      self[:'°C']
    end

    def last
      duration(self[:last])
    end

    # Check for any exceptional situations in stats, sound alarm if any
    def report
      if data[:ping].nil?
        @fails += 1
        if @fails >= @config[:alert_after]
          alarm "Miner #{num} did not respond to status query", :failure
        end
      else
        @fails = 0
        if duration(self[:uptime]) < 2
          alarm "Miner #{num} restarted", :restart
        elsif duration(self[:uptime]) > 5 # Miner settled down
          if self[:mhs] < @min_speed
            alarm "Miner #{num} performance is #{self[:mhs]}, should be #{@min_speed}", :perf_low
          elsif last == 'never' || last > @config[:alert_last_share]
            alarm "Miner #{num} last shares was #{last} min ago", :last_share
          elsif temp >= @config[:alert_temp_high]
            alarm "Miner #{num} too hot at #{temp}°C, needs cooling", :temp_high
          elsif self[:freq] && temp <= @config[:alert_temp_low]
            alarm "Miner #{num} temp low at #{temp}°C, is it hashing at all?", :temp_low
          end
        end
      end
    end

    # Reset or reboot Miner
    def reset
      `ssh root@#{ip} "reboot"`
    end

    def to_s
      "#{num}: " + FIELDS.map {|key, (width, _, _ )| @data[key].to_s.ljust(width)}.join(" ")
    end

  end
end
