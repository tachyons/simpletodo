class RemovePositionFromTasks < ActiveRecord::Migration
  def self.up
    remove_column :tasks, :position
  end

  def self.down
    add_column :tasks, :position, :integer
  end
end
