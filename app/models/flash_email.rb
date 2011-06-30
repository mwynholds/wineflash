class FlashEmail < ActiveRecord::Base

  has_many :deals

  def self.parse(msg)
    mime = Mail.new msg.force_encoding('ASCII-8BIT')
    email = FlashEmail.new
    email.subject = mime.subject
    email.source = 'wtso'

    parser = Parser::WTSOParser.new mime

    return nil unless parser.valid?

    email.deals << Deal.new(:wine => parser.wine, :country => parser.country, :vintage => parser.vintage,
                            :varietal => parser.varietal, :size => parser.size, :price => parser.price)

    email
  end

end
