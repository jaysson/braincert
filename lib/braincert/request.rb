require 'httparty'
require 'net_http_exception_fix'
require 'active_model'

module Braincert

  @@site = 'https://api.braincert.com/v1'
  @@api_key = ''
  
  def self.api_key=(key) ; @@api_key = key ; end
  def self.api_key ; @@api_key ; end
  def self.site=(site);    @@site = site.gsub(/\/$/,'')   ; end # remove trailing slash
  def self.site ; @@site ; end


  module Request
    extend ActiveSupport::Concern # needed since Serializers module expects to use class_method
    include ActiveModel::Conversion
    include ActiveModel::Serializers::JSON

    def self.included(base)
      base.include_root_in_json = false # don't put klass name as toplevel JSON slot
    end

    # Return parsed response body (ie as a hash) if success.  If HTTP exception, API error,
    #  or error return status, return nil but add the error info
    #  to the model's errors object.
    def do_request(endpoint, args={})
      # every request must include the api key
      request_args = args.merge(:apikey => Braincert.api_key)
      begin
        resp = HTTParty.post([Braincert.site,endpoint].join('/'), :query => request_args)
        errors.add(:connection, resp.message) and return nil if resp.code != 200
        body = JSON.parse(resp.body)
        # The return convention from Braincert's API is inconsistent.
        # Some calls return a single JSON object with a "status" slot.
        # Other calls return an array of JSON objects if success (no "status"), OR
        #  a single JSON object with a "status":"error" slot if failure.
        # Fuck.
        errors.add(:connection, body['error']) and return nil if
          body.kind_of?(Hash) && (body['status'] == 'error' || body['Status'] == 'error')
        # otherwise success: return parsed body as JSON
        return body
      rescue RuntimeError, Net::HTTPBroken => e
        self.errors.add(:connection, e.message)
        return nil
      end
    end

  end
end
