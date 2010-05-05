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

  def mutex_no_wait
    if lock_no_wait!
      begin
        yield
        self
      ensure
        db.del(key(:_lock))
      end
    else
      false
    end
  end

  def lock_no_wait!
    unless db.setnx(key(:_lock), lock_timeout)
      # lock deleted, someone else can try and get it
      return false unless lock = db.get(key(:_lock))

      # lock not yet expired, next!
      return false unless lock_expired?(lock)

      # we tried clearing and setting the already expired lock, but something went wrong
      return false unless lock = db.getset(key(:_lock), lock_timeout)

      # someone beat us to it, the existing lock isn't expired
      return false if lock_expired?(lock)
    end

    # gotcha!
    true
  end

  def lock_timeout
    Time.now + 10
  end
end
