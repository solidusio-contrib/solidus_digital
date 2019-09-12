module SolidusDigital
  module Spree
    module Admin
      module OrdersControllerDecorator
        def reset_digitals
          load_order
          @order.reset_digital_links!
          flash[:notice] = Spree.t(:downloads_reset, scope: 'digitals')
          redirect_to spree.admin_order_path(@order)
        end

        ::Spree::Admin::OrdersController.prepend self
      end
    end
  end
end
