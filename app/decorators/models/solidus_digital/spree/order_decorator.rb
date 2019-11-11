# frozen_string_literal: true

module SolidusDigital
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.state_machine.after_transition to: :complete, do: :generate_digital_links, if: :some_digital?
      end

      # all products are digital
      def digital?
        line_items.all?(&:digital?)
      end

      def some_digital?
        line_items.any?(&:digital?)
      end

      def digital_line_items
        line_items.select(&:digital?)
      end

      def digital_links
        digital_line_items.map(&:digital_links).flatten
      end

      def reset_digital_links!
        digital_links.each(&:reset!)
      end

      private

      def generate_digital_links
        line_items.each { |li| li.create_digital_links if li.digital? }
      end

      ::Spree::Order.prepend self
    end
  end
end
