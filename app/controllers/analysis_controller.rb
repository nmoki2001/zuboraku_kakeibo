class AnalysisController < ApplicationController
  def show
    @entries = Entry.order(occurred_on: :asc)

    today_count = AnalysisRequest.today.count
    @remaining_analyses = [0, 3 - today_count].max

    # 明細ゼロ or 回数上限 → ボタン無効
    @analysis_disabled = @entries.blank? || @remaining_analyses.zero?

    @good_point    = session[:good_point]    || "まだ分析は実行されていません。"
    @improve_point = session[:improve_point] || "まずは明細をいくつか登録してから分析してみましょう。"
  end

  def create
    if AnalysisRequest.today.count >= 3
      redirect_to analysis_path, alert: "本日の分析回数（3回）を使い切りました。" and return
    end

    AnalysisRequest.create!(used_at: Time.current)

    # ★ AIベースの分析（中で失敗したらルールベースにフォールバック）
    result = AiMonthlyAnalysis.call

    Rails.logger.info "[AnalysisController] AI analysis good_point=#{result.good_point.to_s[0, 30]}..."

    session[:good_point]    = result.good_point
    session[:improve_point] = result.improve_point

    redirect_to analysis_path, notice: "分析が完了しました。"
  end
end
