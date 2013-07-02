module Avalon

  # Node is a single object to be monitored
  # It should implement simple interface, only 2 required methods: #poll and #report
  class Node
    include Utils # Helper methods

    # Builder method for creating Node subclasses from config arrays
    def Node.create monitor, *args
      subclass = Avalon.const_get(args.first.capitalize)
      subclass.new monitor, *args.drop(1)
    end

    attr_reader :ip, :data

    def initialize
      @data = {}
    end

    def num
      @num ||= @ip ? @ip.split('.').last.to_i : ""
    end

    # Get a specific data point about this Node
    def [] key
      @data[key]
    end

    # Set a specific data point
    def []= key, value
      @data[key] = value
    end

    ### Node API: following methods should be defined:

    def unit_hash
    end

    def pool_hash
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

    # Abstract: Reset or reboot node
    def reset
      raise "#{self.class} should implement #report"
    end

  end
end
