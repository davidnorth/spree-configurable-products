map.namespace :admin do |admin|

  admin.resources :products do |product|
    product.resources :product_option_values, :collection => {:values_for_select => :get, :update_all => :put}
  end

end