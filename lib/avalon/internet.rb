module Avalon

  # Internet is a node encapsulating information about Internet connectivity
  class Internet < Node

    def check_status verbose=true
      ping = `ping -c 1 www.google.com`

      self[:google_ping] = ping =~ / 0.0% packet loss/

    end

    # Check for any exceptional situations in stats, sound alarm if any
    def report_errors
      unless self[:google_ping]
        alarm "Google ping failed, check your Internet connection"
      end
    end
  end
end
