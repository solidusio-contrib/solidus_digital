module Spree
  class Digital < ActiveRecord::Base
    belongs_to :variant
    has_many :digital_links, dependent: :destroy
    has_many :drm_records, dependent: :destroy

    has_attached_file :attachment, path: ":rails_root/private/digitals/:id/:basename.:extension", s3_permissions: :private, s3_headers: { content_disposition: 'attachment' }
    do_not_validate_attachment_file_type :attachment
    validates_attachment_presence :attachment

    def cloud?
      attachment.options[:storage] == :s3
    end

    def create_drm_record(line_item)
      drm_records.create!(line_item: line_item)
    end
  end
end
