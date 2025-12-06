class Entry < ApplicationRecord
  # --- Associations ---
  belongs_to :category, optional: true
  has_many :ai_classifications, dependent: :destroy

  # anon_user_id カラム（string）は migration で追加済み
  # belongs_to :user などの関連は使わない（ログインなし運用）

  # --- Enum ---
  enum :direction, { income: 0, expense: 1 }

  # --- Validations ---
  validates :occurred_on, presence: true
  validates :description, presence: true
  validates :amount,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :direction, presence: true
  validates :anon_user_id, presence: true  # ★ 重要：必ず匿名ユーザーIDを持つ

  # --- Automatic Categorization ---
  before_validation :assign_category_automatically,
                    if: -> { category_id.blank? && description.present? }

  # --- Scopes ---
  scope :for_anon_user, ->(anon_user_id) { where(anon_user_id: anon_user_id) }

  private

  # =========================================================
  #  カテゴリ自動分類
  # =========================================================
  def assign_category_automatically
    # ① ルールベース分類
    rule_key = ::RuleBasedCategorizer.call(
      direction: direction,
      description: description,
      amount: amount
    )

    if rule_key.present? && rule_key.to_sym != :other
      if (found = Category.find_by(name: rule_key.to_s))
        self.category = found
        return   # ルールで決まれば終了
      end
    end

    # ② ルールで決まらなかったら AI に分類させる
    ai_key = ::AiCategorizer.call(
      direction: direction,
      description: description,
      amount: amount,
      occurred_on: occurred_on,
      # ★ 匿名ユーザーで将来学習させたいならここで渡してもOK
      # anon_user_id: anon_user_id
    )

    Rails.logger.info("[Entry] ai_key=#{ai_key.inspect} for desc=#{description.inspect}")

    return if ai_key.blank? # :other の場合はカテゴリ未設定のままにする

    self.category ||= Category.find_by(name: ai_key.to_s)
  end
end
