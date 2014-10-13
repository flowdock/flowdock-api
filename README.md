# Flowdock

Ruby Gem for using the Flowdock Push API. See [Push API documentation](http://www.flowdock.com/api/push) for details.

## Build Status

[![Build Status](https://secure.travis-ci.org/flowdock/flowdock-api.png)](http://travis-ci.org/flowdock/flowdock-api)

flowdock gem is tested on Ruby 1.9.3 and JRuby.

## Dependencies

* HTTParty
* MultiJson

## Installing

    gem install flowdock

If you're using JRuby, you'll also need to install jruby-openssl gem.

## Usage

To post content to Chat or Team Inbox using `Flowdock::Flow`, you need to use the target flow's API token.

Alternatively you can use your personal api token and the `Flowdock::Client`.

All tokens can be found in [tokens page](https://www.flowdock.com/account/tokens).

### REST API

To create an api client you need your personal api token:

```ruby
require 'rubygems'
require 'flowdock'

# Create a client that uses you api token to authenticate
client = Flowdock::Client.new(api_token: '__MY_PERSONAL_API_TOKEN__')
```

#### Posting to Chat

To send a chat message or comment, you can use the client.chat_message:

```ruby
flow_id = 'acdcabbacd0123456789'

# Send a simple chat message
client.chat_message(flow: flow_id, content: "I'm sending a message!", tags: ['foo', 'bar'])

# Send a comment to message 1234
client.chat_message(flow: flow_id, content: "Now I'm commenting!", message: 1234)
```

Both methods return the created message as a hash.

#### Arbitary api access

You can use the client to access api in other ways too. See [REST API documentation](http://www.flowdock.com/api/rest) for all the resources.

```ruby

# Fetch all my flows
flows = client.get('/flows')

# Update a flow's name
client.put('/flows/acme/my_flow', name: 'Your flow')

# Delete a message
client.delete('/flows/acme/my_flow/messages/12345')

# Create an invitation
client.post('/flows/acme/my_flow/invitations', email: 'user@example.com', message: "I'm inviting you to our flow using api.")

```

### Push api

To use the push api, you need a flow token:

#### Posting to Chat

```ruby
require 'rubygems'
require 'flowdock'

# create a new Flow object with target flow's api token and external user name (enough for posting to Chat)
flow = Flowdock::Flow.new(:api_token => "__FLOW_TOKEN__", :external_user_name => "John")

# send message to Chat
flow.push_to_chat(:content => "Hello!", :tags => ["cool", "stuff"])
```

#### Posting to Team Inbox

```ruby
# create a new Flow object with target flow's api token and sender information for Team Inbox posting
flow = Flowdock::Flow.new(:api_token => "__FLOW_TOKEN__",
  :source => "myapp", :from => {:name => "John Doe", :address => "john.doe@example.com"})

# send message to Team Inbox
flow.push_to_team_inbox(:subject => "Greetings from Flowdock API Gem!",
  :content => "<h2>It works!</h2><p>Now you can start developing your awesome application for Flowdock.</p>",
  :tags => ["cool", "stuff"], :link => "http://www.flowdock.com/")
```

#### Posting to multiple flows

```ruby
require 'rubygems'
require 'flowdock'

# create a new Flow object with the api tokens of the target flows
flow = Flowdock::Flow.new(:api_token => ["__FLOW_TOKEN__", "__ANOTHER_FLOW_TOKEN__"], ... )

# see above examples of posting to Chat or Team Inbox
```

## API methods

* `Flowdock::Flow` methods

  `push_to_team_inbox` - Send message to Team Inbox. See [API documentation](http://www.flowdock.com/api/team-inbox) for details.

  `push_to_chat` - Send message to Chat. See [API documentation](http://www.flowdock.com/api/chat) for details.

  `send_message(params)` - Deprecated. Please use `push_to_team_inbox` instead.

* `Flowdock::Client` methods

  `chat_message` - Send message to Chat.

  `post`, `get`, `put`, `delete` - Send arbitary api calls. First parameter is the path, second is data. See [REST API documentation](http://www.flowdock.com/api/rest).

## Deployment notifications

There are separate gems for deployment notifications:

* [capistrano-flowdock](https://github.com/flowdock/capistrano-flowdock)
* [mina-flowdock](https://github.com/elskwid/mina-flowdock)

## Changelog

* 0.5.0 - Added `Flowdock::Client` that authenticates using user credentials and can be used to interact with the api. Better threads support for both `Flow` and `Client` so that comments can be made.

## Copyright

Copyright (c) 2012 Flowdock Ltd. See LICENSE for further details.
