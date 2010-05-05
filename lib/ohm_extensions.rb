require 'json'

class Ohm::Model
  def to_h
    attributes.inject({}) do |hash, attr|
      hash[attr.to_sym] = send(attr)
      hash
    end
  end

  def to_json
    to_h.to_json
  end
end
