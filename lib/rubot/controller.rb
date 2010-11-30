module Rubot
  class Controller
    def self.inherited(subclass)
      # setup class level instance variables our methods expect to be present
      subclass.instance_exec do
        @commands = {}
      end
    end
    
    def self.command(cmd, &block)
      @commands[cmd.to_s] = block
    end
    
    def self.commands
      @commands
    end
    
    def self.execute?(cmd)
      @commands.include? cmd.to_s
    end
    
    def self.execute(cmd, args = {})
      raise NoCommandError, "#{cmd} is not implemented in #{self}" unless @commands.include? cmd.to_s
      self.new(args).instance_exec(&@commands[cmd.to_s])
    end
    
    def initialize(params)
      @params = params
    end
    
    def server
      @params[:server]
    end
  end
end