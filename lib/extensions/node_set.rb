class Nokogiri::XML::NodeSet
  def val
    apply :val
  end

  def price
    apply :price
  end

  def size
    apply :size
  end

  def country
    apply :country
  end

  private

  def apply(func)
    return nil if empty?
    self[0].send func
  end
end