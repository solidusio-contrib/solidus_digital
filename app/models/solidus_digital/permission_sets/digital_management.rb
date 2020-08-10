# frozen_string_literal: true

module SolidusDigital
  module PermissionSets
    class DigitalManagement < ::Spree::PermissionSets::Base
      def activate!
        can :manage, ::Spree::Digital
      end
    end
  end
end
