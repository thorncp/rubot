class Help < Rubot::Core::Command
  def execute(server, message, options)
    reply = @dispatcher.commands.keys.collect do |command|
      @dispatcher.function_character + command.to_s
    end.sort.join(", ")
    server.msg(message.destination, reply)
  end
end