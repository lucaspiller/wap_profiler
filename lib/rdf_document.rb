require 'open-uri'
require 'nokogiri'

class RdfDocument
  def initialize(url)
    @url = url
  end

  def document
    @document ||= Nokogiri::XML(open(ARGV[0]))
  end

  def tag(xpath)
    document.xpath(xpath).first.content
  end
end
