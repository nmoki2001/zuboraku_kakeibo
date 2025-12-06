# app/models/analysis.rb
class Analysis < ApplicationRecord
  validates :good_points, presence: true
  validates :improvements, presence: true

  # ▼ 今日のレコードに限定（「東京の今日」の0:00〜23:59）
  scope :today, -> { where(created_at: Time.zone.today.all_day) }

  # ▼ 特定ユーザー（anon_user_id など）に限定
  scope :for_user, ->(anon_user_id) { where(anon_user_id: anon_user_id) }
end
