class Task < ActiveRecord::Base
  belongs_to :user
  def next
    self.class.find(:first,:conditions =>"id > #{self.id} and user_id=#{self.user_id}")
  end

  def previous
    self.class.find(:last,:conditions =>"id < #{self.id} and user_id=#{self.user_id} ")
  end
end
