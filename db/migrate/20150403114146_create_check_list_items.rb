class CreateCheckListItems < ActiveRecord::Migration
  def change
    create_table :check_list_items do |t|
      t.references :check_list

      t.timestamps
    end
    add_index :check_list_items, :check_list_id
  end
end
