class Auth < Rubot::Core::Command
  def execute(server, message, options)
    return if message.body != 'sudo4me'
    @dispatcher.add_auth(message.from)
  end
end