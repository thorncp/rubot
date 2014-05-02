module Rubot
  module CallbackHandler
    def receive_data(data)
      begin
        callback = JSON.parse(data)

        callback['channels'].each do |channel|
          $conn.message channel, callback['message']
        end
      rescue
        puts "invalid callback format: #{data}"
      end
    end
  end
end
