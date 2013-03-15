require 'rubygems'
require 'httparty'
require 'multi_json'

module Flowdock
  FLOWDOCK_API_URL = "https://api.flowdock.com/v1"

  class Flow
    include HTTParty
    class InvalidParameterError < StandardError; end
    class ApiError < StandardError; end

    attr_reader :api_token, :source, :project, :from, :external_user_name

    # Required options keys: :api_token
    # Optional keys: :external_user_name, :source, :project, :from => { :name, :address }, :reply_to
    def initialize(options = {})
      @api_token = if options[:api_token].kind_of?(Array)
        options[:api_token].join(",")
      else
        options[:api_token].to_s
      end
      raise InvalidParameterError, "Flow must have :api_token attribute" if blank?(@api_token)

      @source = options[:source] || nil
      @project = options[:project] || nil
      @from = options[:from] || {}
      @reply_to = options[:reply_to] || nil
      @external_user_name = options[:external_user_name] || nil
    end

    def push_to_team_inbox(params)
      @source = params[:source] unless blank?(params[:source])
      raise InvalidParameterError, "Message must have valid :source attribute, only alphanumeric characters and underscores can be used" if blank?(@source) || !@source.match(/^[a-z0-9\-_ ]+$/i)

      @project = params[:project] unless blank?(params[:project])
      raise InvalidParameterError, "Optional attribute :project can only contain alphanumeric characters and underscores" if !blank?(@project) && !@project.match(/^[a-z0-9\-_ ]+$/i)

      raise InvalidParameterError, "Message must have both :subject and :content" if blank?(params[:subject]) || blank?(params[:content])

      from = (params[:from].kind_of?(Hash)) ? params[:from] : @from
      raise InvalidParameterError, "Message's :from attribute must have :address attribute" if blank?(from[:address])

      reply_to = (!blank?(params[:reply_to])) ? params[:reply_to] : @reply_to

      tags = (params[:tags].kind_of?(Array)) ? params[:tags] : []
      tags.reject! { |tag| !tag.kind_of?(String) || blank?(tag) }

      link = (!blank?(params[:link])) ? params[:link] : nil

      params = {
        :source => @source,
        :format => 'html', # currently only supported format
        :from_address => from[:address],
        :subject => params[:subject],
        :content => params[:content],
      }
      params[:from_name] = from[:name] unless blank?(from[:name])
      params[:reply_to] = reply_to unless blank?(reply_to)
      params[:tags] = tags.join(",") if tags.size > 0
      params[:project] = @project unless blank?(@project)
      params[:link] = link unless blank?(link)

      # Send the request
      resp = self.class.post(get_flowdock_api_url("messages/team_inbox"), :body => params)
      handle_response(resp)
      true
    end

    def push_to_chat(params)
      raise InvalidParameterError, "Message must have :content" if blank?(params[:content])

      @external_user_name = params[:external_user_name] unless blank?(params[:external_user_name])
      if blank?(@external_user_name) || @external_user_name.match(/^[\S]+$/).nil? || @external_user_name.length > 16
        raise InvalidParameterError, "Message must have :external_user_name that has no whitespace and maximum of 16 characters"
      end

      tags = (params[:tags].kind_of?(Array)) ? params[:tags] : []
      tags.reject! { |tag| !tag.kind_of?(String) || blank?(tag) }

      params = {
        :content => params[:content],
        :external_user_name => @external_user_name
      }
      params[:tags] = tags.join(",") if tags.size > 0

      # Send the request
      resp = self.class.post(get_flowdock_api_url("messages/chat"), :body => params)
      handle_response(resp)
      true
    end

    # <b>DEPRECATED:</b> Please use <tt>useful</tt> instead.
    def send_message(params)
      warn "[DEPRECATION] `send_message` is deprecated.  Please use `push_to_team_inbox` instead."
      push_to_team_inbox(params)
    end

    private

    def blank?(var)
      var.nil? || var.respond_to?(:length) && var.length == 0
    end

    def handle_response(resp)
      unless resp.code == 200
        begin
          # should have JSON response
          json = MultiJson.decode(resp.body)
          errors = json["errors"].map {|k,v| "#{k}: #{v.join(',')}"}.join("\n") unless json["errors"].nil?
          raise ApiError, "Flowdock API returned error:\nStatus: #{resp.code}\n Message: #{json["message"]}\n Errors:\n#{errors}"
        rescue MultiJson::DecodeError
          raise ApiError, "Flowdock API returned error:\nStatus: #{resp.code}\nBody: #{resp.body}"
        end
      end
    end

    def get_flowdock_api_url(path)
      "#{FLOWDOCK_API_URL}/#{path}/#{@api_token}"
    end
  end
end
