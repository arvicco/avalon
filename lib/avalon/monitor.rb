require "avalon/miner"

module Avalon
  class Monitor
    def initialize miners
      @miners = miners
    end

    # Sound alarm with message
    def alarm message, tune="Glass.aiff", n=1
      puts message

      tune = "/System/Library/Sounds/#{tune}" unless File.exist?(tune)
      n.times { `afplay #{tune}` }
    end

    # Collect miner stats for a set of miners
    def collect_stats miner_set, output=true
      if output
        puts
        puts "Miner status as of #{Time.now.getlocal.asctime}:"
        puts Avalon::Stat.headers
      end

      Hash[
        *miner_set.map do |i|
          ping = `ping -c 1 10.0.1.#{i}`

          status = ping =~ /100.0% packet loss/ ? "" : `bash -ic "echo -n 'summary' | nc 10.0.1.#{i} 4028"`

          stat = Avalon::Stat.new(status)

          puts "#{i}: #{stat}" if output

          [i, stat]
        end.flatten
      ]
    end

    # Check for any exceptional situations in stats, sound alarm if any
    def check_stats stats
      stats.each do |num, stat|
        if stat.data.empty?
          alarm "Miner #{num} did not respond to status query"
        elsif stat[:mhs] < 60000 and stat[:uptime] > 0.1
          alarm "Miner #{num} performance too low: #{stat[:mhs]}"
        elsif stat[:uptime] < 0.05
          alarm "Miner #{num} restarted", "Frog.aiff"
        end
      end
    end

    def run
      while true do
          stats = collect_stats @miners
          check_stats stats
          sleep 60
        end
      end
    end

  end
