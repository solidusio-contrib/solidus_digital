# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Stock
    module Splitter
      RSpec.describe DigitalSplitter do
        subject { described_class.new(stock_location) }

        let(:item1) { create(:inventory_unit, variant: create(:digital).variant) }
        let(:item2) { create(:inventory_unit, variant: create(:variant)) }
        let(:item3) { create(:inventory_unit, variant: create(:variant)) }
        let(:item4) { create(:inventory_unit, variant: create(:digital).variant) }
        let(:item5) { create(:inventory_unit, variant: create(:digital).variant) }

        let(:stock_location) { mock_model(Spree::StockLocation) }

        it 'splits each package by product' do
          package1 = Package.new(stock_location)
          package1.add item1, :on_hand
          package1.add item2, :on_hand
          package1.add item3, :on_hand
          package1.add item4, :on_hand
          package1.add item5, :on_hand

          packages = subject.split([package1])

          expect(packages[0].quantity).to eq 3
          expect(packages[1].quantity).to eq 2
        end
      end
    end
  end
end
