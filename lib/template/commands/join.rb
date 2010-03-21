class Join < Rubot::Core::Command
  acts_as_protected
  
  def execute(server, message, options)
    server.join(message.body)
  end
end