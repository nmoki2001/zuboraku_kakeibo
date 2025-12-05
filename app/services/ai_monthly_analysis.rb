# app/services/ai_monthly_analysis.rb
require "json"

class AiMonthlyAnalysis
  Result = Struct.new(:good_point, :improve_point)

  # 呼び出し側は常にこれだけ使う
  def self.call(reference_date: Date.current)
    unless defined?(OpenAIClient)
      Rails.logger.warn "[AiMonthlyAnalysis] OpenAIClient が定義されていないため、AIは使わず固定メッセージを返します。"

      return Result.new(
        "家計の記録ができていて素晴らしいです。この調子で続けていきましょう。",
        "もし気になる支出があれば、カテゴリごとに見直してみると良いかもしれません。"
      )
    end

    new(reference_date: reference_date).call
  rescue => e
    Rails.logger.error "[AiMonthlyAnalysis] error (class-level): #{e.class} #{e.message}"

    # フォールバック：とりあえず固定メッセージを返す（MonthlyAnalysis は一旦使わない）
    Result.new(
      "家計の記録ができていて素晴らしいです。この調子で続けていきましょう。",
      "一部の支出を少しだけ意識するだけでも、無理なく節約につながります。"
    )
  end

  def initialize(reference_date:)
    @date = reference_date.to_date
  end

  def call
    stats  = build_stats
    prompt = build_prompt(stats)

    Rails.logger.info "[AiMonthlyAnalysis] prompt:\n#{prompt}"

    # 新しいスタイルに統一
    response = OpenAIClient.chat.completions.create(
      model: :"gpt-4o-mini",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user",   content: prompt }
      ],
      temperature: 0.7
    )

    text = extract_content_from(response)

    Rails.logger.info "[AiMonthlyAnalysis] raw output: #{text.inspect}"

    json = parse_json_safely(text)

    if json
      Result.new(json["good_point"], json["improve_point"])
    else
      Rails.logger.warn "[AiMonthlyAnalysis] JSON パースに失敗したため、固定メッセージを返します。"
      Result.new(
        "家計の傾向をもとに、バランスよく支出できています。",
        "特に気になるカテゴリがあれば、来月は少しだけ意識してみると良いかもしれません。"
      )
    end
  rescue => e
    Rails.logger.error "[AiMonthlyAnalysis] error (instance-level): #{e.class} #{e.message}"
    Result.new(
      "家計の記録ができていて素晴らしいです。この調子で続けていきましょう。",
      "一部の支出を少しだけ意識するだけでも、無理なく節約につながります。"
    )
  end

  private

  attr_reader :date

  # ---------- OpenAI レスポンス処理 ----------

  def extract_content_from(response)
    # 新しい openai-ruby: OpenAI::Models::Chat::ChatCompletion
    if response.respond_to?(:choices)
      choice = response.choices.first

      message =
        if choice.respond_to?(:message)
          choice.message
        elsif choice.is_a?(Hash)
          choice[:message] || choice["message"]
        else
          raise "Unexpected OpenAI choice object: #{choice.class}"
        end

      if message.respond_to?(:[])
        message[:content] || message["content"]
      elsif message.respond_to?(:content)
        message.content
      else
        raise "Unexpected OpenAI message object: #{message.class}"
      end

    # 古い Hash 形式のフォールバック
    elsif response.is_a?(Hash)
      response.dig("choices", 0, "message", "content") ||
        response.dig(:choices, 0, :message, :content)
    else
      raise "Unexpected OpenAI response type: #{response.class}"
    end
  end

  def parse_json_safely(text)
    json = JSON.parse(text) rescue nil
    return unless json.is_a?(Hash)

    return json if json["good_point"].present? && json["improve_point"].present?
  end

  # ---------- プロンプト関連 ----------

  def system_prompt
    <<~SYS
      あなたは日本人ユーザー向けの家計簿アプリのアドバイザーです。
      ユーザーの1ヶ月分の家計データ（カテゴリ別の合計金額など）が与えられるので、
      「良い点」と「改善点」をそれぞれ1〜2文程度、日本語でわかりやすく伝えてください。

      出力は必ず次のJSON形式だけにしてください（余計な説明文は書かない）:
      {"good_point": "...", "improve_point": "..."}
    SYS
  end

  def build_prompt(stats)
    <<~USER
      対象月: #{stats[:month_label]}

      ■ 全体の支出
      - 今月の支出合計: #{number_with_delimiter(stats[:this_total_expense])} 円
      - 先月の支出合計: #{number_with_delimiter(stats[:last_total_expense])} 円

      ■ カテゴリ別（今月）
      #{format_category_lines(stats[:this_by_category])}

      ■ カテゴリ別（先月）
      #{format_category_lines(stats[:last_by_category])}

      条件:
      - ユーザーを責める言い方は避けてください。
      - 前向きで優しいトーンで書いてください。
      - 良い点と改善点の両方を書いてください（どちらか一方だけにしない）。
      - 文章量はそれぞれ1〜2文程度にしてください。
    USER
  end

  def format_category_lines(hash)
    return "（データなし）" if hash.blank?

    hash.map do |label, amount|
      "・#{label}: #{number_with_delimiter(amount)} 円"
    end.join("\n")
  end

  # ---------- 集計まわり ----------

  def build_stats
    {
      month_label: "#{date.year}年#{date.month}月",
      this_total_expense: expense_scope.where(occurred_on: this_month_range).sum(:amount),
      last_total_expense: expense_scope.where(occurred_on: last_month_range).sum(:amount),
      this_by_category: totals_by_category(this_month_range),
      last_by_category: totals_by_category(last_month_range)
    }
  end

  def this_month_range
    date.beginning_of_month..date.end_of_month
  end

  def last_month_range
    date.prev_month.beginning_of_month..date.prev_month.end_of_month
  end

  def expense_scope
    Entry.where(direction: :expense)
  end

  def totals_by_category(range)
    expense_scope
      .where(occurred_on: range)
      .includes(:category)
      .group("categories.name")
      .sum(:amount)
      .map { |name, amount|
        label = category_label_for(name)
        [label, amount]
      }.to_h
  end

  def category_label_for(name)
    Category.find_by(name: name)&.display_name || name
  end

  # ---------- 便利メソッド ----------

  def number_with_delimiter(number)
    whole, decimal = number.to_s.split(".")
    whole_with_comma = whole.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
    [whole_with_comma, decimal].compact.join(".")
  end
end
