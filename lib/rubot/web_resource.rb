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

    def self.get_url(url, params = {})
      query = "?" + params.map { |k,v| "#{k}=#{CGI.escape(v)}" }.join("&") if params.any?
      Nokogiri::HTML.parse Net::HTTP.get(URI.parse(url + query.to_s))
    end
  end
end