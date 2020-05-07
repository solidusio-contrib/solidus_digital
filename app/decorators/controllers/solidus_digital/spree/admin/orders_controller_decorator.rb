# frozen_string_literal: true

module SolidusDigital
  module Spree
    module Admin
      module OrdersControllerDecorator
        def reset_digitals
          load_order
          @order.reset_digital_links!
          flash[:notice] = I18n.t('spree.digitals.downloads_reset')
          redirect_to spree.edit_admin_order_path(@order)
        end

        ::Spree::Admin::OrdersController.prepend self
      end
    end
  end
end
