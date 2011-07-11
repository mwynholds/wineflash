class Parser::CrushParser < Parser::Base

  @@staff = [ 'Ian McFadden', 'Stephen Bitterolf', 'Robert Schagrin' ]

  def initialize(mime)
    super mime

    header_node = find_header_node
    price_nodes = find_price_nodes header_node

    @deals = []
    price_nodes.each do |node|
      price = node.val
      if price =~ /Special (Email|Futures)/ && price !~ /\d+\-Pack/ && price !~ /Case/
        deal = Deal.new :size => 750
        price.match /\$(\d+\.\d+)/ do |m|
          deal.price = m[1].to_d
        end

        header = header_node.val
        sub_header = find_sub_header node
        wine_description = ( sub_header && sub_header != price ? sub_header : header )

        wine_description.match /^(\d*)(.*)$/ do |m|
          deal.vintage = m[1] || 'NV'
          deal.wine = m[2].strip
        end

        wine_description.match /([\(]?(375|500|750|1500)(ml|ML)?[\)]?)/ do |m|
          deal.size = m[2].to_i
          deal.wine = deal.wine.gsub(m[1], '').strip
        end

        apply_keywords deal, mime.subject, header, sub_header
        @deals << deal
      end
    end
  end

  def source
    'Crush'
  end

  def self.supports?(mime)
    mime.from[0] == 'offers@crushwineco.com'
  end

  def valid?
    ! @deals.empty?
  end

  def deals
    @deals
  end

  private

  def find_header_node
    context = @dom.xpath("//table[@width = '655']")
    sig = nil
    @@staff.each do |staff|
      sig = context.xpath("//p[starts-with(text(), '#{staff}')]")
      break unless sig.empty?
    end
    sig[0].next_element
  end

  def find_price_nodes(header_node)
    header_node.xpath("following-sibling::p//span[@style = 'color:rgb(255, 0, 0);']")
  end

  # look at the preview <p> ancestor, then get its first child value, or if there are a bunch
  # of <strong> nodes, concatenate them all
  def find_sub_header(price_node)
    p_children = price_node.xpath("ancestor::p/*")
    parts = []
    p_children.each do |p_child|
      if parts.empty? || p_child.name == 'strong'
        parts << p_child.val
      else
        break
      end
    end
    
    parts.join ' '
  end
end