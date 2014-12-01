class CreateTaskShares < ActiveRecord::Migration
  def self.up
    create_table :task_shares do |t|
    t.references :task
    t.references :user
    t.timestamps
    end
  end

  def self.down
    drop_table :task_shares
  end
end
