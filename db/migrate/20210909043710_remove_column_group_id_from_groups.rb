class RemoveColumnGroupIdFromGroups < ActiveRecord::Migration[6.0]
  def change
    remove_column :groups, :group_id, null: false, foreign_key: true
  end
end
