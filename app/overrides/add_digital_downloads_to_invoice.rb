Deface::Override.new(
  virtual_path: "spree/shared/_order_details",
  name: "add_digital_downloads_to_invoice",
  insert_bottom: "td[data-hook='order_item_description']",
  partial: "spree/shared/digital_download_links"
)
