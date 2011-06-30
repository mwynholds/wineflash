class Parser::WTSOParser < Parser::Base

  def valid?
    ! @dom.xpath("//td[text() = 'Appellation:']").empty?
  end

  def wine
    @mime.subject
  end

  def country
    normalize_country @dom.xpath("//td[text() = 'Appellation:']/../../tr[3]/td[1]/em[1]/text()")
  end

  def size
    normalize_size @dom.xpath("//td[text() = 'Size:']/../../tr[3]/td[2]/em[1]/text()")
  end

  def vintage
    text @dom.xpath("//td[text() = 'Vintage:']/../../tr[3]/td[1]/em[1]/text()")
  end

  def varietal
    text @dom.xpath("//td[text() = 'Varietal/Grapes:']/../../tr[3]/td[1]/em[1]/text()")
  end

  def price
    normalize_price @dom.xpath("//strong[text() = 'Our Price(Delivered):']/../../../td[2]//strong[1]/text()")
  end

end