class AnalysisController < ApplicationController
  def show
    # ▼ ログイン（匿名ユーザー）ごとの明細一覧
    @entries = Entry.for_anon_user(current_anon_user_id)
                    .order(occurred_on: :asc)

    # ▼ 分析回数まわり（DB ではなく Cookie を見る）
    daily_limit = 3

    today_str  = Time.zone.today.to_s              # 例: "2025-12-06"
    cookie_key = "analysis_count_#{today_str}"     # 例: "analysis_count_2025-12-06"

    today_count = cookies[cookie_key].to_i         # Cookie がなければ 0

    # 0 回未満にならないようにガード
    @remaining_analyses = [0, daily_limit - today_count].max

    # ▼ 直近の選択月 or デフォルトは「今月」
    @selected_month_param = session[:analysis_month_param] || Date.current.strftime("%Y-%m")

    # ▼ セレクトボックスに渡す月一覧（過去12ヶ月）
    @month_options = build_month_options

    # ▼ 分析結果表示用
    @analysis_month_label = session[:analysis_month_label]
    @good_point           = session[:good_point]    || "まだ分析は実行されていません。"
    @improve_point        = session[:improve_point] || "まずは明細をいくつか登録してから分析してみましょう。"
  end

  def create
    daily_limit = 3

    # ▼ 今日の日付ごとにキーを変える（翌日には別カウントになる）
    today_str  = Time.zone.today.to_s               # 例: "2025-12-06"
    cookie_key = "analysis_count_#{today_str}"      # 例: "analysis_count_2025-12-06"

    today_count = cookies[cookie_key].to_i          # Cookie が無ければ 0 扱い

    # ▼ 3回以上なら即リダイレクト（※ここでは DB は見ない）
    if today_count >= daily_limit
      redirect_to analysis_path,
                  alert: "本日の分析回数（#{daily_limit}回）を使い切りました。" and return
    end

    # ▼ ユーザーが選んだ "YYYY-MM" を Date に変換
    reference_date = month_param_to_date(params[:month])

    # ▼ 分析実行
    result = AiMonthlyAnalysis.call(
      reference_date: reference_date,
      anon_user_id:   current_anon_user_id
    )

    Rails.logger.info "[AnalysisController] AI analysis good_point=#{result.good_point.to_s[0, 30]}..."

    # ▼ 分析が「成功したタイミング」でだけ、Cookie の回数を +1
    cookies[cookie_key] = {
      value:   (today_count + 1).to_s,
      expires: Time.zone.tomorrow.end_of_day
    }

    # ▼ ログとして DB には残しておく（回数制限には使わない）
    AnalysisRequest.create!(used_at: Time.current)

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
