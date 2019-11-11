# frozen_string_literal: true

module Spree
  class DigitalLink < ApplicationRecord
    belongs_to :digital
    belongs_to :line_item

    validates :digital, presence: true
    validates :secret, length: { is: 30 }
    before_validation :set_defaults, on: :create

    delegate :attachment_file_name, :cloud?, to: :digital

    # Can this link still be used? It is valid if it's less than 24 hours old and was not accessed more than 3 times
    def authorizable?
      !(expired? || access_limit_exceeded?)
    end

    def expired?
      created_at <= Spree::DigitalConfiguration[:authorized_days].day.ago
    end

    def ready?
      attachment.exists?
    end

    def file_exists?
      cloud? ? attachment.exists? : File.file?(attachment.path)
    end

    def access_limit_exceeded?
      return false if Spree::DigitalConfiguration[:authorized_clicks].nil?

      access_counter >= Spree::DigitalConfiguration[:authorized_clicks]
    end

    # This method should be called when a download is initiated.
    # It returns +true+ or +false+ depending on whether the authorization is granted.
    def authorize!
      authorizable? && increment!(:access_counter) ? true : false
    end

    def reset!
      update_column :access_counter, 0
      update_column :created_at, Time.zone.now
    end

    def attachment
      if digital.drm?
        digital.drm_records.find_by(line_item: line_item).attachment
      else
        digital.attachment
      end
    end

    private

    # Populating the secret automatically and zero'ing the access_counter (otherwise it might turn out to be NULL)
    def set_defaults
      self.secret = SecureRandom.hex(15)
      self.access_counter ||= 0
    end
  end
end
