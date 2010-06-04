## resources/greeting.rb

# a few types of resources depending on what you want to do

# data kept in memory
class Greeting < Rubot::Resource::Static
  # basically creates attributes on the class
  resource :val
end

# data kept in db
class Greeting < Rubot::Resource::Model
  # ORM stuff here, or some other config location TBD
end

# web resource
class Greeting < Rubot::Resource::Web
  # maybe differentiate between screen scraping and web apis with different classes TBD
  resource "http://some-web-resource.com/", :as => :val, :params => [:param_one, :param_two] do |response|
    # handle response
    response[/val=(.+)/i, 1]
  end
  
  # to be invoked like
  #   val = Greeting.val(:param_one => "some value", :param_two => "another value")
  #
  # or, if ruby >= 1.9, take advantage of ordered hashes
  #   val = Greeting.val("some value", "another value") # note: this could possibly get quite ugly
end

## controllers/greeting_controller.rb
class GreetingController < Rubot::Core::Controller
  # !greet Steve_ => "Hello there Steve_"
  command :greet do
    # server and message are method calls that will return the appropriate objects
    server.msg(message.destination, Greeting.val % message.body)
  end
  
  command :hi, :hello do
    # options is a method call that will return the appropriate object
    reply = options[:alias] == :hi ? "hi there %s" : "hello there %s"
    server.msg(message.destination, reply % message.from)
  end
  
  # Steve_ joins #resdat => "Hello there Steve_"
  on :join do
    server.msg(message.destination, Greeting.val % message.from)
  end
  
  listen do
    # listen to all messages
  end
  
  listen :from => "Steve_" do
    # listen for all messages from Steve_
  end
  
  listen :matches => /some_regex/ do
    # listen for a message that matches a pattern
  end
  
  # initialize the resource when necessary
  on :startup, :reload do
    Greeting.val = "Hello there %s"
  end
end