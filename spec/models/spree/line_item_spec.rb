require 'spec_helper'
require 'spree/testing_support/order_walkthrough'

RSpec.describe Spree::LineItem do
  let(:order) { create(:order) }
  let!(:digital_variant) { create(:variant, digitals: [create(:digital)]) }
  let!(:master_digital_variant) { create(:on_demand_master_variant, digitals: [create(:digital)]) }

  context "#digital?" do
    it "reports as digital if either the master variant or selected variant has digitals" do
      expect(build(:variant)).not_to be_digital
      expect(build(:on_demand_master_variant)).not_to be_digital

      expect(digital_variant).to be_digital
      expect(master_digital_variant).to be_digital
    end
  end

  context "#destroy" do
    it "destroys associated links when destroyed" do
      line_item = create(:line_item, order: order, variant: digital_variant)
      line_item.create_digital_links
      links = line_item.digital_links

      expect(links.to_a.size).to eq(1)
      expect(links.first.line_item).to eq(line_item)
      expect {
        line_item.destroy
      }.to change(Spree::DigitalLink, :count).by(-1)
    end
  end
end
