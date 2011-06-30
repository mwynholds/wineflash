require 'yaml'

yaml = YAML::load File.open("#{Rails.root}/config/flash_email.yml")
Fetcher.config = yaml[Rails.env]