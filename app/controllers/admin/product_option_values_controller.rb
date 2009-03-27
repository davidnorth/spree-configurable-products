class Admin::ProductOptionValuesController < Admin::BaseController

  resource_controller
  belongs_to :product

  create.fails.response do |wants|
    wants.html do
      flash[:error] = 'Failed to create property value'
      render :action => 'index' 
    end
  end

  create.response do |wants|
    wants.html { redirect_to collection_url }
  end


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
  
  def update_all
    @product = parent_object
    @product.attributes = params[:product]
    if @product.save
      flash[:notice] = "Properties updated"
    else
      flash[:error] = "Failed to update properties"
    end
    redirect_to collection_url
  end

end
