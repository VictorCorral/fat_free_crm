require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/destroy.js.rjs" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
    assign(:campaign, @campaign = Factory(:campaign, :user => @current_user))
    assign(:campaigns, [ @campaign ].paginate)
    assign(:campaign_status_total, { :called_off => 1, :completed => 1, :on_hold => 1, :planned => 1, :started => 1, :other => 1, :all => 6 })
    render
  end

  it "should blind up destroyed campaign partial" do
    rendered.should include(%Q/$("campaign_#{@campaign.id}").visualEffect("blind_up"/)
  end

  it "should update Campaigns sidebar" do
    rendered.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
    rendered.should include('$("filters").visualEffect("shake"')
  end

  it "should update pagination" do
    rendered.should have_rjs("paginate")
  end

end
