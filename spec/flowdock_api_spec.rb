require 'spec_helper'
require 'fakeweb'

describe Flowdock do
  
  describe "with initializing flow" do
    it "should succeed with correct token and sender information" do
      lambda {
        @flow = Flowdock.new(:api_token => "test", :source => "myapp", 
          :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should_not raise_error
    end
  
    it "should fail without token" do
      lambda {
        @flow = Flowdock.new(:api_token => "", :source => "myapp", 
          :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should raise_error(Flowdock::Flow::ApiTokenMissingError)
    end
  
    it "should fail without source" do
      lambda {
        @flow = Flowdock.new(:api_token => "test", :source => "",
         :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should raise_error(Flowdock::Flow::InvalidSourceError)
    end
  
    it "should fail when source is not alphanumeric" do
      lambda {
        @flow = Flowdock.new(:api_token => "test", :source => "$foobar",
         :from => {:name => "test", :address => "invalid@nodeta.fi"})
      }.should raise_error(Flowdock::Flow::InvalidSourceError)
    end
  
    it "should fail without sender information" do
      lambda {
        @flow = Flowdock.new(:api_token => "test", :source => "myapp",
         :from => {:name => "", :address => "invalid@nodeta.fi"})
      }.should raise_error(Flowdock::Flow::InvalidSenderInformationError)
    
      lambda {
        @flow = Flowdock.new(:api_token => "test", :source => "myapp",
         :from => {:name => "test", :address => ""})
      }.should raise_error(Flowdock::Flow::InvalidSenderInformationError)
    end
  end
  
  describe "with sending messages" do
    before(:each) do
      FakeWeb.allow_net_connect = false
      FakeWeb.clean_registry
      @token = "test"
      @flow = Flowdock.new(:api_token => @token, :source => "myapp",
       :from => {:name => "test", :address => "invalid@nodeta.fi"})
    end
    
    it "should not send without subject" do
      lambda {
        @flow.send_message(:subject => "", :content => "Test", :format => "html")
      }.should raise_error(Flowdock::Flow::InvalidMessageError)
    end
    
    it "should not send without content" do
      lambda {
        @flow.send_message(:subject => "Test", :content => "", :format => "html")
      }.should raise_error(Flowdock::Flow::InvalidMessageError)
    end
    
    it "should not send without correct format" do
      lambda {
        @flow.send_message(:subject => "Testing", :content => "Test", :format => "")
      }.should raise_error(Flowdock::Flow::InvalidMessageError)
    end
    
    it "should send with valid parameters and return true" do
      lambda {
        FakeWeb.register_uri(:post,
                             "#{Flowdock::FLOWDOCK_API_URL}/#{@token}",
                             :status => ["200", "OK"], :body => "")
        @flow.send_message(:subject => "Test", :content => "Test", :format => "html", :tags => ["cool", "stuff"]).should be_true
      }.should_not raise_error
    end
    
    it "should return false if backend returns anything but 200 OK" do
      lambda {
        FakeWeb.register_uri(:post,
                             "#{Flowdock::FLOWDOCK_API_URL}/#{@token}",
                             :status => ["500", "Internal Server Error"], :body => "")
        @flow.send_message(:subject => "Test", :content => "Test", :format => "html", :tags => ["cool", "stuff"]).should be_false
      }.should_not raise_error
    end
    
    after(:each) do
      FakeWeb.allow_net_connect = true
    end
  end
  
end