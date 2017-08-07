class AddDrmFlagToDigitals < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_digitals, :drm, :boolean, default: false, null: false
  end
end
