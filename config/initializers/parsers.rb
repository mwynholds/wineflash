require 'yaml'

Parser::Base
Dir.glob("#{Rails.root}/app/models/parser/*_parser.rb").each do |file|
  load file
end

Parser::Base.countries = YAML::load File.open("#{Rails.root}/config/countries.yml")
Parser::Base.wines = YAML::load File.open("#{Rails.root}/config/wines.yml")