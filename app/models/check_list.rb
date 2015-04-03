class CheckList < ActiveRecord::Base
  belongs_to :task
  has_many :check_list_items
  # attr_accessible :title, :body
end
