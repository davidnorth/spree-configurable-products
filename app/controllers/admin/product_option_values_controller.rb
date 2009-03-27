class Admin::ProductOptionValuesController < Admin::BaseController
  
  resource_controller
  belongs_to :product
    
  def values_for_select
    @option_type = OptionType.find(params[:option_type_id])
    respond_to do |wants|
      wants.js { render :text => @option_type.option_values.map{|ov| {:id => ov.id, :label => ov.presentation}}.to_json }
    end
  end
  
end
