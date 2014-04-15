require "httparty"

class WebUtil < Rubot::WebResource
  def self.title(link)
    doc = party(link.to_s)

    title = doc.search("meta[name='title']").first
    if title
      title.attributes["content"].text.strip
    else
      doc.css("head title").text.strip
    end
  end

  def self.party(url)
    Nokogiri::HTML.parse(HTTParty.get(url))
  end
end
