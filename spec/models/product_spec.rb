require File.dirname(__FILE__) + '/../spec_helper'

describe Product do
  fixtures :option_types, :option_values, :product_option_values, :products

  before(:each) do
  end

  it "should calculate the correct price from" do
    products(:product_with_option_values).calculate_price_from.should == 11.00
    product_option_values(:red_is_one_pound).update_attribute(:price_difference, 0.0)
    products(:product_with_option_values).calculate_price_from.should == 10.00
  end

  it "should cache price from when saving" do
    product = products(:product_with_option_values)
    product.save
    product.price_from.to_f.should == 11.0
  end

end
