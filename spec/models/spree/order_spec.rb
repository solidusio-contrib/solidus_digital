# frozen_string_literal: true

require 'spec_helper'
require 'spree/testing_support/order_walkthrough'

RSpec.describe Spree::Order do
  context "contents.add" do
    let(:order) { create(:order) }

    it "adds digital Variants of quantity 1 to an order" do
      variants = 3.times.map { create(:variant, digitals: [create(:digital)]) }
      variants.each { |v| order.contents.add(v, 1) }

      expect(order.line_items.first.variant).to eq(variants[0])
      expect(order.line_items.second.variant).to eq(variants[1])
      expect(order.line_items.third.variant).to eq(variants[2])
    end

    it "handles quantity higher than 1 when adding one specific digital Variant" do
      digital_variant = create(:variant, digitals: [create(:digital)])
      order.contents.add digital_variant, 3
      expect(order.line_items.first.quantity).to eq(3)

      order.contents.add digital_variant, 2
      expect(order.line_items.first.quantity).to eq(5)
    end
  end

  context "line_item analysis" do
    let(:order) { create(:order) }

    it "understands that all products are digital" do
      3.times do
        order.contents.add create(:variant, digitals: [create(:digital)]), 1
      end
      expect(order.digital?).to be true

      order.contents.add create(:variant, digitals: [create(:digital)]), 4
      expect(order.digital?).to be true
    end

    it "understands that not all products are digital" do
      3.times do
        order.contents.add create(:variant, digitals: [create(:digital)]), 1
      end
      order.contents.add create(:variant), 1 # this is the analog product
      expect(order.digital?).to be false

      order.contents.add create(:variant, digitals: [create(:digital)]), 4
      expect(order.digital?).to be false
    end
  end

  describe '#digital?/#some_digital?' do
    let(:order) { create(:order) }
    let(:digital_order) {
      variants = 3.times.map { create(:variant, digitals: [create(:digital)]) }
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    let(:mixed_order) {
      variants = 2.times.map { create(:variant, digitals: [create(:digital)]) }
      variants << create(:variant)
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    let(:non_digital_order) {
      variants = 3.times.map { create(:variant) }
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    it 'returns true/true for a digital order' do
      expect(digital_order).to be_digital
      expect(digital_order).to be_some_digital
    end

    it 'returns false/true for a mixed order' do
      expect(mixed_order).not_to be_digital
      expect(mixed_order).to be_some_digital
    end

    it 'returns false/false for an exclusively non-digital order' do
      expect(non_digital_order).not_to be_digital
      expect(non_digital_order).not_to be_some_digital
    end
  end

  describe '#digital_line_items' do
    let(:order) { create(:order) }
    let(:digital_order_digitals) { 3.times.map { create(:digital) } }
    let(:digital_order) {
      variants = digital_order_digitals.map { |d| create(:variant, digitals: [d]) }
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    let(:mixed_order_digitals) { 2.times.map { create(:digital) } }
    let(:mixed_order) {
      variants = mixed_order_digitals.map { |d| create(:variant, digitals: [d]) }
      variants << create(:variant)
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    let(:non_digital_order) {
      variants = 3.times.map { create(:variant) }
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    it 'returns true/true for a digital order' do
      digital_order_digital_line_items = digital_order.digital_line_items
      expect(digital_order_digital_line_items.size).to eq(digital_order_digitals.size)

      variants = digital_order_digital_line_items.map(&:variant)
      variants.each { |variant| expect(variant).to be_digital }
      digital_order_digitals.each { |d| expect(variants).to include(d.variant) }
    end

    it 'returns false/true for a mixed order' do
      mixed_order_digital_line_items = mixed_order.digital_line_items
      expect(mixed_order_digital_line_items.size).to eq(mixed_order_digitals.size)

      variants = mixed_order_digital_line_items.map(&:variant)
      variants.each { |variant| expect(variant).to be_digital }
      mixed_order_digitals.each { |d| expect(variants).to include(d.variant) }
    end

    it 'returns an empty set for an exclusively non-digital order' do
      expect(non_digital_order.digital_line_items).to be_empty
    end
  end

  describe '#digital_links' do
    let(:mixed_order_digitals) { 2.times.map { create(:digital) } }
    let(:mixed_order) {
      order = create(:order)
      variants = mixed_order_digitals.map { |d| create(:variant, digitals: [d]) }
      variants << create(:variant)
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    it 'correctly loads the links' do
      mixed_order_digital_links = mixed_order.digital_links
      links_from_digitals = mixed_order_digitals.map(&:reload).map(&:digital_links).flatten
      expect(mixed_order_digital_links.size).to eq(links_from_digitals.size)

      mixed_order_digital_links.each do |l|
        expect(links_from_digitals).to include(l)
      end
    end
  end

  describe '#generate_digital_links' do
    let(:order) do
      if defined?(Spree::TestingSupport::OrderWalkthrough)
        Spree::TestingSupport::OrderWalkthrough
      else
        OrderWalkthrough
      end.up_to(:payment)
    end
    let!(:line_item) { create(:line_item, order: order, variant: digital_variant) }
    let!(:digital_variant) { create(:variant, digitals: [create(:digital)]) }
    let(:links) { order.digital_links }

    context "when order in complete state" do
      it "creates one link for a single digital Variant" do
        order.complete!

        expect(links.to_a.size).to eq(1)
        expect(links.first.line_item).to eq(line_item)
      end

      context "when line_items has quantity more than 1 " do
        before do
          line_item.quantity = 8
          line_item.save
        end

        it "creates a link for each quantity of a digital Variant, even when quantity changes later" do
          order.complete!

          expect(links.to_a.size).to eq(8)
          links.each { |link| expect(link.line_item).to eq(line_item) }
        end
      end
    end

    context "when order is in other state" do
      it "doesn't create a link for digital Variant" do
        expect(links.count).to eq(0)
      end
    end
  end

  describe '#reset_digital_links!' do
    let!(:order) { build(:order) }
    let!(:link_1) { double }
    let!(:link_2) { double }

    before do
      expect(link_1).to receive(:reset!)
      expect(link_2).to receive(:reset!)
      expect(order).to receive(:digital_links).and_return([link_1, link_2])
    end

    it 'calls reset on the links' do
      order.reset_digital_links!
    end
  end
end
