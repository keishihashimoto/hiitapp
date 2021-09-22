class CreateUserHiits < ActiveRecord::Migration[6.0]
  def change
    create_table :user_hiits do |t|
      t.references :user, null: false
      t.references :hiit, null: false
      t.datetime :done_dates, null: false
      t.timestamps
    end
  end
end
