class FlashEmail < ActiveRecord::Base

  has_many :deals

  validates :raw_sha256, :uniqueness => true

  def self.parse(raw)
    mime = Mail.new raw.force_encoding('ASCII-8BIT')

    email = FlashEmail.new
    email.raw = raw
    email.raw_sha256 = Digest::SHA2.new.update(raw).to_s
    email.subject = mime.subject

    parser = Parser::Base.parser_for mime

    unless parser
      puts "Cannot find parser for email from #{mime.from[0]}"
      return email
    end

    email.source = parser.source

    unless parser.valid?
      puts "Email is invalid: #{mime.subject}"
      return email
    end

    email.deals += parser.deals
    email
  end

  def identified?
    ! source.nil?
  end

  def parsed?
    ! deals.empty?
  end

  def label
    return 'INBOX' unless parsed?
    return 'archive/unknown' if source.nil?
    "archive/#{source}"
  end

end
