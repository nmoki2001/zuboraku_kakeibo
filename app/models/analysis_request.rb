# app/models/analysis_request.rb
class AnalysisRequest < ApplicationRecord
  scope :today, -> {
    Rails.logger.warn ">>> DEBUG: AnalysisRequest.today CALLED from: #{caller_locations(1,1).first}"
    where(used_at: Time.zone.today.all_day)
  }
end
