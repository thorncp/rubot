module Rubot
  module VariableHouse
    module ClassMethods
      def con_vars
        @con_vars ||= {}
      end

      def chan_vars
        @chan_vars ||= Hash.new { |h,k| h[k] = {} }
      end

      def nick_vars
        @nick_vars ||= Hash.new { |h,k| h[k] = {} }
      end

      def controller_variable(*vars)
        vars.each do |var|
          define_method(var) { con_vars[var] }
          define_method("#{var}=") { |val| con_vars[var] = val }
        end
      end

      def channel_variable(*vars)
        vars.each do |var|
          define_method(var) { chan_vars[message.to][var] }
          define_method("#{var}=") { |val| chan_vars[message.to][var] = val }
        end
      end

      def nick_variable(*vars)
        vars.each do |var|
          define_method(var) { nick_vars[message.from][var] }
          define_method("#{var}=") { |val| nick_vars[message.from][var] = val }
        end
      end
    end
    
    module InstanceMethods
      %w{con chan nick}.each do |var|
        define_method("#{var}_vars") { self.class.send("#{var}_vars") }
      end
    end
    
    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end