class CreateHiits < ActiveRecord::Migration[6.0]
  def change
    create_table :hiits do |t|
      t.string :name, null: false
      t.string :active_time, null: false
      t.string :rest_time, null: false
      t.references :team, null: false, foreign_key: true
      t.timestamps
    end
  end
end
