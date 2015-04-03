class CheckListItem < ActiveRecord::Base
  belongs_to :check_list
  # attr_accessible :title, :body
end
