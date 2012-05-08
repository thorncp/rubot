Rubot is a framework for creating an IRC bot.  
 
Installation
------------
    gem install rubot
    rubot new botname
    cd botname
    bundle install 
    vim config.yml
    bundle exec rubot server
    nohup bundle exec rubot server & 
 
Usage
-----

`Rubot::Controller` adds functionality to the class, namely the
`message` method. `message` is an instance of the message that matched a
listener or triggered a command. 

You can get the message sender's nick from `message.from` 

* adding a command
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
 
* using listeners 
```ruby
class SubstitutionsController < Rubot::Controller
  listener :matches => /hello/ do
    reply "hello, #{message.from}"
  end
end
```
 
* adding resources
A resource is just a class or module that is a source of data. Resources are looked for
in `APP_ROOT/resources`

```ruby
module Google
  def self.lmgtfy_url_for(query)
    "http://www.lmgtfy.com/?q=#{CGI.escape(query)}"
  end
end
```

* using `Rubot::WebResource`
Rubot ships with a `Rubot::WebResource` class that can be subclassed to add simple
web scraping functionality.

```ruby
class Google < Rubot::WebResource
  get :calc, "http://www.google.com/search" do |doc|
    doc.css(".r")[0].text
  end
end
```

* generate a migration
    rake db:migration migration_name

* migrate the database
    rake db:migrate

NOTE: both the migrations and the sqlite database itself are stored
within `APP_ROOT/db`

* use database in a resource
```ruby
class Fact < Sequel::Model
  def self.random
    # this is a pretty shitty way of getting a random record
    DB["select * from facts order by random() limit 1"].first
  end
end
```

now `Fact.random` can be used from a controller

why should I use rubot to build my IRC bot?
-------------------------------------------

1. provides a very simple DSL for quickly adding commands
2. can update the application via git and reload  

where can I get more resources, commands, and listeners?
--------------------------------------------------------

http://github.com/mculp/rubot-listeners
http://github.com/mculp/rubot-commands
http://github.com/mculp/rubot-resources
 
Future
------
* incorporate some resources, commands, listeners as core configurable extensions/plugins? 
