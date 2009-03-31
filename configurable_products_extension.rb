# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ConfigurableProductsExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/configurable_products"

  # Please use configurable_products/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate

    # register Accessories product tab
    Admin::BaseController.class_eval do
      before_filter :add_accessories_tab
      
      private
      def add_accessories_tab
        @product_admin_tabs << {:name => t('product_option_values'), :url => "admin_product_product_option_values_url"}
      end
    end
        
    Product.class_eval do
      has_many :product_option_values, :include => :option_value, :order => 'option_values.option_type_id, price_difference'
      accepts_nested_attributes_for :product_option_values, :allow_destroy => true
      
      def cheapest_product_option_values
        product_option_values.find(:all, :group => 'option_values.option_type_id', :order => 'price_difference DESC')
      end

      def calculate_price_from
        sql = "SELECT MIN(price_difference) AS price_difference FROM product_option_values 
        INNER JOIN option_values ON option_values.id = product_option_values.option_value_id
        GROUP BY option_type_id"
        master_price + connection.select_all(sql).map{|r| r["price_difference"].to_f}.sum
      end
      
      before_save :store_price_from
      
      def store_price_from
        self.price_from = calculate_price_from
      end

      # Option types that a product option value has been added for
      def configurable_option_types
        product_option_values.map{|pov| pov.option_value.option_type}.uniq
      end
      
    end
    
    LineItem.class_eval do
      has_and_belongs_to_many :product_option_values

      validate :must_have_one_product_option_value_for_each_available_type
      validate :all_product_option_values_must_belong_to_product
      
      
      def must_have_one_product_option_value_for_each_available_type
        option_type_ids = product_option_values.map{|pov| pov.option_value.option_type_id}
        product_option_type_ids = variant.product.configurable_option_types.map(&:id)
        unless option_type_ids.sort == product_option_type_ids.sort
          errors.add(:product_option_values, "Incorrect product configuration, not all required options were selected")
        end
      end
      
      def all_product_option_values_must_belong_to_product
        unless product_option_values.all?{|pov| pov.product == variant.product}
          errors.add(:product_option_values, "Incorrect product configuration, invalid option selected")
        end
      end
      
      def configuration_description
        product_option_values.map {|pov| "#{pov.option_value.option_type.presentation}:#{pov.option_value.presentation}" }.join(', ')
      end
      
    end
    
    Order.class_eval do

      # Override this method to allow configuration to be stored and 
      # so that a new line item is added each time even for the same product
      def add_variant(variant, quantity=1, product_option_values = [])
        if current_item = contains?(variant, product_option_values)
          current_item.increment_quantity unless quantity > 1
          current_item.quantity = (current_item.quantity + quantity) if quantity > 1
          current_item.save
        else
          total_price = variant.price + product_option_values.sum(&:price_difference)
          current_item = LineItem.new(:quantity => quantity, :variant => variant, :price => total_price)
          current_item.product_option_values = product_option_values
          return nil unless current_item.save
          self.line_items << current_item
        end
        current_item
      end
      
      # Override to check if a variant exists in order with the same product configuration
      def contains?(variant, product_option_values = [])
        line_items.select do |line_item|
          line_item.variant == variant and line_item.product_option_values.map(&:id).sort == product_option_values.map(&:id).sort
        end.first
      end
      
    end
    
    OrdersController.class_eval do
      create.after do
        @product = Product.find(params[:product_id])
        @quantity = params[:quantity] ? params[:quantity].to_i : 1
        @product_option_values = params[:configuration] ? @product.product_option_values.find(params[:configuration]) : []
        @order.add_variant(@product.variants.active.first, @quantity, @product_option_values)
        @order.save
      end
    end
    
    ProductsController.class_eval do
      helper :product_configuration
      
      def update_configuration_price
        product_option_values = object.product_option_values.find(params[:configuration])
        @new_price = object.master_price + product_option_values.sum(&:price_difference)
        render :action => 'update_configuration_price', :layout => false
      end
      
    end

  end
end