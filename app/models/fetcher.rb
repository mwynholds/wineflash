class Fetcher

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

      mime = @box.fetch uid
      email = FlashEmail.parse mime

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

#  def self.save_latest(dir, options = {})
#    fetch(options) do |message_id, msg|
#      File.open "#{dir}/#{message_id}.txt", 'w' do |f|
#        f.write msg.force_encoding('UTF-8')
#      end
#    end
#
#    nil
#  end
#
#  def self.create_test_fixtures
#    save_latest "#{Rails.root}/test/fixtures/emails", :folder => 'test/wtso'
#  end

end