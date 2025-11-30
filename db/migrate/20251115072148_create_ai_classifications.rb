class CreateAiClassifications < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_classifications do |t|
      t.references :entry, null: false, foreign_key: true            # 対象の明細
      t.integer    :method, null: false                              # rule or ai
      t.bigint     :predicted_category_id, null: false               # 推定カテゴリ

      t.timestamps
    end

    add_foreign_key :ai_classifications, :categories, column: :predicted_category_id
    add_index :ai_classifications, :predicted_category_id
  end
end
