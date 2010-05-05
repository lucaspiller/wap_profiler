require 'open-uri'
require 'nokogiri'

class RdfDocument
  def initialize(url)
    @url = url
  end

  def document
    @document ||= Nokogiri::XML(open(@url))
  end

  def tag(xpath)
    document.xpath(xpath).first.content
  end
end
