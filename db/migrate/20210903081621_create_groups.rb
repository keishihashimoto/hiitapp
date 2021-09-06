class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.references :hiit, null: false, foreingn_key: true
      t.references :team, null: false, foreingn_key: true
      t.timestamps
    end
  end
end
