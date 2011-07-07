class FlashEmail < ActiveRecord::Base

  has_many :deals

  def self.parse(msg)
    mime = Mail.new msg.force_encoding('ASCII-8BIT')

    email = FlashEmail.new
    email.raw = msg
    email.raw_sha256 = Digest::SHA2.new.update(msg).to_s
    email.subject = mime.subject

    parser = Parser::Base.parser_for mime

    unless parser
      puts "Cannot find parser for email from #{mime.from[0]}"
      return email
    end

    unless parser.valid?
      puts "Email is invalid: #{mime.subject}"
      return email
    end

    email.source = parser.source
    email.deals << Deal.new(:wine => parser.wine, :country => parser.country, :vintage => parser.vintage,
                            :varietal => parser.varietal, :size => parser.size, :price => parser.price)

    email
  end

  def parsed?
    ! source.nil?
  end

  def label
    return 'INBOX' unless parsed?
    return 'archive/unknown' if source.nil?
    "archive/#{source}"
  end

end
