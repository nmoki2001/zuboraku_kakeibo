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
end
