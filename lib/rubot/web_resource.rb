require "net/http"
require "nokogiri"

module Rubot
  class WebResource
    def self.get(name, url)
      define_singleton_method(name) do
        response = Net::HTTP.get(URI.parse(url))
        yield Nokogiri::HTML.parse(response)
      end
    end
  end
end