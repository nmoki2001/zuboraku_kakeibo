class AnalysisController < ApplicationController
  def show
    @entries = Entry.for_anon_user(current_anon_user_id)
                    .order(occurred_on: :asc)

    today_count = AnalysisRequest.today.count
    @remaining_analyses = [0, 3 - today_count].max
    @analysis_disabled = @entries.blank? || @remaining_analyses.zero?

    # ▼ 直近の選択月 or デフォルトは「今月」
    @selected_month_param = session[:analysis_month_param] || Date.current.strftime("%Y-%m")

    # ▼ セレクトボックスに渡す月一覧（過去12ヶ月）
    @month_options = build_month_options

    @analysis_month_label = session[:analysis_month_label]

    @good_point    = session[:good_point]    || "まだ分析は実行されていません。"
    @improve_point = session[:improve_point] || "まずは明細をいくつか登録してから分析してみましょう。"
  end

  def create
    if AnalysisRequest.today.count >= 3
      redirect_to analysis_path, alert: "本日の分析回数（3回）を使い切りました。" and return
    end

    AnalysisRequest.create!(used_at: Time.current)

    # ▼ ユーザーが選んだ "YYYY-MM" を Date に変換
    reference_date = month_param_to_date(params[:month])

    # ▼ 分析実行
    result = AiMonthlyAnalysis.call(
      reference_date: reference_date,
      anon_user_id: current_anon_user_id
    )

    Rails.logger.info "[AnalysisController] AI analysis good_point=#{result.good_point.to_s[0, 30]}..."

    # ▼ 分析結果を session に保存（show に戻った時に表示するため）
    session[:good_point]            = result.good_point
    session[:improve_point]         = result.improve_point
    session[:analysis_month_label]  = reference_date.strftime("%Y年%-m月")
    session[:analysis_month_param]  = reference_date.strftime("%Y-%m")

    redirect_to analysis_path, notice: "分析が完了しました。"
  end

  private

  # "2025-02" → Date オブジェクトの1日目へ
  def month_param_to_date(str)
    return Date.current unless str.present?

    year, month = str.split("-").map(&:to_i)
    Date.new(year, month, 1)
  rescue
    Date.current
  end

  # ["2025年2月", "2025-02"] のような配列のリスト
  def build_month_options(n = 12)
    today = Date.current
    (0...n).map do |i|
      target = today.prev_month(i)
      ["#{target.year}年#{target.month}月", target.strftime("%Y-%m")]
    end
  end
end
