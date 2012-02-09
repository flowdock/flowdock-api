require 'rubygems'
require 'httparty'

module Flowdock
  FLOWDOCK_API_URL = "https://api.flowdock.com/v1/messages/influx"

  class Flow
    include HTTParty
    class InvalidParameterError < StandardError; end
    class ApiError < StandardError; end

    # Required options keys: :api_token, :source, :from => { :name, :address }
    def initialize(options = {})
      @api_token = options[:api_token]
      raise InvalidParameterError, "Flow must have :api_token attribute" if blank?(@api_token)

      @source = options[:source]
      raise InvalidParameterError, "Flow must have valid :source attribute, only alphanumeric characters and underscores can be used" if blank?(@source) || !@source.match(/^[a-z0-9\-_ ]+$/i)

      @project = options[:project]
      raise InvalidParameterError, "Optional attribute :project can only contain alphanumeric characters and underscores" if !blank?(@project) && !@project.match(/^[a-z0-9\-_ ]+$/i)

      @from = options[:from] || {}
    end

    def send_message(params)
      raise InvalidParameterError, "Message must have both :subject and :content" if blank?(params[:subject]) || blank?(params[:content])

      from = (params[:from].kind_of?(Hash)) ? params[:from] : @from
      raise InvalidParameterError, "Flow's :from attribute must have :address attribute" if blank?(from[:address])

      tags = (params[:tags].kind_of?(Array)) ? params[:tags] : []
      tags.reject! { |tag| !tag.kind_of?(String) || blank?(tag) }

      link = (!blank?(params[:link])) ? params[:link] : nil

      params = {
        :source => @source,
        :format => 'html', # currently only supported format
        :from_name => from[:name],
        :from_address => from[:address],
        :subject => params[:subject],
        :content => params[:content],
      }
      params[:tags] = tags.join(",") if tags.size > 0
      params[:project] = @project unless blank?(@project)
      params[:link] = link unless blank?(link)

      # Send the request
      resp = self.class.post(get_flowdock_api_url, :body => params)
      raise ApiError, "Flowdock API returned error: Status: #{resp.code} Body: #{resp.body}" unless resp.code == 200
      true
    end

    private

    def blank?(var)
      var.nil? || var.respond_to?(:length) && var.length == 0
    end

    def get_flowdock_api_url
      "#{FLOWDOCK_API_URL}/#{@api_token}"
    end
  end
end
