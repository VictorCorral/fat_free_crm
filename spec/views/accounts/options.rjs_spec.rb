require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/options.rjs" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign
    assigns[:sort_by]  = "accounts.name ASC"
    assigns[:outline]  = "option_long"
    assigns[:per_page] = 20
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include_text('crm.flick("empty", "toggle")')
  end

  it "should hide [Create Account] form if it's visible" do
    render

    rendered.should include_text('crm.hide_form("create_account")')
  end

  describe "account options" do
    it "should render [options.html.haml] template into :options div and show it" do
      params[:cancel] = nil
      render
    
      rendered.should have_rjs("options") do |rjs|
        with_tag("input[type=hidden]") # @current_user
      end
      rendered.should include_text('crm.flip_form("options")')
      rendered.should include_text('crm.set_title("create_account", "Accounts Options")')
    end

    it "should call JavaScript functions to load preferences menus" do
      params[:cancel] = nil
      view.should_receive(:render).with(:partial => "common/sort_by")
      view.should_receive(:render).with(:partial => "common/per_page")
      view.should_receive(:render).with(:partial => "common/outline")

      render
    end
  end
  
  describe "cancel account options" do
    it "should hide account options form" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("options")
      rendered.should include_text('crm.flip_form("options")')
      rendered.should include_text('crm.set_title("create_account", "Accounts")')
    end
  end

end


