module Avalon
  module Utils

    def system
      @system = `uname -a`.match(/^\w*/).to_s
    end

    # Helper method: play a sound file
    def play tune
      file = [ tune,
               File.expand_path("../../../sound/#{tune}", __FILE__),
               File.expand_path("~/sound/#{tune}", __FILE__),
               File.expand_path("/System/Library/Sounds/#{tune}")
               ].find {|f| File.exist?(f)}

      case system
      when 'Darwin'
        `afplay #{file}`
      when 'Linux'
        raise 'Please install sox package: sudo apt-get install sox' if `which sox`.empty?
        `play #{file}`
      end
    end

    # Helper method: sound alarm with message
    def alarm message, *tunes
      puts message

      tunes.push('Glass.aiff') if tunes.empty?

      tunes.each {|tune| play tune }
    end

    # Helper method: ping the Node, return ping time in ms
    def ping ip
      ping_result = `ping -c 1 #{ip}`
      if ping_result =~ / 0.0% packet loss/
        ping_result.match(/time=([\.\d]*) ms/)[1].to_f
      end
    end

  end
end
