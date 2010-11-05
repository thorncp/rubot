class AdminController < Rubot::Core::Controller
  command :quit do
    server.quit
    exit!
  end
  
  command :nick do
    server.change_nick message.body
  end
end