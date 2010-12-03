module Rubot
  module Server
    def initialize(dispatcher, config)
      @dispatcher = dispatcher
      @config = config
    end
    
    def connection_completed
      raw "USER" + " #{@config[:nick]}" * 4
      raw "NICK " + @config[:nick]
      raw "JOIN " + @config[:channels].join(",") if @config[:channels]
    end

    def raw(msg)
      # todo: need a queueing system with delay
      msg = msg.chomp + "\n"
      puts msg if verbose?
      send_data(msg)
    end

    def receive_data(data)
      puts data if verbose?
      
      case data
        when /^PING :(.+)$/i
          raw "PONG :#{$1}"
        when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:(.+)$/i
          message = Message.new(from: $1, to: $4, text: $5.strip)
          @dispatcher.message_received(self, message)
      end
    end
    
    def verbose?
      @config[:verbose]
    end
    
    def message(destination, text)
      raw "PRIVMSG #{destination} :#{text}"
    end
  end
end