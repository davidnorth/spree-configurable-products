class Admin::ProductOptionValuesController < Admin::BaseController
  
  resource_controller
  belongs_to :product
  
end
