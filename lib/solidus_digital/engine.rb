module SolidusDigital
  class Engine < Rails::Engine
    engine_name 'solidus_digital'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer "spree.solidus_digital.preferences", before: "spree.environment" do |app|
      Spree::DigitalConfiguration = Spree::SpreeDigitalConfiguration.new
    end

    initializer "spree.register.digital_shipping", after: 'spree.register.calculators' do |app|
      app.config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::DigitalDelivery
    end

    initializer 'solidus_digital.custom_spree_splitters', after: 'spree.register.stock_splitters' do |app|
      app.config.spree.stock_splitters << Spree::Stock::Splitter::DigitalSplitter
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
