class Task < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :task_shares
  has_many :shared_users,:class_name=>'User', :through => :task_shares
  attr_accessible :name,:position,:status
  after_create :initialise_sharetask
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
  def self.find_task_by_position_and_user_id(position,user_id)
    user=User.find_by_id(user_id)
    @task=user.shared_tasks.find(:first,:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position DESC",:conditions => "status = 0 AND task_shares.position=#{position}")
  end
  def find_next_task_by_position_and_user_id(position,user_id)
    user=User.find_by_id(user_id)
    @task=user.shared_tasks.find(:first,:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position DESC",:conditions => "status = 0 AND task_shares.position>#{position}")
  end
  def self.find_previous_task_by_position_and_user_id(position,user_id)
    user=User.find_by_id(user_id)
    @task=user.shared_tasks.find(:last,:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position DESC",:conditions => "status = 0 AND task_shares.position<#{position}")
  end
  def find_previous_task_by_position_and_user_id(position,user_id)
    user=User.find_by_id(user_id)
    @task=user.shared_tasks.find(:last,:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position DESC",:conditions => "status = 0 AND task_shares.position<#{position}")
  end
  def self.search(search)
    if search
      find(:all, :conditions => ['name LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
  private 
    def initialise_sharetask
      ts=TaskShare.new
      ts.task_id=self.id;
      ts.user_id=self.user_id
      unless TaskShare.last.nil?
        ts.position=TaskShare.last.id+1
      else
        ts.position=1
      end
      ts.save!
    end
end
