class Task < ActiveRecord::Base
  belongs_to :user
  def next
    self.class.find(:first,:conditions =>"position > #{self.position} and user_id=#{self.user_id}")
  end

  def previous
    self.class.find(:last,:conditions =>"position < #{self.position} and user_id=#{self.user_id} ")
  end
end
