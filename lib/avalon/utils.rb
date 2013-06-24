module Avalon
  module Utils

    def system
      @system ||= `uname -a`.match(/^\w*/).to_s
    end

    def find_file *locations
      locations.map {|loc| File.expand_path(loc,__FILE__)}.find {|f| File.exist?(f)}
    end

    # Helper method: play a sound file
    def play what
      tunes = [Avalon::Config[:alert_sounds][what] || what].compact.flatten

      tunes.each do |tune|
        file = find_file( tune, "../../../sound/#{tune}",
                          "~/.avalon/sound/#{tune}", "/System/Library/Sounds/#{tune}")
        case system
        when 'Darwin'
          `afplay #{file}`
        when 'Linux'
          raise 'Please install sox package: sudo apt-get install sox' if `which sox`.empty?
          `play -q #{file}`
        end
      end
    end

    # Helper method: sound alarm with message
    def alarm message, sound=:failure
      puts message
      play sound
    end

    # Helper method: ping the Node, return ping time in ms
    def ping ip
      ping_result = `ping -c 1 #{ip}`
      if ping_result =~ /( | 0.)0% packet loss/
        ping_result.match(/time=([\.\d]*) ms/)[1].to_f
      end
    end

  end
end
