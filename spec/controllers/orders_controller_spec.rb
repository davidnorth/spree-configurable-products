require File.dirname(__FILE__) + '/../spec_helper'

describe OrdersController do
  before(:each) do
#    Variant.stub!(:find).with(any_args).and_return(@variant = mock_model(Variant, :price => 10, :on_hand => 50))
    @order = Order.new
    @order.stub!(:number).and_return("R100")
    controller.stub!(:find_order).and_return(@order)
  end

  describe "create" do
    fixtures :products, :product_option_values
    
    it "should add the variant to the order" do
      
      @product = products(:product_with_no_option_values)
      
      @product.stub!(:variants).and_return([mock_model(Variant, :price => 10, :on_hand => 50)])
      
      @order.should_receive(:add_variant).with(@variant, 2, [])
	    post :create, :product_id => products(:product_with_option_values).id, :quantity => 2
    end

    it "should add the variant including product option values" do
      
      product_option_values = [
        product_option_values(:large_is_five_pounds),
        product_option_values(:red_is_one_pound)
      ]
            
      @order.should_receive(:add_variant).with(@variant, 2, product_option_values)
	    post :create, :product_id => products(:product_with_option_values).id, :quantity => 2, :configuration => product_option_values.map{|pov| pov.id.to_s}

    end
  

  
  end

end
