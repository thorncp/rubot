require "socket"

module Rubot
  module Irc
    class Server
      include Rubot::Irc::Constants
      attr_reader :nick, :connected_at
  
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
  
      def quit
        raw "QUIT :#{@quit_message}"
        @conn.close
      end
  
      def change_nick(new_nick)
        raw "NICK #{new_nick}"
        @nick = new_nick
      end
  
      def join(channels)
        channels = channels.split(',') if channels.is_a? String
        @channels.concat(channels).uniq!
        bulk_command("JOIN %s", channels)
      end
  
      def part(channels)
        channels = channels.split(',') if channels.is_a? String
        @channels.reject! { |channel| channels.include?(channel) }
        bulk_command("PART %s :#{@quit_message}", channels)
      end
  
      def msg(destination, message)
        @message_queue.message(destination, message)
        #message = message.to_s.split("\n") unless message.is_a? Array
        #build_message_array(message).each do |l|
        #  raw "PRIVMSG #{destination} :#{l}"
        #end
      end
  
      def action(destination, message)
        @message_queue.action(destination, message)
        #msg(destination, "\001ACTION #{message}\001")
      end
  
      def raw(message)
        puts "--> #{message}"
        @conn.puts "#{message}\n"
      end
  
      def names(channel)
        raw "NAMES #{channel}"
        @conn.gets.split(":")[2].split(" ")
      end
  
      private
  
      def main_loop
        while true
          ready = select([@conn])
          next unless ready
      
          return if @conn.eof
          s = @conn.gets
          handle_server_input(s)
    		end
      end
  
      def handle_server_input(s)
    	  puts s
    
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
  
      def string_to_irc_lines(str)
        str.split(" ").inject([""]) do |arr, word|
          arr.push("") if arr.last.size > MAX_MESSAGE_LENGTH
          arr.last << "#{word} "
          arr
        end.map(&:strip)
      end
  
      def build_message_array(arr)
        arr.each_with_index.map do |message, index|
          message.size > MAX_MESSAGE_LENGTH ? string_to_irc_lines(message) : arr[index]
        end.flatten
      end
    end
  end
end