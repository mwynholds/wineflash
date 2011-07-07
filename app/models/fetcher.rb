require 'net/imap'
require 'mail'

class Fetcher

  @@config = {}

  def self.config=(config)
    config.each do |k,v|
      @@config[k.to_sym] = v
    end
  end

  def fetch_latest(opts = {})
    imap = self.imap opts
    mailboxes = imap.list('', 'archive/*')
    

    fetch imap, opts do |message_id, msg|
      email = FlashEmail.parse msg
      
      # bail if checksum already exists in db
      if ! FlashEmail.find_all_by_raw_sha256(email.raw_sha256).empty?
        puts "Skipping email because it already exists in the database: #{email.subject}"
        imap.uid_copy email.message_id,
      end

      # save raw with checksum
      # parse and save
      # move email in imap
    end

    imap.logout()
    imap.disconnect()
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

  # deleting
  # imap.store(message_id, "+FLAGS", [:Deleted])

  private

  def self.imap(opts = {})
    options = { :folder => 'INBOX', :ssl => true }.merge(@@config).merge(opts)
    imap = Net::IMAP.new(options[:server], :ssl => options[:ssl])
    imap.login options[:username], options[:password]
    imap
  end

  def self.fetch(imap, options)
    count = 0
    imap.select options[:folder]
    imap.uid_search(["NOT", "DELETED"]).each do |message_id|
      msg = imap.uid_fetch message_id, "RFC822"
      yield message_id, msg[0].attr['RFC822'] if block_given?
      count += 1
      break if options[:max] && count >= options[:max]
    end
  end

  def archive(imap, email)

  end

end