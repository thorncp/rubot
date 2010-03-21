class Reload < Rubot::Core::Command
  acts_as_protected

	def execute(server, message, options)
		@dispatcher.reload
		server.action(message.destination, "respawned")
	end
end