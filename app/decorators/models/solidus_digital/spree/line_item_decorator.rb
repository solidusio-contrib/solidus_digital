# frozen_string_literal: true

module SolidusDigital
  module Spree
    module LineItemDecorator
      def self.prepended(base)
        base.class_eval do
          has_many :digital_links, dependent: :destroy
        end
      end

      def digital?
        variant.digital? || variant.product.master.digital?
      end

      def create_digital_links
        ::Spree::DigitalLinksCreator.new(self).create_digital_links
      end

      ::Spree::LineItem.prepend self
    end
  end
end
