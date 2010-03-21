class Quit < Rubot::Core::Command
  acts_as_protected

  def execute(server, message, options)
	  server.quit
	  exit!
  end
end