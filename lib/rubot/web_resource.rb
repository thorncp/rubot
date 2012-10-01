require "net/http"
require "nokogiri"
require "cgi"

module Rubot
  class WebResource
    def self.get(name, url)
      define_singleton_method(name) do |params = {}|
        yield get_url(url, params)
      end
    end

    def self.get_url(url, params = {}, follow = false)
      query = "?" + params.map { |k,v| "#{k}=#{CGI.escape(v)}" }.join("&") if params.any?
      found = false
      until found
        res = Net::HTTP.get_response(URI.parse(url + query.to_s))
        res.header['location'] && follow == true ? url = res.header['location'] : found = true
      end
      Nokogiri::HTML.parse Net::HTTP.get(res.body)
    end

    def self.get_url_follow(url, params={})
      get_url(url, params, follow = true)
    end
  end
end
