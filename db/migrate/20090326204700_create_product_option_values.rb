class CreateProductOptionValues < ActiveRecord::Migration
  def self.up

    create_table :product_option_values do |t|
      t.timestamps
      t.integer :product_id, :option_value_id
	    t.decimal :price_difference, :precision => 8, :scale => 2, :default => 0.00
    end

    create_table :line_items_product_option_values do |t|
      t.integer :line_item_id, :product_option_value_id
    end

  end

  def self.down
    drop_table :product_option_values
    drop_table :line_items_product_option_values
  end
end
