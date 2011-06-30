class FlashEmail < ActiveRecord::Base

  has_many :deals

  def self.parse(msg)
    mime = Mail.new msg.force_encoding('ASCII-8BIT')
    email = FlashEmail.new
    email.subject = mime.subject
    email.source = 'wtso'
    
    html = mime.body.parts.find { |part| part.content_type == 'text/html' }.body.to_s
    unless html =~ /^<html>/
      html = "<html>#{html}</html>"
    end

    dom = Nokogiri::HTML html
    anchor = dom.xpath("//td[text() = 'Appellation:']")[0]

    return nil if anchor.nil?

    #p anchor.parent().next_sibling()
    country = anchor.parent().next_sibling().children()[0].children()[0].text().strip  #[0].value().strip
    p country

    email
  end

end
