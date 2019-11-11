# frozen_string_literal: true

module SolidusDigital
  module Spree
    module ProductDecorator
      def self.prepended(base)
        base.class_eval do
          has_many :digitals, through: :variants_including_master
        end
      end

      ::Spree::Product.prepend self
    end
  end
end
