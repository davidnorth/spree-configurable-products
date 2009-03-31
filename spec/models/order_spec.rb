require File.dirname(__FILE__) + '/../spec_helper'

describe Order do
  fixtures :option_types, :option_values, :product_option_values, :products

  before(:each) do
    @variant = Variant.new(:id => "1234", :price => 7.99, :product => products(:product_with_no_option_values))
    @inventory_unit = mock_model(InventoryUnit, :null_object => true)
    @creditcard_payment = mock_model(CreditcardPayment, :null_object => true)
    @user = mock_model(User, :email => "foo@exampl.com")

    @order = Order.new
    @order.checkout_complete = true
    @order.creditcard_payments = [@creditcard_payment]
    @order.number = '#TEST1010'
    @order.user =  @user

    @order.stub!(:save => true, :inventory_units => [@inventory_unit])
    @line_item =  LineItem.new(:variant => @variant, :quantity => 1, :price => 7.99)
    @order.line_items << @line_item
    InventoryUnit.stub!(:retrieve_on_hand).with(@variant, 1).and_return [@inventory_unit]
    OrderMailer.stub!(:deliver_confirm).with(any_args)   
    OrderMailer.stub!(:deliver_cancel).with(any_args)    
  end
  

  describe "add_variant" do

    it "should add new line item if product does not currently existing in order" do
      @variant2 = mock_model(Variant, :id => "5678", :on_hand => 10, :product => products(:product_with_no_option_values), :price => 9.99)      
      @order.line_items.size.should == 1
      @order.add_variant(@variant2)
      @order.line_items.size.should == 2
    end
    
    it "should change quantity if variant already exists in order for product with no option values" do
      @variant2 = mock_model(Variant, :id => "5678", :on_hand => 10, :product => products(:product_with_no_option_values), :price => 9.99)      
      @order.line_items.size.should == 1
      @order.add_variant(@variant2)
      @order.line_items.size.should == 2
      @order.add_variant(@variant2)
      @order.line_items.size.should == 2
    end

    it "should store product option values in line item and calculate correct price" do
      @product = products(:product_with_option_values)
      product_option_values = [
        product_option_values(:large_is_five_pounds),
        product_option_values(:red_is_one_pound)
      ]
      @variant2 = mock_model(Variant, :id => 5678, :on_hand => 10, :product => @product, :price => 10.00)
      @order.line_items.size.should == 1
      @order.add_variant(@variant2, 1, product_option_values)
      @order.line_items.size.should == 2
      

      new_line_item = @order.line_items.detect{|li| li.variant_id ==  @variant2.id}
      new_line_item.product_option_values.length.should == 2
      
      new_line_item.price.to_f.should == 16.00
    end
    
    it "should not add variant without product option values" do
      @product = products(:product_with_option_values)
      @variant2 = mock_model(Variant, :id => 5678, :on_hand => 10, :product => @product, :price => 10.00)
      @order.line_items.size.should == 1
      @order.add_variant(@variant2, 1, [])
      @order.line_items.size.should == 1
    end
    
    it "should not allow invalid product option values to be used" do
      @product = products(:product_with_option_values)
      @variant2 = mock_model(Variant, :id => 5678, :on_hand => 10, :product => @product, :price => 10.00)
      @order.line_items.size.should == 1

      # one for each required option type but one belongs to the wrong product
      product_option_values = [
        product_option_values(:large_is_free_for_some_other_product),
        product_option_values(:red_is_one_pound)
      ]

      @order.add_variant(@variant2, 1, product_option_values)
      @order.line_items.size.should == 1
    end
    
    it "should increment quantity of existing line item if product configuration is the same" do
      @product = products(:product_with_option_values)

      product_option_values = [
        product_option_values(:large_is_five_pounds),
        product_option_values(:red_is_one_pound)
      ]
      @variant2 = mock_model(Variant, :id => 5678, :on_hand => 10, :product => @product, :price => 10.00)
      @order.line_items.size.should == 1
      @order.add_variant(@variant2, 1, product_option_values)
      @order.line_items.size.should == 2
      
      @order.add_variant(@variant2, 2, product_option_values)
      @order.line_items.size.should == 2

      
      new_line_item = @order.line_items.detect{|li| li.variant_id ==  @variant2.id}
      new_line_item.quantity.should == 3

    end

    it "should create a new line item for same variant if configuration is different" do
      @product = products(:product_with_option_values)

      product_option_values = [
        product_option_values(:large_is_five_pounds),
        product_option_values(:red_is_one_pound)
      ]
      @variant2 = mock_model(Variant, :id => 5678, :on_hand => 10, :product => @product, :price => 10.00)
      @order.line_items.size.should == 1
      @order.add_variant(@variant2, 1, product_option_values)
      @order.line_items.size.should == 2
      
      product_option_values = [
        product_option_values(:small_is_free),
        product_option_values(:red_is_one_pound)
      ]
      @order.add_variant(@variant2, 2, product_option_values)
      @order.line_items.size.should == 3

      
    end

  end

end
