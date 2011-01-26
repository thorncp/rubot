module Rubot
  class Dispatcher
    def message_received(server, message)
      # todo: consider spamming all controllers with the command, and let them decide
      # for themselves whether or not to execute it. this will be how listeners will work,
      # and will make things more consistent
      if controller = find_contoller(message)
        controller.execute(message.alias, server: server, dispatcher: self, message: message)
      end
    end
    
    def find_contoller(message)
      if match = message.text.match(/^!(\w+)( .*)?$/i)
        message.alias = match[1]
        message.text.sub!("!#{match[1]}", "").strip
        @controllers.find { |c| c.execute?(match[1]) }
      end
    end
  end
end