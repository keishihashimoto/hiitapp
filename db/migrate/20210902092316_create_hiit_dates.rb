class CreateHiitDates < ActiveRecord::Migration[6.0]
  def change
    create_table :hiit_dates do |t|
      t.references :hiit, null: false, foreign_key: true
      t.integer :date, null: false
      t.timestamps
    end
  end
end
