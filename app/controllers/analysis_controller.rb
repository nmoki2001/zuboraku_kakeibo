class AnalysisController < ApplicationController
  def show
    @entries = Entry.order(occurred_on: :asc)

    today_count = AnalysisRequest.today.count
    @remaining_analyses = [0, 3 - today_count].max

    # 明細がゼロ or 回数上限 → ボタン無効
    @analysis_disabled = @entries.blank? || @remaining_analyses.zero?

    @good_point    = session[:good_point]    || "まだ分析は実行されていません。"
    @improve_point = session[:improve_point] || "まずは明細をいくつか登録してから分析してみましょう。"
  end

  def create
    # 1日3回制限
    if AnalysisRequest.today.count >= 3
      redirect_to analysis_path, alert: "本日の分析回数（3回）を使い切りました。" and return
    end

    # 分析実行記録（used_at の NOT NULL 制約にも対応）
    AnalysisRequest.create!(used_at: Time.current)

    # 分析ロジック本体を実行
    result = MonthlyAnalysis.call

    # 表示用にセッションへ保存
    session[:good_point]    = result.good_point
    session[:improve_point] = result.improve_point

    redirect_to analysis_path, notice: "分析が完了しました。"
  end
end
