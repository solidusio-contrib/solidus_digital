# frozen_string_literal: true

FactoryBot.define do
  factory :digital, class: Spree::Digital do |f|
    f.variant { |p| p.association(:variant) }
    f.attachment_content_type { 'application/octet-stream' }
    f.attachment_file_name { "#{SecureRandom.hex(5)}.epub" }
  end

  factory :digital_link, class: Spree::DigitalLink do |f|
    f.digital { |p| p.association(:digital) }
    f.line_item { |p| p.association(:line_item) }
  end

  factory :digital_shipping_calculator, class: Spree::Calculator::Shipping::DigitalDelivery do
    after :create do |c|
      c.set_preference(:amount, 0)
    end
  end

  factory :digital_shipping_method, parent: :shipping_method do
    name { "Digital Delivery" }
    calculator { FactoryBot.build :digital_shipping_calculator }
  end
end
