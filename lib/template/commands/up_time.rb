class UpTime < Rubot::Core::Command
  aliases :uptime, :up
  
  def execute(server, message, options)
    server.msg(message.destination, seconds_to_words(Time.now - server.connected_at))
  end
  
  def seconds_to_words(seconds)
    time = "#{(seconds % 60).to_i} seconds"
    
    minutes = seconds / 60
    
    if minutes >= 1
      hours = minutes / 60
      time.insert(0, "#{(minutes % 60).to_i} minutes ")
      
      if hours >= 1
        days = hours / 24
        time.insert(0, "#{(hours % 24).to_i} hours ")
        
        if days >= 1
          time.insert(0, "#{days.to_i} days ")
        end
      end
    end
    
    time
  end
end