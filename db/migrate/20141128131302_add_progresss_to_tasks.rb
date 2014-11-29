class AddProgresssToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :progress, :integer, :default => 0
  end

  def self.down
    remove_column :tasks, :progress
  end
end
