class QuitController < Rubot::Core::Controller
  command :quit do
    server.quit
    exit!
  end
end