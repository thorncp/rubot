Rubot is a framework for creating IRC bots.

## Installation

    gem install rubot
    rubot new botname
    cd botname
    bundle install
    vim config.yml
    bundle exec rubot server

## Usage

### Controllers

The `Rubot::Controller` class provides functionality to create commands, listen for messages, and subscribe to events. Within a command, listener, or event handler block, the `message` method gives access to the message that triggered the block to execute.

You can get the message sender's nick from `message.from`

Controllers are looked for in `APP_ROOT/controllers`, and are auto-required.

#### Commands

```ruby
class WebLinkController < Rubot::Controller
  command :calc do
    reply Google.calc(:q => message.text)
  end

  command :google, :g do
    reply Google.lmgtfy_url_for(message.text)
  end
end
```

#### Listeners

```ruby
class SubstitutionsController < Rubot::Controller
  listener :matches => /hello/ do
    reply "hello, #{message.from}"
  end
end
```

#### Events

```ruby
class AdminController < Rubot::Controller
  on :quit do
    puts "totally caught the quit event!"
  end

  on :connect do
    puts "totally caught the connect event!"
  end

  on :reload do
    puts "totally caught the reload event!"
  end
end
```

### Resources

A resource is just a class or module that is a source of data. Resources are looked for in `APP_ROOT/resources`, and are auto-required.

#### Hi

```ruby
module Google
  def self.lmgtfy_url_for(query)
    "http://www.lmgtfy.com/?q=#{CGI.escape(query)}"
  end
end
```

#### Web Resource
Rubot ships with a `Rubot::WebResource` class that can be inherited to add simple web scraping functionality.

```ruby
class Google < Rubot::WebResource
  get :calc, "http://www.google.com/search" do |doc|
    doc.css(".r")[0].text
  end
end
```

The `get` method will define a `calc` class method, whose parameters are expected to be a hash representing the query string that will be sent with the url.

```ruby
Google.calc(q: "1 + 1")
```

### Data Storage

Rubot uses a sqlite3 database that it will create for you in `APP_ROOT/db`. The framework itself does not utilize the database.

#### Models

```ruby
class Fact < Sequel::Model
  def self.random
    DB["select * from facts order by random() limit 1"].first
  end
end
```

Now `Fact.random` can be used from a controller.

## Future

* tests would be good
* extract the irc part so that the server protocol is interchangeable? e.g. support for slack/campfire/etc
* incorporate some resources, commands, listeners as core configurable extensions/plugins?

## Contributors

https://github.com/thorncp/rubot/graphs/contributors
