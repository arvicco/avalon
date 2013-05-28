module Avalon
  # "STATUS=S,When=1368715953,Code=11,Msg=Summary,Description=cgminer 2.10.5|
  #  SUMMARY,Elapsed=58219,MHS av=70827.84,Found Blocks=0,Getworks=1899,Accepted=14755,
  #  Rejected=162,Hardware Errors=2352,Utility=15.21,Discarded=3529,Stale=0,Get Failures=0,
  #  Local Work=1068039,Remote Failures=0,Network Blocks=107,Total MH=4123494727.5140,
  #  Work Utility=992.58,Difficulty Accepted=944320.00000000,Difficulty Rejected=10368.00000000,
  #  Difficulty Stale=0.00000000,Best Share=7493180|\u0000"

  class Miner

    attr_accessor :data

    # Field formats: name => [width, pattern, type/conversion]
    FIELDS = { :mhs => [10, /MHS av=([\d\.]*)/, :f],
               :uptime => [6, /Elapsed=([\d\.]*)/, ->(x){ (x.to_i/60.0/60.0).round(2)}],
               :utility => [7, /,Utility=([\d\.]*)/, :f],
               :getworks => [8, /Getworks=([\d\.]*)/, :i],
               :accepted => [8, /,Accepted=([\d\.]*)/, :i],
               :rejected => [8, /Rejected=([\d\.]*)/, :i],
               :stale => [6, /Stale=([\d\.]*)/, :i],
               :errors => [6, /Hardware Errors=([\d\.]*)/, :i],
               :blocks => [6, /Network Blocks=([\d\.]*)/, :i],
               :found => [2, /Found Blocks=([\d\.]*)/, :i],
               }

    def self.print_headers
      puts "\nMiner status as of #{Time.now.getlocal.asctime}:\n#{}"
      puts "#    " + FIELDS.map {|name, (width,_,_ )| name.to_s.ljust(width)}.join(' ')
    end

    def [] key
      @data[key]
    end

    # Extract stats from status string
    def initialize num
      @num = num
    end

    def update_data status
      if status.empty? #
        @data = {}
      else
        # Convert the status string into usable data pairs
        pairs = FIELDS.map do |name, (_, pattern, type)|
          data_str = status.match(pattern)[1]
          data = if type.is_a?(Symbol)
            data_str.send("to_#{type}")
          elsif type.respond_to?(:call)
            type.call(data_str)
          else
            nil
          end
          [name, data]
        end
        @data = Hash[*pairs.flatten]
      end
    end

    def check_status verbose=true
      ping = `ping -c 1 10.0.1.#{@num}`

      status = ping =~ /100.0% packet loss/ ? "" : `bash -ic "echo -n 'summary' | nc 10.0.1.#{@num} 4028"`

      update_data status

      puts "#{self}" if verbose
    end

    # Sound alarm with message
    def alarm message, tune="Glass.aiff", n=1
      puts message

      tune = "/System/Library/Sounds/#{tune}" unless File.exist?(tune)
      n.times { `afplay #{tune}` }
    end

    # Check for any exceptional situations in stats, sound alarm if any
    def report_errors
      if data.empty?
        alarm "Miner #{@num} did not respond to status query"
      elsif self[:mhs] < 60000 and self[:uptime] > 0.1
        alarm "Miner #{@num} performance too low: #{self[:mhs]}"
      elsif self[:uptime] < 0.05
        alarm "Miner #{@num} restarted", "Frog.aiff"
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
