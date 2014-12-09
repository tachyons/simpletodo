class AddPositionToTaskShares < ActiveRecord::Migration
  def self.up
    add_column :task_shares, :position, :integer
  end

  def self.down
    remove_column :task_shares, :position
  end
end
