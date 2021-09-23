class DeleteNameIndexFromMenu < ActiveRecord::Migration[6.0]
  def change
    remove_index :menus, :name
  end
end