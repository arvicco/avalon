module Avalon

  # Node is a single object to be monitored
  # It should implement simple interface, only 2 required methods: #poll and #report
  class Node

    # Builder method for creating Node subclasses from config arrays
    def Node.create *args
      subclass = Avalon.const_get(args.first.capitalize)
      subclass.new *args.drop(1)
    end

    attr_accessor :data

    def initialize
      @data = {}
    end

    # Get a specific data point about this Node
    def [] key
      @data[key]
    end

    # Set a specific data point
    def []= key, value
      @data[key] = value
    end

    # Helper method: sound alarm with message
    def alarm message, *tunes
      puts message

      tunes.push('Glass.aiff') if tunes.empty?

      tunes.each do |tune|
        File.exist?(tune) ? `afplay #{tune}` : `afplay /System/Library/Sounds/#{tune}`
      end
    end

    # Helper method: ping the Node
    def ping ip
      ping_result = `ping -c 1 #{ip}`
      if ping_result =~ / 0.0% packet loss/
        ping_result.match(/time=([\.\d]*) ms/)[1].to_f
      end
    end

    # Abstract: Check node status
    # If verbose, the Node should print out its state after the status update
    def poll verbose
      raise "#{self.class} should implement #poll"
    end

    # Abstract: Report node errors or special situations (if any)
    def report
      raise "#{self.class} should implement #report"
    end

  end
end
