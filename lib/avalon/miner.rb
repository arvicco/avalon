module Avalon
  # "STATUS=S,When=1368715953,Code=11,Msg=Summary,Description=cgminer 2.10.5|
  #  SUMMARY,Elapsed=58219,MHS av=70827.84,Found Blocks=0,Getworks=1899,Accepted=14755,
  #  Rejected=162,Hardware Errors=2352,Utility=15.21,Discarded=3529,Stale=0,Get Failures=0,
  #  Local Work=1068039,Remote Failures=0,Network Blocks=107,Total MH=4123494727.5140,
  #  Work Utility=992.58,Difficulty Accepted=944320.00000000,Difficulty Rejected=10368.00000000,
  #  Difficulty Stale=0.00000000,Best Share=7493180|\u0000"

  # Miner is a node encapsulating a single Avalon unit
  class Miner < Node

    # type = :absolute_time | :absolute_date | :relative_time
    def self.my_time t, type=:absolute_time
      time = Time.at(t.to_f)
      case type
      when :absolute_date
        time.getlocal.strftime("%Y-%m-%d %H:%M:%S")
      when :absolute_time
        time.getlocal.strftime("%H:%M:%S")
      when :relative_time
        time.utc.strftime("#{(time.day-1)*24+time.hour}:%M:%S")
      end
    end


    # Field formats: name => [width, pattern, type/conversion]
    FIELDS = { :ping => [8, /./, nil],  # not in miner status string...
               :mhs => [6, /(?<=MHS av=)[\d\.]*/, :i],
               # :uptime => [6, /(?<=Elapsed=)[\d\.]*/, ->(x){ (x.to_i/60.0/60.0).round(2)}],
               :uptime => [8, /(?<=Elapsed=)[\d\.]*/, ->(x){ my_time(x, :relative_time)}],
               :last => [8, /(?<=Last Share Time=)[\d\.]*/,
                         ->(x){ my_time(Time.now.getgm-x.to_i, :relative_time)}],
                         # ->(x){ my_time(Time.now-Time.at(x.to_i), :relative_time)}],
               :utility => [7, /(?<=,Utility=)[\d\.]*/, :f],
               :getworks => [8, /(?<=Getworks=)[\d\.]*/, :i],
               :accepted => [8, /(?<=,Accepted=)[\d\.]*/, :i],
               :rejected => [8, /(?<=Rejected=)[\d\.]*/, :i],
               :stale => [6, /(?<=Stale=)[\d\.]*/, :i],
               :errors => [6, /(?<=Hardware Errors=)[\d\.]*/, :i],
               :blocks => [6, /(?<=Network Blocks=)[\d\.]*/, :i],
               :found => [2, /(?<=Found Blocks=)[\d\.]*/, :i],
               }

    def self.print_headers
      puts "\nMiner status as of #{Time.now.getlocal.asctime}:\n#{}"
      puts "#    " + FIELDS.map {|name, (width,_,_ )| name.to_s.ljust(width)}.join(' ')
    end

    def initialize ip, min_speed
      @ip = ip
      @num = ip.split('.').last.to_i
      @min_speed = min_speed * 1000 # Gh/s to Mh/s
      @blanks = 0
      super()
    end

    # Extract data from status string
    def extract_data_from status
      if status.empty? #
        @data.clear
      else
        # Convert the status string into usable data pairs
        pairs = FIELDS.map do |name, (_, pattern, type)|
          value_str = status[pattern] #[1]
          if type.is_a?(Symbol)
            [name, value_str.send("to_#{type}")]
          elsif type.respond_to?(:call)
            [name, type.call(value_str)]
          else
            nil
          end
        end
        @data.merge! Hash[*pairs.compact.flatten]
      end
    end

    def get api_call
      self[:ping] ? `bash -ic "echo -n '#{api_call}' | nc #{@ip} 4028"` : ""
    end

    def poll verbose=true
      self[:ping] = ping @ip

      status = get('summary') + get('pools')

      extract_data_from status

      puts "#{self}" if verbose
    end

    def upminutes
      Time.utc(1970, 01, 01, *self[:uptime].split(/:/).map(&:to_i)).to_i/60.0
    end

    # Check for any exceptional situations in stats, sound alarm if any
    def report
      if data.empty?
        @blanks += 1
        alarm "Miner #{@num} did not respond to status query" if @blanks > 1
      else
        @blanks = 0
        if self[:mhs] < @min_speed*0.95 and upminutes > 5
          alarm "Miner #{@num} performance is #{self[:mhs]}, should be #{@min_speed}"
        elsif upminutes < 2
          alarm "Miner #{@num} restarted", "Frog.aiff"
        end
      end
    end

    def to_s
      "#{@num}: " + @data.map {|name, value| value.to_s.ljust(FIELDS[name][0])}.join(" ")
    end

    def inspect
      @data.map {|name, value| "#{name}:#{value}"}.join(" ")
    end

  end
end
