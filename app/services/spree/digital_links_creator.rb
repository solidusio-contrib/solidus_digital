class Spree::DigitalLinksCreator
  attr_reader :line_item

  delegate :quantity, :digital_links, :variant, :master, to: :line_item

  def initialize(line_item)
    @line_item = line_item
  end

  def create_digital_links
    digital_links.delete_all

    #include master variant digitals
    master = variant.product.master
    create_digital_links_for_variant(master) if master.digital?
    create_digital_links_for_variant(variant) unless variant.is_master
  end

  private
    def create_digital_links_for_variant(variant)
      variant.digitals.each do |digital|
        digital.create_drm_record(line_item) if digital.drm?
        quantity.times { digital_links.create!(digital: digital) }
      end
    end
end
