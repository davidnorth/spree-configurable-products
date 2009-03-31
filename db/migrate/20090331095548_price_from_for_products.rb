class PriceFromForProducts < ActiveRecord::Migration
  def self.up
    add_column "products", "price_from", :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column "products", "price_from"
  end
end