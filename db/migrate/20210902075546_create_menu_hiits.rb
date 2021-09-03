class CreateMenuHiits < ActiveRecord::Migration[6.0]
  def change
    create_table :menu_hiits do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :hiit, null: false, foreign_key: true
      t.timestamps
    end
  end
end
