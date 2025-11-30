class Analysis < ApplicationRecord
  validates :good_points, presence: true
  validates :improvements, presence: true

  # 今日分の分析だけ取りたいとき用（1日3回制限の判定に使える）
  scope :today, -> { where(created_at: Time.current.all_day) }
end
