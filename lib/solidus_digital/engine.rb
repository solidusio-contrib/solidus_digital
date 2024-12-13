# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusDigital
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_digital'

    initializer "solidus_digital.zeitwerk_ignore_deface_overrides", before: :eager_load! do |app|
      app.autoloaders.main.ignore(root.join('app/overrides'))
    end

    initializer "solidus_digital.preferences", before: "spree.environment" do |_app|
      ::Spree::DigitalConfiguration = ::Spree::SpreeDigitalConfiguration.new
    end

    initializer "solidus_digital.digital_shipping", after: "spree.environment" do |app|
      app.config.spree.calculators.shipping_methods << "Spree::Calculator::Shipping::DigitalDelivery"
    end

    initializer "solidus_digital.digital_splitter", after: "spree.environment" do |app|
      app.config.spree.stock_splitters << "Spree::Stock::Splitter::DigitalSplitter"
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
