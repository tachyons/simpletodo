class CreateCheckLists < ActiveRecord::Migration
  def change
    create_table :check_lists do |t|
      t.references :task
      t.timestamps
    end
    add_index :check_lists, :task_id
  end
end
