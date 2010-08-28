require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/update.js.rjs" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign

    assign(:opportunity, @opportunity = Factory(:opportunity, :user => @current_user, :assignee => Factory(:user)))
    assign(:users, [ @current_user ])
    assign(:account, @account = Factory(:account))
    assign(:accounts, [ @account ])
    assign(:stage, Setting.unroll(:opportunity_stage))
    assign(:opportunity_stage_total, { :prospecting => 1, "Custom" => 1 })
  end

  describe "no errors:" do
    describe "on opportunity landing page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
      end

      it "should flip [edit_opportunity] form" do
        render
        rendered.should_not have_rjs("opportunity_#{@opportunity.id}")
        rendered.should include('crm.flip_form("edit_opportunity"')
      end

      it "should update sidebar" do
        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=summary]")
          with_tag("div[id=recently]")
        end
        rendered.should include('$("summary").visualEffect("shake"')
      end
    end

    describe "on opportunities index page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      end

      it "should replace [Edit Opportunity] with opportunity partial and highligh it" do
        render
        rendered.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
          with_tag("li[id=opportunity_#{@opportunity.id}]")
        end
        rendered.should include(%Q/$("opportunity_#{@opportunity.id}").visualEffect("highlight"/)
      end

      it "should update sidebar" do
        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        rendered.should include('$("filters").visualEffect("shake"')
      end
    end

    describe "on related asset page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should update recently viewed items" do
        render
        rendered.should have_rjs("recently") do |rjs|
          with_tag("div[class=caption]")
        end
      end

      it "should replace [Edit Opportunity] with opportunity partial and highligh it" do
        render
        rendered.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
          with_tag("li[id=opportunity_#{@opportunity.id}]")
        end
        rendered.should include(%Q/$("opportunity_#{@opportunity.id}").visualEffect("highlight"/)
      end
    end
  end

  describe "validation errors:" do
    before(:each) do
      @opportunity.errors.add(:name)
    end

    describe "on opportunity landing page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
      end

      it "should redraw the [edit_opportunity] form and shake it" do
        render
        rendered.should have_rjs("edit_opportunity") do |rjs|
          with_tag("form[class=edit_opportunity]")
        end
        rendered.should include('crm.create_or_select_account(false)')
        rendered.should include('$("edit_opportunity").visualEffect("shake"')
        rendered.should include('focus()')
      end
    end

    describe "on opportunities index page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      end

      it "should redraw the [edit_opportunity] form and shake it" do
        render
        rendered.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
          with_tag("form[class=edit_opportunity]")
        end
        rendered.should include('crm.create_or_select_account(false)')
        rendered.should include(%Q/$("opportunity_#{@opportunity.id}").visualEffect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on related asset page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = @referer = "http://localhost/accounts/123"
      end

      it "should show disabled accounts dropdown when called from accounts landing page" do
        render
        rendered.should include("crm.create_or_select_account(#{@referer =~ /\/accounts\//})")
      end

      it "should update related campaign sidebar from campaign landing page" do
        assign(:campaign, campaign = Factory(:campaign))
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
        render

        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[class=panel][id=summary]")
          with_tag("div[class=panel][id=recently]")
        end
      end

      it "should redraw the [edit_opportunity] form and shake it" do
        render
        rendered.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
          with_tag("form[class=edit_opportunity]")
        end
        rendered.should include(%Q/$("opportunity_#{@opportunity.id}").visualEffect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
