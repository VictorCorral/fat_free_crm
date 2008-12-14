# == Schema Information
# Schema version: 10
#
# Table name: campaigns
#
#  id                :integer(4)      not null, primary key
#  uuid              :string(36)
#  user_id           :integer(4)
#  name              :string(64)      default(""), not null
#  status            :string(64)
#  budget            :decimal(12, 2)
#  target_leads      :integer(4)
#  target_conversion :float
#  target_revenue    :decimal(12, 2)
#  actual_leads      :integer(4)
#  actual_conversion :float
#  actual_revenue    :decimal(12, 2)
#  starts_on         :date
#  ends_on           :date
#  objectives        :text
#  deleted_at        :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

class Campaign < ActiveRecord::Base
  belongs_to :user
  acts_as_paranoid

  validates_presence_of :name, :message => "^Please specify campaign name."
  validates_uniqueness_of :name, :scope => :user_id
  before_create :set_campaign_status

  # Make sure end date > start date.
  #----------------------------------------------------------------------------
  def validate
    if (self.starts_on && self.ends_on) && (self.starts_on > self.ends_on)
      errors.add(:ends_on, "^Please make sure the campaign end date is after the start date.")
    end
  end

  private
  #----------------------------------------------------------------------------
  def set_campaign_status
    if self.ends_on and (self.ends_on < Date.today)
      self.status = "Completed"
    else
      self.status = self.starts_on && (self.starts_on <= Date.today) ? "Started" : "Planned"
    end
  end

end
