class TaskShare < ActiveRecord::Base
	belongs_to :shared_task,:foreign_key => "task_id" ,:class_name=> "Task"
	belongs_to :shared_user,:foreign_key => "user_id",:class_name=>"User"
	def self.swap_elements(pos1,pos2)
		task_share_one=TaskShare.find_by_position(pos1)
		task_share_two=TaskShare.find_by_position(pos2)
		task_share_one.position,task_share_two.position=task_share_two.position,task_share_one.position
		task_share_one.save!
		task_share_two.save!
	end
	# def self.find_by_user_and_task(user_id,task_id)

	# end
end
