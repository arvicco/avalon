module Avalon

  # Encapsulates DLI Web Power Switch
  class Switch

    def initialize user, pass, ip, outlet
      @user, @pass, @ip, @outlet = user, pass, ip, outlet
      raise 'Please install curl: sudo apt-get install curl' if `which curl`.empty?
    end

    def on
      `curl -s http://#{@user}:#{@pass}@#{@ip}/outlet?#{@outlet}=ON`
    end

    def off
      `curl -s http://#{@user}:#{@pass}@#{@ip}/outlet?#{@outlet}=OFF`
    end

  end
end
