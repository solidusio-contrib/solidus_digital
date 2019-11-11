# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::DigitalsController, type: :controller do
  describe '#show' do
    let(:digital) { create(:digital) }
    let(:digital_link) { create(:digital_link, digital: digital) }

    it 'returns a 404 for a non-existent secret' do
      get :show, params: { secret: 'NotReal00000000000000000000000' }
      expect(response.status).to eq(404)
    end

    context 'unauthorized' do
      it 'returns a 200 and calls send_file for link that is not a file' do
        expect(digital_link).not_to receive(:cloud?)
        expect(controller).not_to receive(:send_file)

        get :show, params: { secret: digital_link.secret }
        expect(response.status).to eq(200)
        expect(response).to render_template(:unauthorized)
      end
    end

    context 'authorized' do
      before { allow(controller).to receive(:authorize_digital_link).and_return(true) }

      it 'returns a 200 and calls send_file that is a file' do
        expect(controller)
          .to receive(:send_file)
            .with(
              digital.attachment.path,
              filename: digital.attachment.original_filename,
              type: digital.attachment.content_type
            ){ controller.render body: nil, content_type: digital.attachment.content_type }

        get :show, params: { secret: digital_link.secret }
        expect(response.status).to eq(200)
        expect(response.header['Content-Type']).to match digital.attachment.content_type
      end

      it 'redirects to s3 when using s3' do
        skip 'TODO: needs a way to test without having a bucket'
        Paperclip::Attachment.default_options[:storage] = :s3

        expect(controller).to receive(:redirect_to)
        expect(controller).to receive(:attachment_is_file?).and_return(true)
        expect(controller).not_to receive(:send_file)

        get :show, params: { secret: digital_link.secret }
      end
    end
  end
end
