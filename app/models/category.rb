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

  # ▼ 表示用の日本語ラベル
  def display_name
    case name
    when "food"         then "食費"
    when "daily_goods"  then "日用品"
    when "transport"    then "交通"
    when "hobby"        then "趣味・娯楽"
    when "other"        then "その他"
    when "salary"       then "給与"
    when "bonus"        then "賞与"
    when "side_income"  then "副収入"
    when "other_income" then "その他収入"
    else
      name # 想定外のものはそのまま返す（デバッグ用）
    end
  end
end
