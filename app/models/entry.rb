class Entry < ApplicationRecord
  belongs_to :category, optional: true   # AIが分類するまではNULL

  has_many :ai_classifications, dependent: :destroy

  enum :direction, { income: 0, expense: 1 }

  validates :occurred_on, presence: true
  validates :description, presence: true
  validates :amount,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :direction, presence: true

  # カテゴリ未設定で、説明があるときだけルールベース分類を実行
  before_validation :assign_category_by_rule, if: -> { category_id.blank? && description.present? }

  private

  def assign_category_by_rule
    # ルールベース分類の結果（例：:food, :transport, :salary, :other）
    category_key = ::RuleBasedCategorizer.call(
      direction: direction,        # "expense" or "income"（enumの文字列）
      description: description,
      amount: amount
    )

    # 判定できなかった / other の場合は何もしない
    return if category_key.blank? || category_key.to_sym == :other

    # categories.name に "food" / "salary" などを入れておく想定
    self.category ||= Category.find_by(name: category_key.to_s)
  end
end
