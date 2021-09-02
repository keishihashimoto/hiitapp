class AddIndexMenusName < ActiveRecord::Migration[6.0]
  def change
    add_index :menus, :name, unique: true
  end
end
