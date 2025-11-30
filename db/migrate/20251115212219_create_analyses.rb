class CreateAnalyses < ActiveRecord::Migration[7.2]
  def change
    create_table :analyses do |t|
      t.text :good_points, null: false       # 良い点（AI生成）
      t.text :improvements, null: false      # 改善点（AI生成）

      t.timestamps                           # created_at を「分析実行日時」として使う
    end

    add_index :analyses, :created_at
  end
end
