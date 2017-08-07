require 'spec_helper'

class SampleDrmMaker
  def initialize(drm_record)
    @drm_record = drm_record
  end

  def create!
    if @drm_record.digital.attachment.exists?
      @drm_record.attachment = @drm_record.digital.attachment
    end
  end
end

Spree::DrmRecord.class_eval do
  private
    def prepare_drm_mark
      SampleDrmMaker.new(self).create!
    end
end

RSpec.describe Spree::DrmRecord do
  describe "#create" do
    let(:sample_file) { File.open(SolidusDigital::Engine.root.join("spec", "fixtures", "thinking-cat.jpg")) }
    let(:digital) { create(:digital, drm: true, attachment: sample_file) }
    let(:digital_variant) { create(:variant, digitals: [digital]) }
    let(:line_item) { create(:line_item, variant: digital_variant) }

    it "creates drm marked attachment" do
      drm_record = digital.drm_records.create(line_item: line_item)

      expect(drm_record.attachment.present?).to eq(true)
      expect(drm_record.attachment_file_name).to eq("thinking-cat.jpg")
    end
  end
end
