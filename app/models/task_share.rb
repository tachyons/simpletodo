class TaskShare < ActiveRecord::Base
	belongs_to :shared_task,:foreign_key => "task_id"
	belongs_to :shared_user,:foreign_key => "user_id"
end
