require 'yaml'

Dir.glob("#{Rails.root}/app/models/parser/*.rb").each do |file|
  load file
end

yaml = YAML::load File.open("#{Rails.root}/config/countries.yml")
Parser::Base.countries = yaml