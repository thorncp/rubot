class Msg < Rubot::Core::Command
  acts_as_protected
  def execute(server, message, options)
    server.msg(message.body.split(" ")[0], message.body.split(" ")[1..-1].join(" "))
  end
end