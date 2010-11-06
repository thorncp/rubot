class HelpController < Rubot::Core::Controller
  command :help, :hi, :hello do
    message "hello"
  end
end