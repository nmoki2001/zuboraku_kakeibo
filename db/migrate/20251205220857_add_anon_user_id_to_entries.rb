class AddAnonUserIdToEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :entries, :anon_user_id, :string
    add_index :entries, :anon_user_id
  end
end
