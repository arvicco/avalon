module Avalon

  # Node is a single object to be monitored
  # It should implement simple interface
  class Node

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

    # Sound alarm with message
    def alarm message, tune="Glass.aiff", n=1
      puts message

      tune = "/System/Library/Sounds/#{tune}" unless File.exist?(tune)
      n.times { `afplay #{tune}` }
    end

    # Check node status
    def check_status verbose
      raise "#{self.class} should implement #check_status"
    end

    # Report node errors (if any)
    def report_errors
      raise "#{self.class} should implement #report_errors"
    end

  end
end
