class Category < ApplicationRecord
  # ▼ 種別（支出 or 収入）のenum
  enum :kind, { expense: 0, income: 1 }

  # ▼ Entryとの関連付け（カテゴリに属する明細）
  has_many :entries, dependent: :nullify

  # ▼ AiClassification で predicted_category として使われる関連
  has_many :ai_classifications,
           foreign_key: :predicted_category_id,
           dependent: :nullify

  # ▼ バリデーション
  validates :name, presence: true
  validates :kind, presence: true

  # ▼ カテゴリキー → 日本語表示名
  CATEGORY_LABELS = {
    "food"         => "食費",
    "daily_goods"  => "日用品",
    "transport"    => "交通",
    "hobby"        => "趣味・娯楽",
    "other"        => "その他",
    "salary"       => "給与",
    "bonus"        => "賞与",
    "side_income"  => "副収入",
    "other_income" => "その他収入"
  }.freeze

  def display_name
    CATEGORY_LABELS[name] || name
  end
end
