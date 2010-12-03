module Rubot
  class Dispatcher
    def message_received(server, message)
      if controller = find_contoller(message)
        controller.execute(message.alias, server: server, dispatcher: self, message: message)
      end
    end
    
    def find_contoller(message)
      puts message.inspect
      if match = message.text.match(/^!(\w+)( .*)?$/i)
        message.alias = match[1]
        message.text.sub!("!#{match[1]}", "").strip
        @controllers.find { |c| c.execute?(match[1]) }
      end
    end
  end
end