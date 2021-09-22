class RemoveColumnHiitDatesFromGroup < ActiveRecord::Migration[6.0]
  def up
    remove_column :groups :group
  end

  def down
    add_reference :groups, :group, null: false, foreign_key: true
  end

end
