module Rubot
  module Server
    include MessageQueue

    attr_reader :connected_at

    def initialize(dispatcher, config)
      @dispatcher = dispatcher
      @config = config
      @message_delay = config[:message_delay]
    end
    
    def connection_completed
      raw "PASS #{@config[:password]}" if @config[:password]
      raw "USER" + " #{@config[:nick]}" * 4
      raw "NICK " + @config[:nick]
      raw "JOIN " + @config[:channels].join(",") if @config[:channels]
    end

    def raw(msg)
      msg = msg.chomp + "\n"
      puts msg if verbose?
      send_data(msg)
    end

    def receive_data(data)
      puts data if verbose?
      
      case data
        when /^PING :(.+)$/i
          raw "PONG :#{$1}"
        when /^:([-.0-9a-z]+)\s([0-9]+)\s(.+)\s(.*)$/i
          handle_meta($1, $2.to_i, $4)
        when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+?)\s:(.+)$/i
          message = Message.new(from: $1, to: $4, text: $5.strip)
          @dispatcher.message_received(self, message)
      end
    end
    
    def verbose?
      @config[:verbose]
    end
    
    queue_method :message do |destination, text|
      raw "PRIVMSG #{destination} :#{text}"
    end

    queue_method :action do |destination, text|
      raw "PRIVMSG #{destination} :\001ACTION #{text}\001"
    end
    
    def nick
      @config[:nick]
    end

    def handle_meta(server, code, message)
      case code
      when 1 # welcome message, we're officially connected to the server. todo pull to constants
        @dispatcher.connected(self)
        @is_connected = true
        @connected_at = Time.now
      end
    end
  end
end