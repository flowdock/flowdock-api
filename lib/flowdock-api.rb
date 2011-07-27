require 'rubygems'
require 'httparty'

module Flowdock
  FLOWDOCK_API_URL = "http://api.local.nodeta.dmz/v1/influx"

  class << self
    def new(options={})
      Flow.new(options[:api_token], options[:source], options[:from])
    end
  end

  class Flow
    include HTTParty
    class ApiTokenMissingError < StandardError; end
    class SourceMissingError < StandardError; end
    class InvalidSenderInformationError < StandardError; end
    class InvalidMessageError < StandardError; end

    def initialize(api_token, source, from)
      raise ApiTokenMissingError if api_token.blank?
      @api_token = api_token
      
      raise SourceMissingError if source.blank?
      @source = source

      raise InvalidSenderInformationError if from.nil? || !from.kind_of?(Hash)
      from.reject! { |k,v| ![:name, :address].include?(k) }
      raise InvalidSenderInformationError if from[:name].blank? || from[:address].blank?
      @from = from
    end

    def send_message(params)
      raise InvalidMessageError if params[:subject].blank? || params[:content].blank?

      tags = (params[:tags].kind_of?(Array)) ? params[:tags] : []
      tags.reject! { |tag| !tag.kind_of?(String) || tag.blank? }
      
      resp = self.class.post(get_flowdock_api_url_for("send_message"), :body => {
          :source => @source,
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
  
    def get_flowdock_api_url_for(method)
      "#{FLOWDOCK_API_URL}/#{@api_token}/#{method}"
    end
  end
end
