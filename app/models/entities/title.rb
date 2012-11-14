class Title < ActiveRecord::Base
  has_and_belongs_to_many :title_groups
end
