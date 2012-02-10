# Flowdock

Ruby Gem for using the Flowdock API.

http://www.flowdock.com/api

## Build Status

[![Build Status](https://secure.travis-ci.org/flowdock/flowdock-api.png)](http://travis-ci.org/flowdock/flowdock-api)

flowdock gem is tested on Ruby 1.8.7, 1.9.3 and JRuby.

## Requirements

* HTTParty

## Installing

    gem install flowdock

If you're using JRuby, you'll also need to install jruby-openssl gem.

## Example

    require 'rubygems'
    require 'flowdock'

    # create a new Flow object with target flow's api token and sender information
    flow = Flowdock::Flow.new(:api_token => "56188e2003e370c6efa9711988f7bf02",
      :source => "myapp",
      :from => {:name => "John Doe", :address => "john.doe@example.com"})

    # send message to the flow
    flow.send_message(:subject => "Greetings from Flowdock API Gem!",
      :content => "<h2>It works!</h2><p>Now you can start developing your awesome application for Flowdock.</p>",
      :tags => ["cool", "stuff"], :link => "http://www.flowdock.com/")

## API methods

* Flow methods

  *send_message(params)* - Send message to flow. See [API documentation](http://www.flowdock.com/help/api_documentation) for details.


## Capistrano deployment task

The Flowdock API Ruby Gem includes a ready task for sending deployment notifications with Capistrano (you need to have Grit installed too). Just add the task into your deploy.rb file and configure the settings to match your project and flow:

```
 require 'flowdock/capistrano'

 # for Flowdock Gem notifications
 set :flowdock_project_name, "My project"
 set :flowdock_deploy_tags, ["frontend"]
 set :flowdock_api_token, "_YOUR_API_TOKEN_HERE_"
```


## Copyright

Copyright (c) 2011 Flowdock Ltd. See MIT-LICENSE for further details.
