require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ProductOptionValuesHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the Admin::ProductOptionValuesHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(Admin::ProductOptionValuesHelper)
  end
  
end
