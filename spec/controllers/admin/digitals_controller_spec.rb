# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::DigitalsController do
  stub_authorization!

  let!(:product) { create(:product) }

  describe '#index' do
    render_views

    context "with variants" do
      let(:digitals) { 3.times.map { create(:digital) } }
      let(:variants_with_digitals) do
        digitals.map { |d| create(:variant, product: product, digitals: [d]) }
      end
      let(:variants_without_digitals) { 3.times.map { create(:variant, product: product) } }

      it "displays an empty page when no digitals exist" do
        variants_without_digitals
        get :index, params: { product_id: product.slug }
      end

      it "displays list of digitals when they exist" do
        variants_with_digitals
        get :index, params: { product_id: product.slug }

        variants_with_digitals.each do |variant|
          variant.digitals.each do |digital|
            expect(response.body).to include(digital.attachment_file_name)
          end
        end
      end
    end

    context "without non-master variants" do
      it "displays an empty page when the master variant is not digital" do
        get :index, params: { product_id: product.slug }
        expect(response.code).to eq("200")
        expect(response.body).to include("<span>This product has no variants.</span>")
        expect(response.body).not_to include('<span>A digital version of this product currently exists:</span>')
      end

      it "displays the variant details when the master is digital" do
        @digital = create :digital, variant: product.master
        get :index, params: { product_id: product.slug }

        expect(response.code).to eq("200")
        expect(response.body).to include('<span>A digital version of this product currently exists:</span>')
      end
    end
  end

  describe '#create' do
    context 'for a product that exists' do
      let!(:variant) { create(:variant, product: product) }

      it 'creates a digital associated with the variant and product' do
        expect {
          post :create, params: { product_id: product.slug,
                                  digital: { variant_id: variant.id,
                                             attachment: upload_image('thinking-cat.jpg') } }
          expect(response).to redirect_to(spree.admin_product_digitals_path(product))
        }.to change(Spree::Digital, :count).by(1)
      end
    end

    context 'for an invalid object' do
      it 'redirects to the index page' do
        expect {
          post :create, params: { product_id: product.slug, digital: { variant_id: product.master.id } } # fail validation by not passing attachment
          expect(flash[:error]).to eq "Attachment can't be blank"
          expect(response).to redirect_to(spree.admin_product_digitals_path(product))
        }.to change(Spree::Digital, :count).by(0)
      end
    end
  end

  describe '#destroy' do
    let(:digital) { create(:digital) }
    let!(:variant) { create(:variant, product: product, digitals: [digital]) }

    context 'for a digital and product that exist' do
      it 'deletes the associated digital' do
        expect {
          delete :destroy, params: { product_id: product.slug, id: digital.id }
          expect(response).to redirect_to(spree.admin_product_digitals_path(product))
        }.to change(Spree::Digital, :count).by(-1)
      end
    end
  end
end
