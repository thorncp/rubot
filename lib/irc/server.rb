require "socket"

module Rubot
  module Irc
    # Performs the dirty work of communicating with an IRC server, passing messages
    # back and forth between the server and a dispatcher.
    class Server
      include Rubot::Irc::Constants
      # Our current nick
      attr_reader :nick
      
      # When a successful connection to the server was made
      attr_reader :connected_at
      
      # The list of channels we're currently in
      attr_reader :channels
  
      # Initializes a Server using the given dispatcher.
      #
      # The connection info to be used is extracted from the dispatcher's config method. (This
      # needs to be changed)
      #
      # ==== Parameters
      # dispatcher<Rubot::Core::Dispatcher>:: The dispatcher to handle the messages we receive
      def initialize(dispatcher)
        dispatcher.config["server"].each_pair do |key, value|
          instance_variable_set("@#{key}".to_sym, value)
        end
        @channels = @channels.split(",").collect(&:strip)
        @dispatcher = dispatcher
        
        @message_queue = MessageQueue.new(@message_delay)
        
        @message_queue.message do |destination, message|
          raw "PRIVMSG #{destination} :#{message}"
        end
        
        @message_queue.action do |destination, action|
          raw "PRIVMSG #{destination} :\001ACTION #{action}\001"
        end
      end
  
      # Attempts to make a connection to the server
      def connect
        return if @is_connected
    
        @conn = TCPSocket.open(@host, @port, @vhost)
        raw "USER #{@nick} #{@nick} #{@nick} :#{@real_name}"
        change_nick @nick
        join @channels
    
        begin
            main_loop()
        rescue Interrupt
        rescue Exception => detail
            puts detail.message()
            print detail.backtrace.join("\n")
            retry
        end
      end
  
      # Sends the quit command to the IRC server, then closes the connection.
      def quit
        raw "QUIT :#{@quit_message}"
        @conn.close
      end
  
      # Changes our nick.
      def change_nick(new_nick)
        raw "NICK #{new_nick}"
        @nick = new_nick
      end
  
      # Joins the specified channels, which can be comma separated string or an array.
      #
      # ==== Parameters
      # channels<String,Array>:: The channels to join
      def join(channels)
        channels = channels.split(',') if channels.is_a? String
        @channels.concat(channels).uniq!
        bulk_command("JOIN %s", channels)
      end
  
      # Parts the specified channels, which can be comma separated string or an array.
      #
      # ==== Parameters
      # channels<String,Array>:: The channels to part
      def part(channels)
        channels = channels.split(',') if channels.is_a? String
        @channels.reject! { |channel| channels.include?(channel) }
        bulk_command("PART %s :#{@quit_message}", channels)
      end
  
      # Adds message(s) to the outgoing queue
      #
      # ==== Parameters
      # destination<String>:: Where to send the message
      # message<String,Array>:: The message(s) to be sent
      def msg(destination, message)
        message = message.to_s.split("\n") unless message.is_a? Array
        build_message_array(message).each do |line|
          @message_queue.message(destination, line)
        end
      end
      
      # Adds action(s) to the outgoing queue
      #
      # ==== Parameters
      # destination<String>:: Where to send the message
      # action<String,Array>:: The actions(s) to be sent
      def action(destination, action)
        @message_queue.action(destination, action)
      end
  
      # Sends a raw line to the server and dumps it the console (to be replaced with a logger)
      #
      # ==== Parameters
      # message<String>:: The raw line to send
      def raw(message)
        puts "--> #{message}"
        @conn.puts "#{message}\n"
      end
  
      # Get the list of nicks in the given channel. I'm not sure if the current implementation
      # is really how it should be. TODO investigate
      #
      # ==== Parameters
      # channel<String>:: The channel whose nicks we want
      def names(channel)
        raw "NAMES #{channel}"
        @conn.gets.split(":")[2].split(" ")
      end
  
      private
      
      # The loop that goes on forever, reading input from the server.
      def main_loop
        loop do
          # something about this doesn't seem right. why are we using select and creating 
          # the ready object if we're never using it. TODO investigate wtf is going on here
          # and find a better solution
          ready = select([@conn])
          next unless ready
      
          return if @conn.eof
          s = @conn.gets
          handle_server_input(s)
    		end
      end
  
      # Determines what to do with the input from the server
      def handle_server_input(s)
    	  puts s # TODO logger
    
        case s.strip
          when /^PING :(.+)$/i
            raw "PONG :#{$1}"
          when /^:([-.0-9a-z]+)\s([0-9]+)\s(.+)\s(.*)$/i
            handle_meta($1, $2.to_i, $4)
          when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:(.+)$/i
            message = Rubot::Irc::Message.new($1, $4 == @nick ? $1 : $4, $5)
            # TODO add ability to pass events other than privmsg to dispatcher. ie, nick changes, parts, joins, quits, bans, etc, etc
            @dispatcher.handle_message(self, message)
        end
      end
  
      # performs the same command on each element in the given collection, separated by comma
      def bulk_command(formatted_string, elements)
        if elements.is_a? String
          elements = elements.split(',')
        end
    
        elements.each do |e|
          raw sprintf(formatted_string, e.to_s.strip)
        end
      end
  
      # Handles predefined events from the server.
      def handle_meta(server, code, message)
        case code
        when ERR_NICK_IN_USE
          if @nick == @alt_nick
            puts "all nicks used, don't know how to name myself."
            quit
            exit!
          end
          change_nick @alt_nick
          join @channels
        when WELLCOME
          @dispatcher.connected(self)
          @is_connected = true
          @connected_at = Time.now
        end
      end
  
      # Preps the string for sending to the server by breaking it down into
      # an array if it's too long
      def string_to_irc_lines(str)
        str.split(" ").inject([""]) do |arr, word|
          arr.push("") if arr.last.size > MAX_MESSAGE_LENGTH
          arr.last << "#{word} "
          arr
        end.map(&:strip)
      end
  
      # Ensures each string in the array is shorter than the max allowed message
      # length, breaking the string if necessary
      def build_message_array(arr)
        arr.each_with_index.map do |message, index|
          message.size > MAX_MESSAGE_LENGTH ? string_to_irc_lines(message) : arr[index]
        end.flatten
      end
    end
  end
end
