# == Schema Information
# Schema version: 15
#
# Table name: leads
#
#  id          :integer(4)      not null, primary key
#  uuid        :string(36)
#  user_id     :integer(4)
#  campaign_id :integer(4)
#  assigned_to :integer(4)
#  first_name  :string(64)      default(""), not null
#  last_name   :string(64)      default(""), not null
#  access      :string(8)       default("Private")
#  title       :string(64)
#  company     :string(64)
#  source      :string(32)
#  status      :string(32)
#  referred_by :string(64)
#  email       :string(64)
#  alt_email   :string(64)
#  phone       :string(32)
#  mobile      :string(32)
#  blog        :string(128)
#  linkedin    :string(128)
#  facebook    :string(128)
#  twitter     :string(128)
#  address     :string(255)
#  rating      :integer(4)      default(0), not null
#  do_not_call :boolean(1)      not null
#  notes       :text
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_one :contact
  named_scope :only, lambda { |filters| { :conditions => [ "status IN (?)" + (filters.delete("other") ? " OR status IS NULL" : ""), filters ] } }
  named_scope :converted, :conditions => "status='converted'"
  named_scope :for_campaign, lambda { |id| { :conditions => [ "campaign_id=?", id ] } }

  uses_mysql_uuid
  uses_user_permissions
  acts_as_commentable
  acts_as_paranoid

  validates_presence_of :first_name, :message => "^Please specify first name."
  validates_presence_of :last_name, :message => "^Please specify last name."
  validate :users_for_shared_access

  after_create :increment_leads_count

  # Save the lead along with its permissions.
  #----------------------------------------------------------------------------
  def save_with_permissions(users)
    if self[:access] == "Campaign" &&self[:campaign_id] # Copy campaign permissions.
      save_with_model_permissions(Campaign.find(self[:campaign_id]))
    else
      super(users) # invoke :save_with_permissions in plugin.
    end
  end

  # Promote the lead by creating contact and optional opportunity. Upon
  # successful promotion Lead status gets set to :converted.
  #----------------------------------------------------------------------------
  def promote(params)
    account     = Account.create_or_select_for(self, params[:account], params[:users])
    opportunity = Opportunity.create_for(self, account, params[:opportunity], params[:users])
    contact     = Contact.create_for(self, account, opportunity, params)

    return account, opportunity, contact
  end

  #----------------------------------------------------------------------------
  def convert(with_opportunity = true)
    update_attributes(:status => "converted")
    increment_opportunities_count if with_opportunity
  end

  #----------------------------------------------------------------------------
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  private
  #----------------------------------------------------------------------------
  def increment_leads_count
    if self.campaign_id
      Campaign.increment_counter(:leads_count, self.campaign_id)
    end
  end

  #----------------------------------------------------------------------------
  def increment_opportunities_count
    if self.campaign_id
      Campaign.increment_counter(:opportunities_count, self.campaign_id)
    end
  end

  # Make sure at least one user has been selected if the lead is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, "^Please specify users to share the lead with.") if self[:access] == "Shared" && !self.permissions.any?
  end

end
