class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :name
      t.integer :order
      t.boolean :status
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
