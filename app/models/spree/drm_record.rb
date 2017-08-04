module Spree
  class DrmRecord < ActiveRecord::Base
    belongs_to :digital
    belongs_to :line_item

    before_create :prepare_drm_mark

    has_attached_file :attachment, path: ":rails_root/private/digitals/drm/:id/:basename.:extension"
    do_not_validate_attachment_file_type :attachment

    if Paperclip::Attachment.default_options[:storage] == :s3
      attachment_definitions[:attachment][:s3_permissions] = :private
      attachment_definitions[:attachment][:s3_headers] = { content_disposition: 'attachment' }
    end

    private
      def prepare_drm_mark
        # TODO: implement DRM functionallity, set new file for DRM record
      end
  end
end
