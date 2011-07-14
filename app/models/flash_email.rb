class FlashEmail < ActiveRecord::Base

  has_many :deals

  validates :raw_sha256, :uniqueness => true

  def self.re_parse(opts = {})
    options = {}.merge opts
    verbose = options[:verbose]

    emails = ( options[:source] ? FlashEmail.where(:source => options[:source]) : FlashEmail.all )
    emails.each do |email|
      puts "Re-parse email: #{email.subject}" if verbose
      re_parsed = FlashEmail.parse email.raw
      email.source = re_parsed.source
      email.deals.each { |deal| deal.delete }
      email.deals += re_parsed.deals
      email.save!
    end
    
    nil
  end

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

end
