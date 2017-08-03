module OrderDecorator
  def self.prepended(base)
    base.state_machine.after_transition to: :complete, do: :generate_digital_links, if: :some_digital?
  end

  # all products are digital
  def digital?
    line_items.all? { |item| item.digital? }
  end

  def some_digital?
    line_items.any? { |item| item.digital? }
  end

  def digital_line_items
    line_items.select(&:digital?)
  end

  def digital_links
    digital_line_items.map(&:digital_links).flatten
  end

  def reset_digital_links!
    digital_links.each do |digital_link|
      digital_link.reset!
    end
  end

  private
    def generate_digital_links
      line_items.each { |li| li.create_digital_links if li.digital? }
    end
end

Spree::Order.prepend OrderDecorator
