class Parser::Base

  @@parsers = []
  @@countries = {}
  @@wines = {}

  cattr_accessor :parsers
  cattr_accessor :wines

  def self.inherited(subclass)
    @@parsers << subclass
  end

  def self.countries=(country_config)
    country_config.each do |country, synonyms|
      @@countries[country] = country
      synonyms.each do |synonym|
        @@countries[synonym] = country
      end
    end
  end

  def self.countries
    @@countries
  end

  def self.parser_for(mime)
    @@parsers.each do |parser|
      return parser.new(mime) if parser.supports? mime
    end

    nil
  end

  def initialize(mime)
    @mime = mime

    html = html_part
    unless html =~ /^<html>/
      html = "<html>#{html}</html>"
    end

    @dom = Nokogiri::HTML html
    @dom.encoding = 'UTF-8'
  end

  def html_part
    @mime.html_part.body.to_s.force_encoding 'UTF-8'
  end

  def apply_keywords(deal, *strings)
    strings.compact.each do |str|
      s = str.downcase
      @@wines.each do |keyword, attrs|
        deal.apply attrs if s =~ /#{keyword.downcase}/
      end
    end
  end

end