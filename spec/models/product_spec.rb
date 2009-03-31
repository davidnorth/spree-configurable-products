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
  
  it "should find correct configurable option types" do
    configurable_option_types = products(:product_with_option_values).configurable_option_types
    
    configurable_option_types.length.should == 2    
    configurable_option_types.should include(option_types(:size_option_type))
    configurable_option_types.should include(option_types(:color_option_type))
  end

end
