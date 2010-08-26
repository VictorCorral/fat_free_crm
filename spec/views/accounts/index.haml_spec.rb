require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index.html.haml" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render a proper account website link if an account is provided" do
    assigns[:accounts] = [ Factory(:account, :website => 'www.fatfreecrm.com'), Factory(:account) ].paginate
    render
    rendered.should have_tag("a[href=http://www.fatfreecrm.com]")
  end

  it "should render list of accounts if list of accounts is not empty" do
    assigns[:accounts] = [ Factory(:account), Factory(:account) ].paginate
    view.should_receive(:render).with(hash_including(:partial => "account"))
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end

  it "should render a message if there're no accounts" do
    assigns[:accounts] = [].paginate
    view.should_not_receive(:render).with(hash_including(:partial => "account"))
    view.should_receive(:render).with(:partial => "common/empty")
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end
end

