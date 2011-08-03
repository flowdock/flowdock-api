require 'rubygems'
require 'httparty'

module Flowdock
  FLOWDOCK_API_URL = "http://api.local.nodeta.dmz/v1/messages/influx"

  class Flow
    include HTTParty
    class ApiTokenMissingError < StandardError; end
    class InvalidSourceError < StandardError; end
    class InvalidSenderInformationError < StandardError; end
    class InvalidMessageError < StandardError; end

    # Required options keys: :api_token, :source, :from => { :name, :address }
    def initialize(options = {})
      @api_token = options[:api_token]
      raise ApiTokenMissingError, "Flow must have :api_token attribute" if @api_token.blank?
      
      @source = options[:source]
      raise InvalidSourceError, "Flow must have valid :source attribute, only alphanumeric characters and underscores can be used" if @source.blank? || !@source.match(/^\w+$/i)

      @from = options[:from] || {}
    end

    def send_message(params)
      raise InvalidMessageError, "Message must have both :subject and :content" if params[:subject].blank? || params[:content].blank?
      
      from = (params[:from].kind_of?(Hash)) ? params[:from] : @from
      raise InvalidSenderInformationError, "Flow's :from attribute must have both :name and :address" if from[:name].blank? || from[:address].blank?

      tags = (params[:tags].kind_of?(Array)) ? params[:tags] : []
      tags.reject! { |tag| !tag.kind_of?(String) || tag.blank? }

      params = {
        :source => @source,
        :format => 'html', # currently only supported format
        :from_name => from[:name],
        :from_address => from[:address],
        :subject => params[:subject],
        :content => params[:content]
      }
      params[:tags] = tags.join(",") if tags.size > 0

      # Send the request
      resp = self.class.post(get_flowdock_api_url, :body => params)

      resp.code == 200
    end
  
    private
  
    def get_flowdock_api_url
      "#{FLOWDOCK_API_URL}/#{@api_token}"
    end
  end
end
