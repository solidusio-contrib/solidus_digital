# frozen_string_literal: true

module SolidusDigital
  module PermissionSets
    class DigitalDisplay < ::Spree::PermissionSets::Base
      def activate!
        can [:display, :admin], ::Spree::Digital
      end
    end
  end
end
