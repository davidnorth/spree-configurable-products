module ProductConfigurationHelper


  def product_configuration_select(option_type)
    select_tag "configuration[]", options_for_select(formatted_product_option_values_for_select(option_type))
  end

  def formatted_product_option_values_for_select(option_type)
    @product.product_option_values.for_option_type(option_type).map do |product_option_value|
      ["#{product_option_value.presentation} #{format_price_difference(product_option_value.price_difference)}", product_option_value.id]
    end
  end
  
  def format_price_difference(value)
    if value == 0.0
      return ''
    elsif value > 0
      prefix = '+'
    else
      prefix = '-'
    end
    "(#{prefix}#{format_price(value)})"
  end
  

end