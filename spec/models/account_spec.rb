# == Schema Information
# Schema version: 27
#
# Table name: accounts
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  assigned_to     :integer(4)
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Private")
#  website         :string(64)
#  toll_free_phone :string(32)
#  phone           :string(32)
#  fax             :string(32)
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  email           :string(64)
#  background_info :string(255)
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Account do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Account.create!(:name => "Test Account", :user => Factory(:user))
  end

  describe "Discard" do
    before do
      @account = Factory(:account)
    end

    it "should discard a task" do
      @task = Factory(:task, :asset => @account, :user => @current_user)
      @account.tasks.count.should == 1

      @account.discard!(@task)
      @account.reload.tasks.should == []
      @account.tasks.count.should == 0
    end

    it "should discard a contact" do
      @contact = Factory(:contact)
      @account.contacts << @contact
      @account.contacts.count.should == 1

      @account.discard!(@contact)
      @account.contacts.should == []
      @account.contacts.count.should == 0
    end

    it "should discard an opportunity" do
      @opportunity = Factory(:opportunity)
      @account.opportunities << @opportunity
      @account.opportunities.count.should == 1

      @account.discard!(@opportunity)
      @account.opportunities.should == []
      @account.opportunities.count.should == 0
    end
  end
end
