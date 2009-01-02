require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/new.html.erb" do
  include ContactsHelper
  
  before(:each) do
    assigns[:current_user] = mock_model(User)
    assigns[:users] = [ mock_model(User, :full_name => "Joe Spec") ]
    assigns[:contact] = stub_model(Contact,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/contacts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", contacts_path) do
    end
  end
end


