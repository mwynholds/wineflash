require 'net/imap'
require 'mail'

class Fetcher

  cattr_accessor :config

  def self.fetch_latest(options = {})
    options = { :folder => 'INBOX' }.merge options

    puts "Fetching new emails from #{options[:folder]}"

    emails = {}
    imap = Net::IMAP.new(@@config['server'], :ssl => true)
    imap.login(@@config['username'], @@config['password'])
    imap.select options[:folder]
    imap.search(["NOT", "DELETED"]).each do |message_id|
      msg = imap.fetch message_id, "RFC822"
      emails[message_id] = msg[0].attr['RFC822']
    end
    imap.logout()
    imap.disconnect()

    emails
  end

  def self.save_latest(dir, options = {})
    fetch_latest(options).each do |message_id, msg|
      File.open "#{dir}/#{message_id}.txt", 'w' do |f|
        f.write msg.force_encoding('UTF-8')
      end
    end

    nil
  end

  def self.create_test_fixtures
    save_latest "#{Rails.root}/test/fixtures/emails", :folder => 'test/wtso'
  end

  # deleting
  # imap.store(message_id, "+FLAGS", [:Deleted])

end