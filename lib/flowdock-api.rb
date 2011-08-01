require 'rubygems'
require 'httparty'

module FlowdockApi
  FLOWDOCK_API_URL = "http://api.local.nodeta.dmz/v1/messages/influx"

  class << self
    def new(options={})
      Flow.new(options[:api_token], options[:source], options[:from])
    end
  end

  class Flow
    include HTTParty
    class ApiTokenMissingError < StandardError; end
    class InvalidSourceError < StandardError; end
    class InvalidSenderInformationError < StandardError; end
    class InvalidMessageError < StandardError; end

    def initialize(api_token, source, from)
      raise ApiTokenMissingError, "Flow must have :api_token attribute" if api_token.blank?
      @api_token = api_token
      
      raise InvalidSourceError, "Flow must have valid :source attribute, only alphanumeric characters and underscores can be used" if source.blank? || !source.match(/^\w+$/i)
      @source = source

      raise InvalidSenderInformationError, "Flow must have :from attribute" if from.nil? || !from.kind_of?(Hash)
      from.reject! { |k,v| ![:name, :address].include?(k) }
      raise InvalidSenderInformationError, "Flow's :from attribute must have both :name and :address" if from[:name].blank? || from[:address].blank?
      @from = from
    end

    def send_message(params)
      raise InvalidMessageError, "Message must have both :subject and :content" if params[:subject].blank? || params[:content].blank?
      raise InvalidMessageError, "Message must have :format with one of following values: html" if params[:format].blank? || !["html"].include?(params[:format])

      tags = (params[:tags].kind_of?(Array)) ? params[:tags] : []
      tags.reject! { |tag| !tag.kind_of?(String) || tag.blank? }
      
      resp = self.class.post(get_flowdock_api_url, :body => {
          :source => @source,
          :format => params[:format],
          :from_name => @from[:name],
          :from_address => @from[:address],
          :subject => params[:subject],
          :content => params[:content],
          :tags => tags.join(",")
        }
      )
      resp.code == 200
    end
  
    private
  
    def get_flowdock_api_url
      "#{FLOWDOCK_API_URL}/#{@api_token}"
    end
  end
end
