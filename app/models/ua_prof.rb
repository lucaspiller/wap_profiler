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

  def validate
    assert_present :uri
    if status.nil?
      self.status = 'pending'
    end
  end

  def self.find_or_create(uri)
    find(:uri => uri).first || create(:uri => uri)
  end
end
