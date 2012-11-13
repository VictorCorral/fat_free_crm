class TitleGroup < ActiveRecord::Base
  belongs_to :contact
  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :titles
  def title_names
    titles.pluck(:name).join(", ")
  end
end
