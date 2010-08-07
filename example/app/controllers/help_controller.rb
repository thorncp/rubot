class HelpController < Rubot::Core::Controller
  command :help, :hi, :hello do
    server.msg(message.destination, "hello")
  end
end