module Kernel
  def smartload(name)
    # find a less hackish way to do this
    require "#{File.dirname(__FILE__)}/../#{File.basename(self.to_s.underscore, '.rb')}/#{name.to_s.underscore}"
  end
end