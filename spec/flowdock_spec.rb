require 'spec_helper'

describe Flowdock do
  describe "with initializing flow" do
    it "should succeed with correct token and source" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp")
      }.should_not raise_error
    end

    it "should succeed with correct token, source and sender information" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp",
          :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should_not raise_error
    end

    it "should succeed with correct token, sender information, source and project" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp", :project => "myproject",
          :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should_not raise_error
    end

    it "should succeed without the optional from-name parameter" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp",
          :from => {:address => "invalid@nodeta.fi"})
      }.should_not raise_error
    end

    it "should fail without token" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "", :source => "myapp")
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should fail without source" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "")
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should fail when source is not alphanumeric" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "$foobar")
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should fail when project is not alphanumeric" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp", :project => "$foobar")
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end
  end

  describe "with sending messages" do
    before(:each) do
      @token = "test"
      @flow = Flowdock::Flow.new(:api_token => @token, :source => "myapp", :project => "myproject",
       :from => {:name => "Eric Example", :address => "eric@example.com"})
      @example_content = "<h1>Hello</h1>\n<p>Let's rock and roll!</p>"
    end

    it "should not send without subject" do
      lambda {
        @flow.send_message(:subject => "", :content => "Test")
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send without content" do
      lambda {
        @flow.send_message(:subject => "Test", :content => "")
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send without sender information" do
      @flow = Flowdock::Flow.new(:api_token => @token, :source => "myapp")
      lambda {
        @flow.send_message(:subject => "Test", :content => @example_content)
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should send with valid parameters and return true" do
      lambda {
        stub_request(:post, "#{Flowdock::FLOWDOCK_API_URL}/#{@token}").
          with(:body => {
            :source => "myapp",
            :project => "myproject",
            :format => "html",
            :from_name => "Eric Example",
            :from_address => "eric@example.com",
            :subject => "Hello World",
            :content => @example_content,
            :tags => "cool,stuff",
            :link => "http://www.flowdock.com/"
          }).
          to_return(:body => "", :status => 200)

        @flow.send_message(:subject => "Hello World", :content => @example_content, 
          :tags => ["cool", "stuff"], :link => "http://www.flowdock.com/").should be_true
      }.should_not raise_error
    end

    it "should allow overriding sender information per message" do
      lambda {
        stub_request(:post, "#{Flowdock::FLOWDOCK_API_URL}/#{@token}").
          with(:body => {
            :source => "myapp",
            :project => "myproject",
            :format => "html",
            :from_name => "Test",
            :from_address => "invalid@nodeta.fi",
            :subject => "Hello World",
            :content => @example_content,
            :tags => "cool,stuff",
          }).
          to_return(:body => "", :status => 200)

        @flow.send_message(:subject => "Hello World", :content => @example_content, :tags => ["cool", "stuff"],
          :from => {:name => "Test", :address => "invalid@nodeta.fi"}).should be_true
      }.should_not raise_error
    end

    it "should raise error if backend returns anything but 200 OK" do
      lambda {
        stub_request(:post, "#{Flowdock::FLOWDOCK_API_URL}/#{@token}").
          with(:body => {
            :source => "myapp",
            :project => "myproject",
            :format => "html",
            :from_name => "Eric Example",
            :from_address => "eric@example.com",
            :subject => "Hello World",
            :content => @example_content
          }).
          to_return(:body => "Internal Server Error", :status => 500)

        @flow.send_message(:subject => "Hello World", :content => @example_content).should be_false
      }.should raise_error(Flowdock::Flow::ApiError)
    end
  end
end
