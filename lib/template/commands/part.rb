class Part < Rubot::Core::Command
  acts_as_protected
  
  def execute(server, message, options)
    if message.body.empty?
      server.part(message.destination)
    else
      server.part(message.body)
    end
  end
end