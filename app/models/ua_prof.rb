require 'lib/rdf_document'

SCREEN_SIZE_XPATH = '//rdf:Description[@rdf:ID="HardwarePlatform"]/prf:ScreenSize'

class UaProf < Ohm::Model
  attribute :uri
  attribute :status
  attribute :width
  attribute :height

  index :uri
  index :status

  def pending?
    status.nil? || status == 'pending'
  end

  def process!
    begin
      doc = RdfDocument.new(self.uri)

      # screen size
      doc.tag(SCREEN_SIZE_XPATH) =~ /([0-9]+)x([0-9]+)/
      self.width = $1
      self.height = $2

      # update status and save
      self.status = 'processed'
      save
    rescue Nokogiri::XML::SyntaxError => e
      # parse error
      # TODO: Log it, and pos. ignore it in the future
      false
    end
  end

  def validate
    assert_present :uri

    # set default status
    if status.nil?
      self.status = 'pending'
    end
  end

  def self.find_or_create(uri)
    find(:uri => uri).first || create(:uri => uri)
  end
end
