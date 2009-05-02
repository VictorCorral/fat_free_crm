require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/destroy.js.rjs" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
    assigns[:campaign] = @campaign = Factory(:campaign, :user => @current_user)
    assigns[:campaigns] = [ @campaign ].paginate
    render "campaigns/destroy.js.rjs"
  end

  it "should blind up destroyed campaign partial" do
    response.should include_text(%Q/$("campaign_#{@campaign.id}").visualEffect("blind_up"/)
  end

  it "should update Campaigns sidebar" do
    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
    response.should include_text('$("filters").visualEffect("shake"')
  end

  it "should update pagination" do
    response.should have_rjs("paginate")
  end

end
