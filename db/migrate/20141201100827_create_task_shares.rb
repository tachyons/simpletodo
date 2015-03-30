class CreateTaskShares < ActiveRecord::Migration
  def self.up
    create_table :task_shares do |t|
    t.references :task
    t.references :user
    t.timestamps
    # add_index :task_shares, [:user_id, :task_id]
    end
  end

  def self.down
    drop_table :task_shares
  end
end
