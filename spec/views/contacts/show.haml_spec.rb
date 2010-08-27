require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/show.html.haml" do
  include ContactsHelper

  before(:each) do
    login_and_assign
    assign(:contact, Factory(:contact, :id => 42))
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
  end

  it "should render contact landing page" do
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "common/_timeline")
    view.should render_template(:partial => "common/_tasks")
    view.should render_template(:partial => "opportunities/_opportunity")

    render

    rendered.should have_tag("div[id=edit_contact]")
  end

end

