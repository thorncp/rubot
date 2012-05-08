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
 
* adding a command
```ruby
class GoogleController < Rubot::Controller
  command :google do
  end
end
```
 
* using listeners 
```ruby
class SubstitutionsController < Rubot::Controller
  listener :matches =>  /hello/ do
    reply "hello world"
  end
end
```
 
* adding resources 


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
