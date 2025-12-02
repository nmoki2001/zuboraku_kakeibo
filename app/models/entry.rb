class Entry < ApplicationRecord
  belongs_to :category, optional: true
  has_many :ai_classifications, dependent: :destroy

  enum :direction, { income: 0, expense: 1 }

  validates :occurred_on, presence: true
  validates :description, presence: true
  validates :amount,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :direction, presence: true

  # カテゴリ未設定で説明があるときだけ自動分類
  before_validation :assign_category_automatically,
                    if: -> { category_id.blank? && description.present? }

  private

  def assign_category_automatically
    # ① ルールベース
    rule_key = ::RuleBasedCategorizer.call(
      direction: direction,
      description: description,
      amount: amount
    )

    if rule_key.present? && rule_key.to_sym != :other
      if (found = Category.find_by(name: rule_key.to_s))
        self.category = found
        return   # ルールで判定できたのでここで終了
      end
    end

    # ② ルールで決まらなかったら AI
    ai_key = ::AiCategorizer.call(
      direction: direction,
      description: description,
      amount: amount,
      occurred_on: occurred_on
    )

    Rails.logger.info("[Entry] ai_key=#{ai_key.inspect} for desc=#{description.inspect}")

    return if ai_key.blank?  # ← :other でも nil でもない場合だけ続ける

    self.category ||= Category.find_by(name: ai_key.to_s)
  end
end
