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
    
    Product.class_eval do
      has_many :product_option_values
    end
    
    LineItem.class_eval do
      
      has_and_belongs_to_many :product_option_values
      
    end

  end
end