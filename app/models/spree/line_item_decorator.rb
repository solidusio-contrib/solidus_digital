Spree::LineItem.class_eval do
  has_many :digital_links, dependent: :destroy

  def digital?
    variant.digital? || variant.product.master.digital?
  end

  def create_digital_links
    Spree::DigitalLinksCreator.new(self).create_digital_links
  end
end
