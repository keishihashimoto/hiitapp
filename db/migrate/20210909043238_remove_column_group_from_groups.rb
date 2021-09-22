class RemoveColumnGroupFromGroups < ActiveRecord::Migration[6.0]
  def change
    def change
      remove_reference :groups, :group, null: false, foreign_key: true
    end
  end
end
