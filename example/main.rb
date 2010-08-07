$:.unshift File.absolute_path("../lib")

require "yaml"
require "rubot"

config = YAML.load_file 'config.yml'

dispatcher = Rubot::Core::Dispatcher.new(config)
server = Rubot::Irc::Server.new(dispatcher)
server.connect