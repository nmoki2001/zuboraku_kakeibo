class AiClassification < ApplicationRecord
  belongs_to :entry

  # 推定されたカテゴリ（Category モデル）への関連
  belongs_to :predicted_category,
             class_name: "Category"

  # ルール判定かAI判定か
  enum :method, { rule: 0, ai: 1 }

  validates :method, presence: true
end
