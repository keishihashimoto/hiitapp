class AddColumnGroupToHiitDates < ActiveRecord::Migration[6.0]
  def change
    add_reference :hiit_dates, :group, null: false, foreign_key: true
  end
end
