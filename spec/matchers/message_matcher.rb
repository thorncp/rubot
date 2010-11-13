class MessageMatcher
  def initialize(options = {})
    @options = options
  end
  
  def description
    "a message with - " + @options.map { |k,v| "#{k}: #{v}" }.join(", ")
  end
  
  def ==(actual)
    @options.all? { |k,v| actual.send(k) == v }
  end
end

def message_with(options)
  MessageMatcher.new(options)
end