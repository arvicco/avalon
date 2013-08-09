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
      :unit => [6, /(?<=MHS av=)[\d\.]*/, :i],
      :pool => [6, /./, nil], # not in miner status string...
      :ping => [6, /./, nil],  # not in miner status string...
      :rst => [3, /./, nil],  # not in miner status string...
      :uptime => [9, /(?<=Elapsed=)[\d\.]*/, ->(x){ my_time(x, :relative_time)}],
      :last => [8, /(?<=Status=Alive,).*?Last Share Time=[\d\.]*/,
                ->(x){ convert_last(x)}],
      :miner => [5, /(?<=Description=cgminer )[\d\.]*/, :s],
      :freq => [4, /(?<=frequency=)[\d\.]*/, :i],
      :'°C' => [2, /(?<=Temperature=)[\d\.]*/, :i],
      :fan2 => [4, /(?<=fan2=)[\d\.]*/, :i],
      :fan3 => [4, /(?<=fan3=)[\d\.]*/, :i],
      :WU => [4, /(?<=,Work Utility=)[\d\.]*/, :i],
      :getwork => [7, /(?<=Getworks=)[\d\.]*/, :i],
      :accept => [6, /(?<=,Accepted=)[\d\.]*/, :i],
      :reject => [6, /(?<=Rejected=)[\d\.]*/, :i],
      :stale => [5, /(?<=Stale=)[\d\.]*/, :i],
      :error => [6, /(?<=Hardware Errors=)[\d\.]*/, :i],
      # :block => [5, /(?<=Network Blocks=)[\d\.]*/, :i],
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
      puts "\nMiner status as of #{Time.now.getlocal.asctime}:\nmhs: " +
        FIELDS.map {|name, (width,_,_ )| name.to_s.rjust(width)}.join(' ')
    end

    def initialize monitor, ip, min_mhs, worker_name=nil
      @ip, @min_mhs, @worker_name = ip, min_mhs*1000 , worker_name
      @monitor = monitor
      @config = Avalon::Config.config # TODO: monitor.config?
      @fails = 0
      super()
    end

    def get_api call
      self[:ping] ? `bash -ic "echo -n '#{call}' | nc #{@ip} 4028"` : ""
    end

    def poll verbose=true
      self[:ping] = ping @ip

      status = get_api('summary') + get_api('pools') + get_api('devs') + get_api('stats')
      @poll_time = Time.now
      # p get_api('summary')

      data = self.class.extract_data_from(status)

      if data.empty?
        @data = {:ping => self[:ping], :rst => self[:rst]}
      else
        @data.merge! data
        if @config[:monitor][:per_hour]
          [:getwork, :accept, :reject, :stale, :error].each do |key|
            self[key] = (self[key]/upminutes*60).round(1) if self[key]
          end
        end
      end

      self[:pool] = pool_hash

      puts "#{self}" if verbose
    end

    def upminutes
      duration(self[:uptime])
    end

    def last
      duration(self[:last])
    end

    def restart_time
      @poll_time - upminutes * 60.0
    end

    def temp
      self[:'°C']
    end

    def unit_hash
      self[:unit] || 0
    end

    def pool_hash
      if @monitor.pool && @worker_name && @monitor.pool[:workers] && @monitor.pool[:workers][@worker_name]
        @monitor.pool[:workers][@worker_name][:hash_rate].round(0)
      end
    end

    # Check for any exceptional situations in stats, sound alarm if any
    def report
      if data[:ping].nil? || data[:unit].nil?
        @fails += 1
        if @fails >= @config[:alert_after]
          alarm "Miner #{num} did not respond to status query", :failure
        end
      else
        @fails = 0
        @last_restart ||= restart_time

        # Detect Miner reset correctly
        if (restart_time - @last_restart) > 20
          @last_restart = restart_time
          self[:rst] = (self[:rst] || 0) + 1
          alarm "Miner #{num} restarted", :restart
        elsif unit_hash == 0 && last == 'never' && temp == 0
          alarm "Miner #{num} is stuck in error state!!!", :failure
        elsif upminutes > 5 # Miner settled down
          if unit_hash < @min_mhs
            alarm "Miner #{num} performance is #{unit_hash}, should be #{@min_mhs}", :perf_low
          elsif last == 'never' || last > @config[:alert_last_share]
            alarm "Miner #{num} last shares was #{last} min ago", :last_share
          elsif temp && temp >= @config[:alert_temp_high]
            alarm "Miner #{num} too hot at #{temp}°C, needs cooling", :temp_high
          elsif self[:freq] && temp && temp <= @config[:alert_temp_low]
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
      num.to_s.rjust(3) + ": " + 
        FIELDS.map {|key, (width, _, _ )| @data[key].to_s.rjust(width)}.join(" ")
    end

  end
end
