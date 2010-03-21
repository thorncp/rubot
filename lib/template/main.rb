require "yaml"
require "rubot"

config = YAML.load_file 'resources/config.yml'

dispatcher = Rubot::Core::Dispatcher.new(config)
server = Rubot::Irc::Server.new(dispatcher)
server.connect