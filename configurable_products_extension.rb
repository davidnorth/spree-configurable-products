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
      has_many :product_option_values, :include => {:option_value => :option_type}, :order => 'option_types.presentation, option_values.name'
      accepts_nested_attributes_for :product_option_values, :allow_destroy => true
    end
    
    LineItem.class_eval do
      has_and_belongs_to_many :product_option_values
    end
        
    ProductsController.class_eval do
      helper :product_configuration
    end

  end
end