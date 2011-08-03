require 'spec_helper'

describe Flowdock do
  describe "with initializing flow" do
    it "should succeed with correct token and sender information" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp", 
          :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should_not raise_error
    end
  
    it "should fail without token" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "", :source => "myapp", 
          :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should raise_error(Flowdock::Flow::ApiTokenMissingError)
    end
  
    it "should fail without source" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "",
         :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should raise_error(Flowdock::Flow::InvalidSourceError)
    end
  
    it "should fail when source is not alphanumeric" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "$foobar",
         :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should raise_error(Flowdock::Flow::InvalidSourceError)
    end
  
    it "should fail without sender information" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp",
         :from => {:name => "", :address => "invalid@nodeta.fi"})
      }.should raise_error(Flowdock::Flow::InvalidSenderInformationError)
    
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp",
         :from => {:name => "test", :address => ""})
      }.should raise_error(Flowdock::Flow::InvalidSenderInformationError)
    end
  end
  
  describe "with sending messages" do
    before(:each) do
      @token = "test"
      @flow = Flowdock::Flow.new(:api_token => @token, :source => "myapp",
       :from => {:name => "Eric Example", :address => "eric@example.com"})
      @example_content = "<h1>Hello</h1>\n<p>Let's rock and roll!</p>"
    end
    
    it "should not send without subject" do
      lambda {
        @flow.send_message(:subject => "", :content => "Test")
      }.should raise_error(Flowdock::Flow::InvalidMessageError)
    end
    
    it "should not send without content" do
      lambda {
        @flow.send_message(:subject => "Test", :content => "")
      }.should raise_error(Flowdock::Flow::InvalidMessageError)
    end
    
    it "should send with valid parameters and return true" do
      lambda {
        stub_request(:post, "#{Flowdock::FLOWDOCK_API_URL}/#{@token}").
          with(:body => {
            :source => "myapp",
            :format => "html",
            :from_name => "Eric Example",
            :from_address => "eric@example.com",
            :subject => "Hello World",
            :content => @example_content,
            :tags => "cool,stuff"
          }).
          to_return(:body => "", :status => 200)

        @flow.send_message(:subject => "Hello World", :content => @example_content, :tags => ["cool", "stuff"]).should be_true
      }.should_not raise_error
    end
    
    it "should return false if backend returns anything but 200 OK" do
      lambda {
        stub_request(:post, "#{Flowdock::FLOWDOCK_API_URL}/#{@token}").
          with(:body => {
            :source => "myapp",
            :format => "html",
            :from_name => "Eric Example",
            :from_address => "eric@example.com",
            :subject => "Hello World",
            :content => @example_content
          }).
          to_return(:body => "Internal Server Error", :status => 500)

        @flow.send_message(:subject => "Hello World", :content => @example_content).should be_false
      }.should_not raise_error
    end
  end
end
