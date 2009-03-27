class Admin::ProductOptionValuesController < Admin::BaseController
  
  resource_controller
  belongs_to :product
    
  def values_for_select
    begin
      @option_type = OptionType.find(params[:option_type_id])
      @data = @option_type.option_values.map{|ov| {:id => ov.id, :label => ov.presentation}}
    rescue
      @data = []
    end
    respond_to do |wants|
      wants.js { render :text => @data.to_json }
    end
  end
  
end
