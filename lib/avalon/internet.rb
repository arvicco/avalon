module Avalon

  # Internet is a node encapsulating information about Internet connectivity
  class Internet < Node

    def poll verbose=true
      self[:google_ping] = `ping -c 1 www.google.com` =~ / 0.0% packet loss/
    end

    # Check for any exceptional situations with Node, sound alarm if any
    def report
      unless self[:google_ping]
        alarm "Google ping failed, check your Internet connection"
      end
    end
  end
end
