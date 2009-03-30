# Represents the availability and price impact of a particular OptionValue for a product
# Line items are assigned to this model to represent the customer's chosen product configuration and the the 
# line item price is calculated from the product's master_price plus the price difference of their chosen product option values
class ProductOptionValue < ActiveRecord::Base
  
  belongs_to :product
  belongs_to :option_value
  has_and_belongs_to_many :line_items
  
  validates_presence_of :price_difference, :product, :option_value

  named_scope :for_option_type, lambda {|option_type| { :include => :option_value, :conditions => {'option_values.option_type_id' => option_type.id} } }

  delegate :name, :presentation, :to => :option_value

end
