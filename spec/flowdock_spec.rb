require 'spec_helper'

describe Flowdock do
  describe "with initializing flow" do
    it "should succeed with correct token" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test")
      }.should_not raise_error
    end

    it "should fail without token" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "")
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end
  end

  describe "with sending Team Inbox messages" do
    before(:each) do
      @token = "test"
      @flow_attributes = {:api_token => @token, :source => "myapp", :project => "myproject",
       :from => {:name => "Eric Example", :address => "eric@example.com"}}
      @flow = Flowdock::Flow.new(@flow_attributes)
      @example_content = "<h1>Hello</h1>\n<p>Let's rock and roll!</p>"
      @valid_attributes = {:subject => "Hello World", :content => @example_content,
        :link => "http://www.flowdock.com/", :tags => ["cool", "stuff"]}
    end

    it "should not send without source" do
      lambda {
        @flow = Flowdock::Flow.new(@flow_attributes.merge(:source => ""))
        @flow.push_to_team_inbox(@valid_attributes)
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send when source is not alphanumeric" do
      lambda {
        @flow = Flowdock::Flow.new(@flow_attributes.merge(:source => "$foobar"))
        @flow.push_to_team_inbox(@valid_attributes)
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send when project is not alphanumeric" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp", :project => "$foobar")
        @flow.push_to_team_inbox(@valid_attributes)
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send without sender information" do
      lambda {
        @flow = Flowdock::Flow.new(@flow_attributes.merge(:from => nil))
        @flow.push_to_team_inbox(@valid_attributes)
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send without subject" do
      lambda {
        @flow.push_to_team_inbox(@valid_attributes.merge(:subject => ""))
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send without content" do
      lambda {
        @flow.push_to_team_inbox(@valid_attributes.merge(:content => ""))
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should succeed with correct token, source and sender information" do
      lambda {
        stub_request(:post, push_to_team_inbox_url(@token)).
          with(:body => {
            :source => "myapp",
            :format => "html",
            :from_name => "Eric Example",
            :from_address => "eric@example.com",
            :subject => "Hello World",
            :content => @example_content,
            :tags => "cool,stuff",
            :link => "http://www.flowdock.com/"
          }).
          to_return(:body => "", :status => 200)

        @flow = Flowdock::Flow.new(@flow_attributes.merge(:project => ""))
        @flow.push_to_team_inbox(@valid_attributes)
      }.should_not raise_error
    end

    it "should succeed without the optional from-name parameter" do
      lambda {
        stub_request(:post, push_to_team_inbox_url(@token)).
          with(:body => {
            :source => "myapp",
            :project => "myproject",
            :format => "html",
            :from_address => "eric@example.com",
            :subject => "Hello World",
            :content => @example_content,
            :tags => "cool,stuff",
            :link => "http://www.flowdock.com/"
          }).
          to_return(:body => "", :status => 200)
        @flow = Flowdock::Flow.new(@flow_attributes.merge(:from => {:address => "eric@example.com"}))
        @flow.push_to_team_inbox(@valid_attributes)
      }.should_not raise_error
    end

    it "should succeed with correct token, sender information, source and project" do
      lambda {
        stub_request(:post, push_to_team_inbox_url(@token)).
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
        @flow = Flowdock::Flow.new(@flow_attributes)
        @flow.push_to_team_inbox(@valid_attributes)
      }.should_not raise_error
    end

    it "should send with valid parameters and return true" do
      lambda {
        stub_request(:post, push_to_team_inbox_url(@token)).
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

        @flow.push_to_team_inbox(:subject => "Hello World", :content => @example_content,
          :tags => ["cool", "stuff"], :link => "http://www.flowdock.com/").should be_true
      }.should_not raise_error
    end

    it "should allow overriding sender information per message" do
      lambda {
        stub_request(:post, push_to_team_inbox_url(@token)).
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

        @flow.push_to_team_inbox(:subject => "Hello World", :content => @example_content, :tags => ["cool", "stuff"],
          :from => {:name => "Test", :address => "invalid@nodeta.fi"}).should be_true
      }.should_not raise_error
    end

    it "should raise error if backend returns anything but 200 OK" do
      lambda {
        stub_request(:post, push_to_team_inbox_url(@token)).
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

        @flow.push_to_team_inbox(:subject => "Hello World", :content => @example_content).should be_false
      }.should raise_error(Flowdock::Flow::ApiError)
    end
  end

  describe "with sending Chat messages" do
    before(:each) do
      @token = "test"
      @flow = Flowdock::Flow.new(:api_token => @token)
      @valid_parameters = {:external_user_name => "foobar", :content => "Hello", :tags => ["cool","stuff"]}
    end

    it "should not send without content" do
      lambda {
        @flow.push_to_chat(@valid_parameters.merge(:content => ""))
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send without external_user_name" do
      lambda {
        @flow.push_to_chat(@valid_parameters.merge(:external_user_name => ""))
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should not send with invalid external_user_name" do
      lambda {
        @flow.push_to_chat(@valid_parameters.merge(:external_user_name => "foo bar"))
      }.should raise_error(Flowdock::Flow::InvalidParameterError)
    end

    it "should send with valid parameters and return true" do
      lambda {
        stub_request(:post, push_to_chat_url(@token)).
          with(:body => @valid_parameters.merge(:tags => "cool,stuff")).
          to_return(:body => "", :status => 200)

        @flow.push_to_chat(@valid_parameters).should be_true
      }.should_not raise_error
    end

    it "should accept external_user_name in init" do
      lambda {
        stub_request(:post, push_to_chat_url(@token)).
          with(:body => @valid_parameters.merge(:tags => "cool,stuff", :external_user_name => "foobar2")).
          to_return(:body => "", :status => 200)

        @flow = Flowdock::Flow.new(:api_token => @token, :external_user_name => "foobar")
        @flow.push_to_chat(@valid_parameters.merge(:external_user_name => "foobar2"))
      }.should_not raise_error
    end

    it "should allow overriding external_user_name" do
      lambda {
        stub_request(:post, push_to_chat_url(@token)).
          with(:body => @valid_parameters.merge(:tags => "cool,stuff")).
          to_return(:body => "", :status => 200)

        @flow = Flowdock::Flow.new(:api_token => @token, :external_user_name => "foobar")
        @flow.push_to_chat(@valid_parameters.merge(:external_user_name => ""))
      }.should_not raise_error
    end

    it "should raise error if backend returns anything but 200 OK" do
      lambda {
        stub_request(:post, push_to_chat_url(@token)).
          with(:body => @valid_parameters.merge(:tags => "cool,stuff")).
          to_return(:body => '{"message":"Validation error","errors":{"content":["can\'t be blank"],"external_user_name":["should not contain whitespace"]}}',
            :status => 400)

        @flow.push_to_chat(@valid_parameters).should be_false
      }.should raise_error(Flowdock::Flow::ApiError)
    end
  end

  def push_to_chat_url(token)
    "#{Flowdock::FLOWDOCK_API_URL}/messages/chat/#{token}"
  end

  def push_to_team_inbox_url(token)
    "#{Flowdock::FLOWDOCK_API_URL}/messages/team_inbox/#{token}"
  end
end
