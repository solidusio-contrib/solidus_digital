require 'spec_helper'

RSpec.describe Spree::Admin::OrdersController do
  context "with authorization" do
    stub_authorization!

    let(:order) do
      create(:completed_order_with_totals) do |o|
        create(:digital, variant: o.line_items.first.variant)
      end
    end
    let!(:digital_link) do
      create(:digital_link, access_counter: 3, line_item: order.line_items.first)
    end

    before do
      request.env["HTTP_REFERER"] = "http://localhost:3000"
    end

    context '#reset_digitals' do
      it 'should reset digitals for an order' do
        expect do
          get :reset_digitals, params: { id: order.number }
          digital_link.reload
        end.to change(digital_link, :access_counter).to(0)

        expect(response).to redirect_to(spree.admin_order_path(order))
      end
    end
  end
end
