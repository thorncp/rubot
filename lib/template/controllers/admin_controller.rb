class AdminController < Rubot::Controller
  command :reload, protected: true do
    dispatcher.reload
    reply "reloaded"
  end

  command :quit, protected: true do
    dispatcher.quit
  end

  command :raw, protected: true do
    server.raw message.text
  end

  on :quit do
    puts "totally caught the quit event!"
  end

  on :connect do
    puts "totally caught the connect event!"
  end

  on :reload do
    puts "totally caught the reload event!"
  end
end
