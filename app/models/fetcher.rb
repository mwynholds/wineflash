require 'mail'

class Fetcher

  attr_reader :box

  def initialize
    @box = Mailbox.new
  end

  def fetch(opts = {})

    options = { }.merge(opts)

    count = 0
    list = ( opts[:subject] ? @box.search(opts[:subject]) : @box.list )
    list.each do |uid|
      break if options[:max] && count >= options[:max]
      count += 1

      raw = @box.fetch uid
      email = FlashEmail.parse raw

      if !email.identified?
        @box.archive uid, '_unidentified'
        next
      end

      if !email.parsed?
        @box.archive uid, '_invalid'
        next
      end

      if FlashEmail.where(:raw_sha256 => email.raw_sha256).exists?
        puts "Deleting duplicate email: #{email.subject}"
        @box.delete uid
        next
      end

      unless email.save
        puts "Skipping email due to errors: #{email.subject}"
        email.errors.each do |error|
          puts "  Error: #{error}"
        end
        puts ""
        next
      end

      label = "archive/#{email.source}"
      new_uid = @box.archive uid, label
      email.message_id = new_uid
      email.save
    end

    count
  end

  def fetch_next(opts = {})
    fetch opts.merge(:max => 1)
  end

  def testable(uids, source, opts = {})
    options = { :label => '_unidentified' }.merge(opts)
    uids = [ uids ] unless uids.is_a? Array

    dir = "#{Rails.root}/test/fixtures/emails/#{source}"
    Dir.mkdir(dir) unless Dir.exists? dir

    File.open "#{dir}/emails.yml", 'a' do |emails|
      uids.each do |uid|
        msg = @box.fetch uid, options[:label]
        File.open "#{dir}/#{uid}.txt", 'w' do |raw|
          raw.write msg.force_encoding('UTF-8')
        end

        mime = Mail.new msg.force_encoding('ASCII-8BIT')
        emails.write <<EOF
- message_id: #{uid}
  source: #{source}
  subject: #{mime.subject}
  deals:
    - wine:
      varietal:
      vintage:
      price:
      country:
      size:

EOF
      end
    end
  end

end