# Represents the availability and price impact of a particular OptionValue for a product
# Line items are assigned to this model to represent the customer's chosen product configuration and the the 
# line item price is calculated from the product's master_price plus the price difference of their chosen product option values
class ProductOptionValue < ActiveRecord::Base
  
  belongs_to :product
  belongs_to :option_value
  has_and_belongs_to_many :line_items
  
end
