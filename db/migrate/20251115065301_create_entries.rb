class CreateEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :entries do |t|
      t.date    :occurred_on, null: false               # 日付
      t.string  :description, null: false               # 内容
      t.integer :amount, null: false                   # 金額（正の整数）
      t.integer :direction, null: false                # income or expense
      t.references :category, foreign_key: true, null: true  # AI分類後、カテゴリIDが入る（未分類はNULL）

      t.timestamps
    end

    add_index :entries, :occurred_on
  end
end
