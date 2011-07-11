class Deal < ActiveRecord::Base

  belongs_to :flash_email

  def apply(attrs)
    attrs.each do |name, value|
      if respond_to? name
        send (name + '=').to_sym, value
      end
    end
  end
end