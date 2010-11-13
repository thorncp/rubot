module Rubot
  module Server
    def initialize(config)
      @config = config
    end
    
    def connection_completed
      raw "USER" + " #{@config[:nick]}" * 4
      raw "NICK #{@config[:nick]}"
      @config[:channels].each { |c| raw("JOIN #{c}") } if @config[:channels]
    end

    def raw(msg)
      puts msg if verbose?
      send_data "#{msg}\n"
    end

    def receive_data(data)
      case data
        when /^PING :(.+)$/i
          raw "PONG :#{$1}"
      end
      
      if data =~ /hi rubot/i
        raw "PRIVMSG #rubot :hi!"
      end
      
      puts data if verbose?
    end
    
    def verbose?
      @config[:verbose]
    end
  end
end