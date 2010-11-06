class AdminController < Rubot::Core::Controller
  command :quit do
    @server.quit
    exit!
  end
  
  command :nick do
    if text =~ /^[a-z][-a-z0-9\[\]\\`^{}]+$/i
      @server.change_nick text
    else
      message "invalid nick"
    end
  end
  
  command :reload do
    @dispatcher.reload
    action "reloaded"
  end
end