# Flowdock

Ruby gem for using the Flowdock Push API. See the [Push API documentation](http://www.flowdock.com/api/push) for details.

## Build Status

[![Build Status](https://secure.travis-ci.org/flowdock/flowdock-api.png)](http://travis-ci.org/flowdock/flowdock-api)

The Flowdock gem is tested on Ruby 2.1 and JRuby.

## Dependencies

* HTTParty
* MultiJson

## Installing

    gem install flowdock

If you're using JRuby, you'll also need to install the `jruby-openssl` gem.

## Usage

To post content to a flow's chat or team inbox using `Flowdock::Flow`, you need to use the target flow's API token or a source's flow_token.

Alternatively, you can use your personal API token and the `Flowdock::Client`.

Personal and flow's tokens can be found on the [tokens page](https://www.flowdock.com/account/tokens).

### REST API

To create an API client, you need your personal [API token](https://flowdock.com/account/tokens), an [OAuth token](https://www.flowdock.com/api/authentication) or a [source's flow_token](https://www.flowdock.com/api/sources).

Note that a `flow_token` will only allow you to post [thread messages](https://www.flowdock.com/api/production-integrations#/post-inbox) to the flow that the source belongs to.

```ruby
require 'rubygems'
require 'flowdock'

# Create a client that uses your personal API token to authenticate
api_token_client = Flowdock::Client.new(api_token: '__MY_PERSONAL_API_TOKEN__')

# Create a client that uses a source's flow_token to authenticate. Can only use post_to_thread
flow_token_client = Flowdock::Client.new(flow_token: '__FLOW_TOKEN__')
```

#### Posting to Chat

To send a chat message or comment, you can use `client.chat_message`:

```ruby
flow_id = 'acdcabbacd0123456789'

# Send a simple chat message
api_token_client.chat_message(flow: flow_id, content: "I'm sending a message!", tags: ['foo', 'bar'])

# Send a comment to message 1234
api_token_client.chat_message(flow: flow_id, content: "Now I'm commenting!", message: 1234)
```

Both methods return the created message as a hash.

#### Post a threaded messages

You can post `activity` and `discussion` events to a [threaded conversation](https://www.flowdock.com/api/integration-getting-started) in Flowdock.

```
flow_token_client.post_to_thread(
    event: "activity",
    author: {
        name: "anttipitkanen",
        avatar: "https://avatars.githubusercontent.com/u/946511?v=2",
    },
    title: "activity title",
    external_thread_id: "your-id-here",
    thread: {
        title: "this is required if you provide a thread field at all",
        body: "<p>some html content</p>",
        external_url: "https://example.com/issue/123",
        status: {
            color: "green",
            value: "open"
        }
    }
}
```


#### Arbitary API access

You can use the client to access the Flowdock API in other ways, too. See the [REST API documentation](http://www.flowdock.com/api/rest) for all the resources.

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

### Push API

**Note:** the Push API is in the process of being deprecated. [Creating a source](https://www.flowdock.com/api/integration-getting-started) along with a flow_token is recommended instead.

To use the Push API, you need the flow's API token:

#### Posting to the chat

```ruby
require 'rubygems'
require 'flowdock'

# create a new Flow object with target flow's API token and external user name (enough for posting to the chat)
flow = Flowdock::Flow.new(:api_token => "__FLOW_API_TOKEN__", :external_user_name => "John")

# send message to Chat
flow.push_to_chat(:content => "Hello!", :tags => ["cool", "stuff"])
```

#### Posting to the team inbox

```ruby
# create a new Flow object with the target flow's API token and sender information
flow = Flowdock::Flow.new(:api_token => "__FLOW_API_TOKEN__",
  :source => "myapp", :from => {:name => "John Doe", :address => "john.doe@example.com"})

# send message to Team Inbox
flow.push_to_team_inbox(:subject => "Greetings from the Flowdock API gem!",
  :content => "<h2>It works!</h2><p>Now you can start developing your awesome application for Flowdock.</p>",
  :tags => ["cool", "stuff"], :link => "http://www.flowdock.com/")
```

#### Posting to multiple flows

```ruby
require 'rubygems'
require 'flowdock'

# create a new Flow object with the API tokens of the target flows
flow = Flowdock::Flow.new(:api_token => ["__FLOW_API_TOKEN__", "__ANOTHER_FLOW_API_TOKEN__"], ... )

# see the above examples of posting to the chat or team inbox
```

## API methods

* `Flowdock::Flow` methods

  `push_to_team_inbox` - Send message to the team inbox. See [API documentation](http://www.flowdock.com/api/team-inbox) for details.

  `push_to_chat` - Send message to the chat. See [API documentation](http://www.flowdock.com/api/chat) for details.

  `send_message(params)` - Deprecated. Please use `push_to_team_inbox` instead.

* `Flowdock::Client` methods

  `chat_message` - Send message to chat.

  `post_to_thread` - Post messages to a team inbox thread.

  `post`, `get`, `put`, `delete` - Send arbitary api calls. First parameter is the path, second is data. See [REST API documentation](http://www.flowdock.com/api/rest).

## Deployment notifications

There are separate gems for deployment notifications:

* [capistrano-flowdock](https://github.com/flowdock/capistrano-flowdock)
* [mina-flowdock](https://github.com/elskwid/mina-flowdock)

## Changelog
* 0.7.0 - Added `post_to_thread`
* 0.5.0 - Added `Flowdock::Client` that authenticates using user credentials and can be used to interact with the API. Better threads support for both `Flow` and `Client` so that comments can be made.

## Copyright

Copyright (c) 2012 Flowdock Ltd. See LICENSE for further details.
