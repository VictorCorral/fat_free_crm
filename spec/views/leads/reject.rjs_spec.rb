require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/reject.js.rjs" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assign(:lead, @lead = Factory(:lead, :status => "new"))
    assign(:lead_status_total, { :contacted => 1, :converted => 1, :new => 1, :rejected => 1, :other => 1, :all => 5 })
  end

  it "should refresh current lead partial" do
    render

    rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
      with_tag("li[id=lead_#{@lead.id}]")
    end
    rendered.should match(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
  end

  it "should update sidebar filters when called from index page" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
    render

    rendered.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=filters]")
    end
    rendered.should match('$("filters").visualEffect("shake"')
  end

  it "should update sidebar summary when called from landing page" do
    render

    rendered.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=summary]")
    end
    rendered.should match('$("summary").visualEffect("shake"')
  end

  it "should update campaign sidebar if called from campaign landing page" do
    assign(:campaign, campaign = Factory(:campaign))
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render

    rendered.should have_rjs("sidebar") do |rjs|
      with_tag("div[class=panel][id=summary]")
      with_tag("div[class=panel][id=recently]")
    end
  end

end