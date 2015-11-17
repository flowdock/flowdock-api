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
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should succeed with array of tokens" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => ["test", "foobar"])
      }.should_not raise_error
    end
  end

  describe "handle_response" do
    it "parses a response body that contains an empty string" do
      class TestResponse
        attr_reader :body, :code

        def initialize
          @body = ""
          @code = 200
        end
      end

      class TestHelper
        include Flowdock::Helpers
      end

      expect(TestHelper.new.handle_response(TestResponse.new)).to eq({})
    end
  end

  describe "with sending Team Inbox messages" do
    before(:each) do
      @token = "test"
      @flow_attributes = {:api_token => @token, :source => "myapp", :project => "myproject",
       :from => {:name => "Eric Example", :address => "eric@example.com"}, :reply_to => "john@example.com" }
      @flow = Flowdock::Flow.new(@flow_attributes)
      @example_content = "<h1>Hello</h1>\n<p>Let's rock and roll!</p>"
      @valid_attributes = {:subject => "Hello World", :content => @example_content,
        :link => "http://www.flowdock.com/", :tags => ["cool", "stuff"]}
    end

    it "should not send without source" do
      lambda {
        @flow = Flowdock::Flow.new(@flow_attributes.merge(:source => ""))
        @flow.push_to_team_inbox(@valid_attributes)
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should not send when source is not alphanumeric" do
      lambda {
        @flow = Flowdock::Flow.new(@flow_attributes.merge(:source => "$foobar"))
        @flow.push_to_team_inbox(@valid_attributes)
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should not send when project is not alphanumeric" do
      lambda {
        @flow = Flowdock::Flow.new(:api_token => "test", :source => "myapp", :project => "$foobar")
        @flow.push_to_team_inbox(@valid_attributes)
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should not send without sender information" do
      lambda {
        @flow = Flowdock::Flow.new(@flow_attributes.merge(:from => nil))
        @flow.push_to_team_inbox(@valid_attributes)
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should not send without subject" do
      lambda {
        @flow.push_to_team_inbox(@valid_attributes.merge(:subject => ""))
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should not send without content" do
      lambda {
        @flow.push_to_team_inbox(@valid_attributes.merge(:content => ""))
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should send without reply_to address" do
      expect {
        stub_request(:post, push_to_team_inbox_url(@token)).to_return(:body => "", :status => 200)
        @flow.push_to_team_inbox(@valid_attributes.merge(:reply_to => ""))
      }.not_to raise_error
    end

    it "should succeed with correct token, source and sender information" do
      lambda {
        stub_request(:post, push_to_team_inbox_url(@token)).
          with(:body => {
            :source => "myapp",
            :format => "html",
            :from_name => "Eric Example",
            :from_address => "eric@example.com",
            :reply_to => "john@example.com",
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

    it "should succeed with correct params and multiple tokens" do
      lambda {
        tokens = ["test", "foobar"]
        stub_request(:post, push_to_team_inbox_url(tokens)).
          with(:body => {
            :source => "myapp",
            :format => "html",
            :from_name => "Eric Example",
            :from_address => "eric@example.com",
            :reply_to => "john@example.com",
            :subject => "Hello World",
            :content => @example_content,
            :tags => "cool,stuff",
            :link => "http://www.flowdock.com/"
          }).
          to_return(:body => "", :status => 200)

        @flow = Flowdock::Flow.new(@flow_attributes.merge(:project => "", :api_token => tokens))
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
            :reply_to => "john@example.com",
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
            :reply_to => "john@example.com",
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
            :reply_to => "john@example.com",
            :subject => "Hello World",
            :content => @example_content,
            :tags => "cool,stuff",
            :link => "http://www.flowdock.com/"
          }).
          to_return(:body => "", :status => 200)

        @flow.push_to_team_inbox(:subject => "Hello World", :content => @example_content,
          :tags => ["cool", "stuff"], :link => "http://www.flowdock.com/").should be_truthy
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
            :reply_to => "foobar@example.com",
            :subject => "Hello World",
            :content => @example_content,
            :tags => "cool,stuff",
          }).
          to_return(:body => "", :status => 200)

        @flow.push_to_team_inbox(:subject => "Hello World", :content => @example_content, :tags => ["cool", "stuff"],
          :from => {:name => "Test", :address => "invalid@nodeta.fi"}, :reply_to => "foobar@example.com").should be_truthy
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
            :reply_to => "john@example.com",
            :subject => "Hello World",
            :content => @example_content
          }).
          to_return(:body => "Internal Server Error", :status => 500)

        @flow.push_to_team_inbox(:subject => "Hello World", :content => @example_content).should be_false
      }.should raise_error(Flowdock::ApiError)
    end

    it "should raise error if backend returns 404 NotFound" do
      lambda {
        stub_request(:post, push_to_team_inbox_url(@token)).
          with(:body => {
            :source => "myapp",
            :project => "myproject",
            :format => "html",
            :from_name => "Eric Example",
            :from_address => "eric@example.com",
            :reply_to => "john@example.com",
            :subject => "Hello World",
            :content => @example_content
          }).
          to_return(:body => "{}", :status => 404)

        @flow.push_to_team_inbox(:subject => "Hello World", :content => @example_content).should be_false
      }.should raise_error(Flowdock::NotFoundError)
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
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should not send without external_user_name" do
      lambda {
        @flow.push_to_chat(@valid_parameters.merge(:external_user_name => ""))
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should not send with invalid external_user_name" do
      lambda {
        @flow.push_to_chat(@valid_parameters.merge(:external_user_name => "foo bar"))
      }.should raise_error(Flowdock::InvalidParameterError)
    end

    it "should send with valid parameters and return true" do
      lambda {
        stub_request(:post, push_to_chat_url(@token)).
          with(:body => @valid_parameters.merge(:tags => "cool,stuff")).
          to_return(:body => "", :status => 200)

        @flow.push_to_chat(@valid_parameters).should be_truthy
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
      }.should raise_error(Flowdock::ApiError)
    end

    it "should send supplied message to create comments" do
      lambda {
        stub_request(:post, push_to_chat_url(@token)).
          with(:body => /message_id=12345/).
          to_return(:body => "", :status => 200)

        @flow = Flowdock::Flow.new(:api_token => @token, :external_user_name => "foobar")
        @flow.push_to_chat(@valid_parameters.merge(:message_id => 12345))
      }.should_not raise_error
    end

    it "should send supplied thread_id to post to threads" do
      lambda {
        stub_request(:post, push_to_chat_url(@token)).
          with(:body => /thread_id=acdcabbacd/).
          to_return(:body => "", :status => 200)

        @flow = Flowdock::Flow.new(:api_token => @token, :external_user_name => "foobar")
        @flow.push_to_chat(@valid_parameters.merge(:thread_id => 'acdcabbacd'))
      }.should_not raise_error
    end
  end

  def push_to_chat_url(token)
    "#{Flowdock::FLOWDOCK_API_URL}/messages/chat/#{join_tokens(token)}"
  end

  def push_to_team_inbox_url(token)
    "#{Flowdock::FLOWDOCK_API_URL}/messages/team_inbox/#{join_tokens(token)}"
  end

  def join_tokens(tokens)
    if tokens.kind_of?(Array)
      tokens.join(",")
    else
      tokens.to_s
    end
  end
end

describe Flowdock::Client do

  context "with flow_token" do
    let(:token) { SecureRandom.hex }
    let(:client) { Flowdock::Client.new(flow_token: token) }
    let(:flow) { SecureRandom.hex }

    describe "post a threaded message" do
      it "succeeds" do
        stub_request(:post, "https://api.flowdock.com/v1/messages").
          with(body: MultiJson.dump(flow: flow, flow_token: token),
               headers: {"Accept" => "application/json", "Content-Type" => "application/json"}).
          to_return(status: 201, body: '{"id":123}', headers: {"Content-Type" => "application/json"})
        res = client.post_to_thread({flow: flow})
        expect(res).to eq({"id" => 123})
      end
    end
  end

  context "with api_token" do
    let(:token) { SecureRandom.hex(8) }
    let(:client) { Flowdock::Client.new(api_token: token) }

    describe 'initializing' do

      it 'should initialize with access token' do
        expect {
          client = Flowdock::Client.new(api_token: token)
          expect(client.api_token).to equal(token)
        }.not_to raise_error
      end
      it 'should raise error if initialized without access token' do
        expect {
          client = Flowdock::Client.new(api_token: nil)
        }.to raise_error(Flowdock::InvalidParameterError)
      end
    end

    describe 'posting to chat' do

      let(:flow) { SecureRandom.hex(8) }

      it 'posts to /messages' do
        expect {
          stub_request(:post, "https://#{token}:@api.flowdock.com/v1/messages").
            with(:body => MultiJson.dump(flow: flow, content: "foobar", tags: [], event: "message"), :headers => {"Accept" => "application/json", "Content-Type" => "application/json"}).
            to_return(:status => 201, :body => '{"id":123}', :headers => {"Content-Type" => "application/json"})
          res = client.chat_message(flow: flow, content: 'foobar')
          expect(res).to eq({"id" => 123})
        }.not_to raise_error
      end
      it 'posts to /comments' do
        expect {
          stub_request(:post, "https://#{token}:@api.flowdock.com/v1/comments").
            with(:body => MultiJson.dump(flow: flow, content: "foobar", message: 12345, tags: [], event: "comment"), :headers => {"Accept" => "application/json", "Content-Type" => "application/json"}).
            to_return(:status => 201, :body => '{"id":1234}', :headers => {"Content-Type" => "application/json"})
          res = client.chat_message(flow: flow, content: 'foobar', message: 12345)
          expect(res).to eq({"id" => 1234})
        }.not_to raise_error
      end
      it 'posts to /private/:user_id/messages' do
        expect {
          stub_request(:post, "https://#{token}:@api.flowdock.com/v1/private/12345/messages").
            with(:body => MultiJson.dump(content: "foobar", event: "message"), :headers => {"Accept" => "application/json", "Content-Type" => "application/json"}).
            to_return(:status => 201, :body => '{"id":1234}', :headers => {"Content-Type" => "application/json"})
          res = client.private_message(user_id: "12345", content: 'foobar')
          expect(res).to eq({"id" => 1234})
        }.not_to raise_error
      end

      it 'raises without flow' do
        expect {
          client.chat_message(content: 'foobar')
        }.to raise_error(Flowdock::InvalidParameterError)
      end
      it 'raises without content' do
        expect {
          client.chat_message(flow: flow)
        }.to raise_error(Flowdock::InvalidParameterError)
      end
      it 'handles error responses' do
        expect {
          stub_request(:post, "https://#{token}:@api.flowdock.com/v1/messages").
            to_return(:body => '{"message":"Validation error","errors":{"content":["can\'t be blank"],"external_user_name":["should not contain whitespace"]}}',
                      :status => 400)
          client.chat_message(flow: flow, content: 'foobar')
        }.to raise_error(Flowdock::ApiError)
      end
    end

    describe 'GET' do
      it 'does abstract get with params' do
        stub_request(:get, "https://#{token}:@api.flowdock.com/v1/some_path?sort_by=date").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => '{"id": 123}', :headers => {"Content-Type" => "application/json"})
        expect(client.get('/some_path', {sort_by: 'date'})).to eq({"id" => 123})
      end
    end

    describe 'POST' do
      it 'does abstract post with body' do
        stub_request(:post, "https://#{token}:@api.flowdock.com/v1/other_path").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}, :body => MultiJson.dump(name: 'foobar')).
          to_return(:status => 200, :body => '{"id": 123,"name": "foobar"}', :headers => {"Content-Type" => "application/json"})
        expect(client.post('other_path', {name: 'foobar'})).to eq({"id" => 123, "name" => "foobar"})
      end

    end

    describe 'PUT' do
      it 'does abstract put with body' do
        stub_request(:put, "https://#{token}:@api.flowdock.com/v1/other_path").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}, :body => MultiJson.dump(name: 'foobar')).
          to_return(:status => 200, :body => '{"id": 123,"name": "foobar"}', :headers => {"Content-Type" => "application/json"})
        expect(client.put('other_path', {name: 'foobar'})).to eq({"id" => 123, "name" => "foobar"})
      end
    end

    describe 'DELETE' do
      it 'does abstract delete with params' do
        stub_request(:delete, "https://#{token}:@api.flowdock.com/v1/some_path").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => '', :headers => {"Content-Type" => "application/json"})
        expect(client.delete('/some_path')).to eq({})
      end
    end
  end
end
