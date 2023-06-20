# frozen_string_literal: true

require 'spree/preferences/configuration'

module Spree
  class SpreeDigitalConfiguration < Preferences::Configuration
    # number of times a customer can download a digital file
    # nil - infinite number of clicks
    preference :authorized_clicks, :integer, default: 3

    # number of days after initial purchase the customer can download a file
    preference :authorized_days, :integer, default: 2

    # should digitals be kept around after the associated product is destroyed
    preference :keep_digitals, :boolean, default: false

    # number of seconds before an s3 link expires
    preference :s3_expiration_seconds, :integer, default: 10

    # number of digital links generated per line item
    # accepts: 'quantity' or Integer numbers
    # quantity - 'line_item.quantity' digital links will be generated
    # Integer 'number' - 'number' digital links will be generated
    preference :digital_links_count, :string, default: 'quantity'
  end
end
