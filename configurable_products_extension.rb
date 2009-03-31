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

    end
    
    LineItem.class_eval do
      has_and_belongs_to_many :product_option_values
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