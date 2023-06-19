# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusDigital
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_digital'

    initializer "spree.register.digital_shipping" do |app|
      Rails.application.config.after_initialize do
        ::Spree::DigitalConfiguration = ::Spree::SpreeDigitalConfiguration.new
        app.config.spree.calculators.shipping_methods << ::Spree::Calculator::Shipping::DigitalDelivery
        app.config.spree.stock_splitters << ::Spree::Stock::Splitter::DigitalSplitter
      end
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
