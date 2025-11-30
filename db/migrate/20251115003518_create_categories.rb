class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string  :name, null: false
      t.integer :kind, null: false, default: 0  # 0: expense, 1: income

      t.timestamps
    end

    add_index :categories, :name
  end
end
