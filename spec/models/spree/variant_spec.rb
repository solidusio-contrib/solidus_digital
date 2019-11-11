# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Variant do
  describe "#destroy" do
    let(:variant) { create(:variant) }
    let!(:digital) { create(:digital, variant: variant) }

    it "destroys associated digitals by default" do
      # default is false
      stub_spree_preferences(Spree::DigitalConfiguration, keep_digitals: false)

      expect(Spree::Digital.count).to eq(1)
      expect(variant.digitals.present?).to be true

      variant.deleted_at = Time.zone.now
      expect(variant.deleted?).to be true
      variant.save!

      expect { digital.reload.present? }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Spree::Digital.count).to eq(0)
    end

    it "conditionallies keep associated digitals" do
      stub_spree_preferences(Spree::DigitalConfiguration, keep_digitals: true)

      expect(Spree::Digital.count).to eq(1)
      expect(variant.digitals.present?).to be true

      variant.deleted_at = Time.zone.now
      variant.save!
      expect(variant.deleted?).to be true
      expect { digital.reload.present? }.not_to raise_error
      expect(Spree::Digital.count).to eq(1)
    end
  end
end
