require 'net/imap'
require 'mail'

class Mailbox

  @@config = {}

  def self.config=(config)
    config.each do |k,v|
      @@config[k.to_sym] = v
    end
  end

  def self.connect(opts = {})
    options = @@config.merge(opts)
    imap = Net::IMAP.new(options[:server], :ssl => options[:ssl])
    imap.login options[:username], options[:password]
    imap
  end

  attr_reader :imap

  def initialize(imap = nil)
    @imap = imap || Mailbox.connect
    @labels = labels
  end

  def search(query, label = 'INBOX')
    @imap.examine label
    context, term = 'SUBJECT', query
    query.match /^(to|from):(.*)$/ do |m|
      context, term = m[1].upcase, m[2]
    end
    @imap.uid_search [context, term]
  end

  def list(label = 'INBOX')
    @imap.examine label
    @imap.uid_search ['NOT', 'DELETED']
  end

  def fetch(uid, label = 'INBOX')
    @imap.examine label
    msg = @imap.uid_fetch(uid, 'RFC822')
    msg[0].attr['RFC822']
  end

  def archive(uid, label)
    tokens = []
    label.split('/').each do |token|
      tokens << token
      partial = tokens.join '/'
      unless @labels.include? partial
        @imap.create partial
        @labels << partial
      end
    end

    new_uid = copy uid, 'INBOX', label
    mark_as_seen new_uid, label
    delete uid, 'INBOX'

    new_uid
  end

  def unarchive(uid, label)
    new_uid = copy uid, label, 'INBOX'
    mark_as_unseen new_uid, 'INBOX'
    delete uid, label

    new_uid
  end

  def unarchive_all(label)
    search('*', label).each do |uid|
      revert uid, label
    end
  end

  def delete(uid, label = 'INBOX')
    @imap.select label
    @imap.uid_store uid, '+FLAGS', [:Deleted]
  end

  def labels
    @imap.list('', '*').map { |m| m.name }
  end

  def disconnect
    @imap.logout
    @imap.disconnect
  end

  private

  # returns new UID
  def copy(uid, from_label, to_label)
    @imap.examine from_label
    resp = @imap.uid_copy uid, to_label
    resp.data.code.data.split(' ')[2].to_i
  end

  def mark_as_seen(uid, label)
    @imap.select label
    @imap.uid_store uid, '+FLAGS', [:Seen]
  end

  def mark_as_unseen(uid, label)
    @imap.select label
    @imap.uid_store uid, '-FLAGS', [:Seen]
  end
  
end