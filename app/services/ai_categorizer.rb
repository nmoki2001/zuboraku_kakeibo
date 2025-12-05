# app/services/ai_categorizer.rb
class AiCategorizer
  # Entry からはこう呼ぶ想定：
  # AiCategorizer.call(
  #   direction: entry.direction,        # "income" / "expense"
  #   description: entry.description,
  #   amount: entry.amount,
  #   occurred_on: entry.occurred_on
  # )
  def self.call(direction:, description:, amount:, occurred_on:)
    new(
      direction: direction,
      description: description,
      amount: amount,
      occurred_on: occurred_on
    ).call
  end

  # このアプリで使うカテゴリキー一覧（Category.name と一致させる）
  CATEGORY_KEYS = %w[
    food
    daily_goods
    transport
    hobby
    other
    salary
    bonus
    side_income
    other_income
  ].freeze

  def initialize(direction:, description:, amount:, occurred_on:)
    @direction   = direction   # "income" か "expense"
    @description = description
    @amount      = amount
    @occurred_on = occurred_on
  end

  def call
    Rails.logger.info("[AiCategorizer] called direction=#{@direction} desc=#{@description}")

    # 説明が空ならそもそも分類しない
    return :other if @description.blank?

    # ▼ OpenAIClient が定義されていなければ（APIキー未設定など）AI は使わない
    return default_key_for_direction unless defined?(OpenAIClient)

    # -----------------------------
    # OpenAI に投げるメッセージを組み立て
    # -----------------------------
    system_prompt = <<~SYS
      あなたは日本の家計簿アプリの「項目」分類AIです。
      次の英語のカテゴリキーのいずれか1つだけを必ず出力してください。

      利用できるキーは次の通りです：
      - food          # 食費
      - daily_goods   # 日用品
      - transport     # 交通
      - hobby         # 趣味・娯楽
      - other         # その他（支出）
      - salary        # 給与
      - bonus         # 賞与
      - side_income   # 副収入（フリマ・お小遣いなど）
      - other_income  # その他（収入）

      出力はカテゴリキーのみとし、説明や日本語は一切書かないでください。
      例：food
    SYS

    user_prompt = <<~USER
      次の家計簿の1件の明細を、上記のカテゴリキーのどれか1つに分類してください。

      種別: #{@direction == "expense" ? "支出" : "収入"}
      金額: #{@amount} 円
      日付: #{@occurred_on}
      内容: #{@description}
    USER

    # -----------------------------
    # OpenAI API を呼び出し
    # -----------------------------
    response = OpenAIClient.chat.completions.create(
      model: :"gpt-4o-mini", # 安め＆十分なモデル
      messages: [
        { role: "system", content: system_prompt },
        { role: "user",   content: user_prompt }
      ],
      temperature: 0 # ぶれを抑える
    )

    raw_text = extract_content_from(response)
    Rails.logger.info("[AiCategorizer] raw output: #{raw_text.inspect} desc=#{@description.inspect}")

    normalized_key = normalize_label(raw_text)
    Rails.logger.info("[AiCategorizer] normalized_key=#{normalized_key.inspect}")

    # 許可したキー以外は direction に応じてその他系に丸める
    if CATEGORY_KEYS.include?(normalized_key)
      normalized_key.to_sym
    else
      default_key_for_direction
    end
  rescue => e
    Rails.logger.error("[AiCategorizer] error: #{e.class} #{e.message}")
    default_key_for_direction
  end

  private

  attr_reader :direction, :description, :amount, :occurred_on

  # OpenAI のレスポンスから content を安全に取り出す
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

  # モデルの出力を "food" などのキーに正規化する
  def normalize_label(text)
    return nil if text.nil?

    # 余計な改行やコメントが付いていても最初の単語だけ取る
    text.to_s.strip.downcase.split(/\s/).first
  end

  # 方向に応じたデフォルトカテゴリ
  def default_key_for_direction
    # 支出なら :other、収入なら :other_income に寄せる
    direction == "income" ? :other_income : :other
  end
end
