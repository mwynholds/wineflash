class Nokogiri::XML::Node
  def val
    content().strip
  end

  def price
    val.match /\$(\d+(\.\d+)?)/ do |m|
      return m[1]
    end

    nil
  end

  def size
    v = val.downcase
    [375, 500, 750, 1500, 3000, 6000].each do |size|
      return size if v =~ /#{size.to_s}/
    end

    return 1500 if v =~ /1\.50?\s*[lL]/
    return 3000 if v =~ /3(\.0)?\s*[lL]/
    return 6000 if v =~ /6(\.0)?\s*[lL]/

    return 3000 if v =~ /(double|dbl)\s+magnum/
    return 1500 if v =~ /magnum/

    nil
  end

  def country
    v = val.downcase
    Parser::Base.countries.each do |synonym, country|
      return country if v =~ /#{synonym.downcase}/
    end

    nil
  end
end