class FlashEmail < ActiveRecord::Base

  has_many :deals

  def self.parse(msg)
    mime = Mail.new msg.force_encoding('ASCII-8BIT')
    parser = Parser::Base.parser_for mime

    unless parser
      puts "Cannot find parser for email from #{mime.from[0]}"
      return nil
    end

    unless parser.valid?
      puts "Email is invalid: #{mime.subject}"
      return nil
    end

    email = FlashEmail.new
    email.subject = mime.subject
    email.source = parser.source
    email.deals << Deal.new(:wine => parser.wine, :country => parser.country, :vintage => parser.vintage,
                            :varietal => parser.varietal, :size => parser.size, :price => parser.price)

    email
  end

end
