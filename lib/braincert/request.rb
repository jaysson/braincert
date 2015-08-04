require 'httparty'

module Braincert
  module Request

    @@site = 'https://api.braincert.com/v1'
    
    def self.api_key=(key) ; @@api_key = key ; end
    def self.site=(site);    @@site = site.gsub(/\/$/,'')   ; end # rm trailing slash

    protected
    
    # Return response body if success.  If HTTP exception, API error,
    #  or error return status, return nil but add the error info
    #  to the model's errors object.
    def do_request(endpoint, args={})
      # every request must include the api key
      request_args = args.merge(:apikey => @@api_key)
      begin
        resp = HTTParty.post([@@site,endpoint].join('/'), :query => request_args)
        errors.add(:connection, resp.message) and return nil if resp.code != 200
        body = JSON.parse(resp.body)
        errors.add(:connection, body['error']) and return nil if
          (body['status'] == 'error' || body['Status'] == 'error')
        # otherwise success: return parsed body as JSON
        return body
      rescue RuntimeError => e
        self.errors.add(:connection, e.message)
        return nil
      end
    end

  end
end
