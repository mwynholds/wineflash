class Parser::WTSOParser < Parser::Base

  def source
    'WTSO'
  end

  def self.supports?(mime)
    mime.from[0] == 'wines@wtso.com'
  end

  def valid?
    ! @dom.xpath("//td[text() = 'Appellation:']").empty?
  end

  def deals
    [ Deal.new(:wine => wine, :country => country, :vintage => vintage,
               :varietal => varietal, :size => size, :price => price) ]
  end

  private

  def wine
    @mime.subject
  end

  def country
    @dom.xpath("//td[text() = 'Appellation:']/../../tr[3]/td[1]/em[1]").country
  end

  def size
    @dom.xpath("//td[text() = 'Size:']/../../tr[3]/td[2]/em[1]").size
  end

  def vintage
    @dom.xpath("//td[text() = 'Vintage:']/../../tr[3]/td[1]/em[1]").val
  end

  def varietal
    @dom.xpath("//td[text() = 'Varietal/Grapes:']/../../tr[3]/td[1]/em[1]").val
  end

  def price
    @dom.xpath("//strong[text() = 'Our Price(Delivered):']/../../../td[2]//strong[1]").price
  end

end