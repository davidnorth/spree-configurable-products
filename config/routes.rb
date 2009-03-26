map.namespace :admin do |admin|

  admin.resources :products do |product|
    product.resources :product_option_values
  end

end