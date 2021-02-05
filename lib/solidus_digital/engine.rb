# frozen_string_literal: true

require 'spree/core'

module SolidusDigital
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace Spree

    engine_name 'solidus_digital'

    initializer "spree.solidus_digital.preferences", before: "spree.environment" do |_app|
      Spree::DigitalConfiguration = Spree::SpreeDigitalConfiguration.new
    end

    initializer "spree.register.digital_shipping", after: 'spree.register.calculators' do |app|
      app.config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::DigitalDelivery
    end

    initializer 'solidus_digital.custom_spree_splitters', after: 'spree.register.stock_splitters' do |app|
      app.config.spree.stock_splitters << Spree::Stock::Splitter::DigitalSplitter
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
