class Parser::Base

  @@parsers = []
  @@countries = {}

  cattr_accessor :parsers

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

  def self.parser_for(mime)
    @@parsers.each do |parser|
      return parser.new(mime) if parser.supports? mime
    end

    nil
  end

  def initialize(mime)
    @mime = mime

    html = mime.body.parts.find { |part| part.content_type == 'text/html' }.body.to_s
    unless html =~ /^<html>/
      html = "<html>#{html}</html>"
    end

    @dom = Nokogiri::HTML html
  end

  def normalize_size(str)
    str = text(str) if str.is_a? Nokogiri::XML::NodeSet
    return nil if str.nil?
    return 750 if str =~ /750/
    nil
  end

  def normalize_price(str)
    str = text(str) if str.is_a? Nokogiri::XML::NodeSet
    return nil if str.nil?
    str.sub(/\$/, '').to_d
  end
  
  def normalize_country(str)
    str = text(str) if str.is_a? Nokogiri::XML::NodeSet
    return nil if str.nil?
    @@countries[str]
  end

  def text(nodeset)
    return nil if nodeset.empty?
    nodeset[0].text().strip
  end

end