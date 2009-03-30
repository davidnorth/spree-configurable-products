require File.dirname(__FILE__) + '/../spec_helper'

describe Product do
  fixtures :option_types, :option_values, :products

  before(:each) do
    @product = products(:product_with_option_values)
  end

  it "should be valid" do
    @product.should be_valid
  end

end
