class TitleGroup < ActiveRecord::Base
  belongs_to :contact
  has_and_belongs_to_many :accounts, :uniq => true
  has_and_belongs_to_many :titles, :uniq => true
  accepts_nested_attributes_for :accounts, :allow_destroy => true
  accepts_nested_attributes_for :titles, :allow_destroy => true
  def title_names
    titles.pluck(:name).join(", ")
  end
end
