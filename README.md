# Flowdock

Ruby Gem for using the Flowdock Push API. See [Push API documentation](http://www.flowdock.com/api/push) for details.

## Build Status

[![Build Status](https://secure.travis-ci.org/flowdock/flowdock-api.png)](http://travis-ci.org/flowdock/flowdock-api)

flowdock gem is tested on Ruby 1.8.7, 1.9.3 and JRuby.

## Dependencies

* HTTParty
* MultiJson

## Installing

    gem install flowdock

If you're using JRuby, you'll also need to install jruby-openssl gem.

## Usage

To post content to Chat or Team Inbox, you need to use the target flow's API token. They can be found from [tokens page](https://www.flowdock.com/account/tokens).

### Posting to Chat

```ruby
require 'rubygems'
require 'flowdock'

# create a new Flow object with target flow's api token and external user name (enough for posting to Chat)
flow = Flowdock::Flow.new(:api_token => "__FLOW_TOKEN__", :external_user_name => "John")

# send message to Chat
flow.push_to_chat(:content => "Hello!", :tags => ["cool", "stuff"])
```

### Posting to Team Inbox

```ruby
# create a new Flow object with target flow's api token and sender information for Team Inbox posting
flow = Flowdock::Flow.new(:api_token => "__FLOW_TOKEN__",
  :source => "myapp", :from => {:name => "John Doe", :address => "john.doe@example.com"})

# send message to Team Inbox
flow.push_to_team_inbox(:subject => "Greetings from Flowdock API Gem!",
  :content => "<h2>It works!</h2><p>Now you can start developing your awesome application for Flowdock.</p>",
  :tags => ["cool", "stuff"], :link => "http://www.flowdock.com/")
```

### Posting to multiple flows

```ruby
require 'rubygems'
require 'flowdock'

# create a new Flow object with the api tokens of the target flows
flow = Flowdock::Flow.new(:api_token => ["__FLOW_TOKEN__", "__ANOTHER_FLOW_TOKEN__"], ... )

# see above examples of posting to Chat or Team Inbox
```

## API methods

* Flow methods

  `push_to_team_inbox` - Send message to Team Inbox. See [API documentation](http://www.flowdock.com/api/team-inbox) for details.

  `push_to_chat` - Send message to Chat. See [API documentation](http://www.flowdock.com/api/chat) for details.

  `send_message(params)` - Deprecated. Please use `push_to_team_inbox` instead.


## Capistrano deployment task

The Flowdock API Ruby Gem includes a ready task for sending deployment notifications with Capistrano (you need to have Grit installed too). Just add the task into your deploy.rb file and configure the settings to match your project and flow:

```ruby
require 'flowdock/capistrano'

# for Flowdock Gem notifications
set :flowdock_project_name, "My project"
set :flowdock_deploy_tags, ["frontend"]
set :flowdock_api_token, ["_YOUR_API_TOKEN_HERE_"]
```


## Copyright

Copyright (c) 2012 Flowdock Ltd. See LICENSE for further details.
