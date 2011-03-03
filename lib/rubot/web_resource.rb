require "net/http"
require "nokogiri"
require "cgi"

module Rubot
  class WebResource
    def self.get(name, url)
      define_singleton_method(name) do |params = {}|
        yield Nokogiri::HTML.parse(get_wut(url, params))
      end
    end

    private
    # todo: name
    def self.get_wut(url, params = {})
      query = "?" + params.map { |k,v| "#{k}=#{CGI.escape(v)}" }.join("&") if params.any?
      Net::HTTP.get(URI.parse(url + query.to_s))
    end
  end
end