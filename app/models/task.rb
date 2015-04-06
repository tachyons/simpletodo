class Task < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :task_shares
  has_many :shared_users,:class_name=>'User', :through => :task_shares
  attr_accessible :name,:position,:status
  after_create :initialise_sharetask
  has_one :check_list
  scope :active, -> { where(:status => false) }
  scope :inactive, -> { where(:status=> true) }
  def find_next_task_by_position_and_user_id(position,user_id)
    user=User.find_by_id(user_id)
    user.shared_tasks.active.joins(:task_shares).select("tasks.*,task_shares.position").where("task_shares.position>#{position}").order("task_shares.position DESC").last
  end
  def find_previous_task_by_position_and_user_id(position,user_id)
    user=User.find_by_id(user_id)
    user.shared_tasks.active.joins(:task_shares).select("tasks.*,task_shares.position").where("task_shares.position<#{position}").order("task_shares.position DESC").first
  end
  def self.find_by_position(position)
    Task.joins(:task_shares).select("tasks.*,position").where("task_shares.position=#{position}").first
  end
  def self.search(search,status="all")  
    if search
      if status=="all"
        where('name LIKE ?', "%#{search}%")
      elsif status=="active"
        where('name LIKE ? and status=?', "%#{search}%",false)
      elsif status=="inactive"
        where('name LIKE ? and status=?', "%#{search}%",true)
      end
    else  
      scoped  
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
