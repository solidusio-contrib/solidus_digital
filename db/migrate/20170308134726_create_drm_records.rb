# frozen_string_literal: true

class CreateDrmRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_drm_records do |t|
      t.integer :digital_id
      t.integer :line_item_id
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.timestamps
    end
    add_index :spree_drm_records, :digital_id
    add_index :spree_drm_records, :line_item_id
  end
end
