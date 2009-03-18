require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/index.html.erb" do
  include ContactsHelper
  
  before(:each) do
  end

  it "should render list of accounts if list of contacts is not empty" do
    assigns[:contacts] = [ Factory(:contact) ]
    template.should_receive(:render).with(hash_including(:partial => "contact"))
    render "/contacts/index.html.haml"
  end

end

