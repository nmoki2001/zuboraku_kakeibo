class Category < ApplicationRecord
  # ▼ 種別（支出 or 収入）のenum
  enum kind, { expense: 0, income: 1 }

  # ▼ Entryとの関連付け（カテゴリに属する明細）
  has_many :entries, dependent: :nullify

  # ▼ AiClassification で predicted_category として使われる関連
  has_many :ai_classifications,
           foreign_key: :predicted_category_id,
           dependent: :nullify

  # ▼ バリデーション
  validates :name, presence: true
  validates :kind, presence: true
end
