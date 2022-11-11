# frozen_string_literal: true

module Spree
  class DigitalsController < Spree::BaseController
    rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found
    before_action :authorize_digital_link, only: :show

    def show
      if digital_link.cloud?
        redirect_to attachment.expiring_url(Spree::DigitalConfiguration[:s3_expiration_seconds])
      else
        send_file attachment.path, filename: attachment.original_filename, type: attachment.content_type
      end
    end

    private

    def authorize_digital_link
      # don't authorize the link unless the file exists
      raise ActiveRecord::RecordNotFound if attachment.blank?

      render :unauthorized unless digital_link.file_exists? && digital_link.authorize!
    end

    def digital_link
      @link ||= DigitalLink.find_by!(secret: params[:secret])
    end

    def attachment
      @attachment ||= digital_link.attachment
    end

    def resource_not_found
      render body: nil, status: :not_found
    end
  end
end
