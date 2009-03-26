require File.dirname(__FILE__) + '/../spec_helper'

describe ProductOptionValue do
  before(:each) do
    @product_option_value = ProductOptionValue.new
  end

  it "should be valid" do
    @product_option_value.should be_valid
  end
end
