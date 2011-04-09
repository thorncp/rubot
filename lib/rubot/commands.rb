# todo: better name
module Rubot
  module Commands
    def command(*names, &block)
      options = names.extract_options!
      names.each do |name|
        commands[name.to_s] = options.merge :block => block
      end
    end
  
    def commands
      @commands ||= {}
    end
  
    def execute?(name)
      commands.include? name.to_s
    end
  
    def execute(name, args = {})
      command = commands[name.to_s]
      raise NoCommandError, "#{name} is not implemented in #{self}" unless command
      raise AuthorizationError, "Unauthorized call to protected command `#{name}'" if command[:protected] && !args[:authorized]
      self.new(args).instance_exec(&command[:block])
    end
  end
end
