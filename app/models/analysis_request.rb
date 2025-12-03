class AnalysisRequest < ApplicationRecord
  # 今日分だけを取り出すためのスコープ
  scope :today, -> { where(used_at: Time.zone.today.all_day) }
end
