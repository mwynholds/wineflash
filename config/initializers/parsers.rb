require 'yaml'

yaml = YAML::load File.open("#{Rails.root}/config/countries.yml")
Parser::Base.countries = yaml