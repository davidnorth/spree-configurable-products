$('document').ready(function(){
  
  $('#option_type_id').selectChain({
      target: $('#product_option_value_option_value_id'),
      url: option_values_url,
      data: { ajax: true }
  });
  
})