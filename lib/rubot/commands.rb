# todo: better name
module Rubot
  module Commands
    def command(cmd, &block)
      commands[cmd.to_s] = block
    end
  
    def commands
      @commands ||= {}
    end
  
    def execute?(cmd)
      commands.include? cmd.to_s
    end
  
    def execute(cmd, args = {})
      raise NoCommandError, "#{cmd} is not implemented in #{self}" unless @commands.include? cmd.to_s
      self.new(args).instance_exec(&@commands[cmd.to_s])
    end
  end
end
