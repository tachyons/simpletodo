class Task < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  attr_accessible :name,:position,:status
  def next
    self.class.find(:first,:conditions =>"position > #{self.position} and user_id=#{self.user_id} ",:order => 'position')
  end

  def previous
    self.class.find(:last,:conditions =>"position < #{self.position} and user_id=#{self.user_id} ",:order => 'position')
  end
  def next_completed_task
    self.class.find(:first,:conditions =>"position > #{self.position} and user_id=#{self.user_id} and status=1",:order => 'position')
  end

  def previous_completed_task
    self.class.find(:last,:conditions =>"position < #{self.position} and user_id=#{self.user_id} and status=1",:order => 'position')
  end
  def next_active_task
    self.class.find(:first,:conditions =>"position > #{self.position} and user_id=#{self.user_id} and status=0",:order => 'position')
  end

  def previous_active_task
    self.class.find(:last,:conditions =>"position < #{self.position} and user_id=#{self.user_id} and status=0",:order => 'position')
  end
end
