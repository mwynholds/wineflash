require 'yaml'

yaml = YAML::load File.open("#{Rails.root}/config/imap.yml")
Mailbox.config = yaml[Rails.env]