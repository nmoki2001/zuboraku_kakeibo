# app/services/rule_based_categorizer.rb
class RuleBasedCategorizer
  # ここで「どのキーワードがどのカテゴリか」を定義
  # category は内部キー（:food, :transport, :salary など）として返す
  RULES = [
    # ========= 支出 =========
    {
      direction: "expense",
      category:  :food,
      keywords:  %w[
        マック マクド マクドナルド 松屋 吉野家 すき家 ガスト サイゼ 牛丼
        カフェ ランチ 夕飯 朝食 昼食 晩ごはん 外食 食事 ご飯 ラーメン
        ファミマ セブン ローソン 弁当
      ]
    },
    {
      direction: "expense",
      category:  :transport,
      keywords:  %w[
        電車 バス 交通費 タクシー ガソリン 駐車場 駐輪場 高速 ETC
      ]
    },
    {
      direction: "expense",
      category:  :daily_goods,
      keywords:  %w[
        日用品 洗剤 ティッシュ トイレットペーパー シャンプー
        ドラッグストア 薬局 マツキヨ スギ薬局 ココカラファイン
      ]
    },
    {
      direction: "expense",
      category:  :hobby,
      keywords:  %w[
        カメラ レンズ 写真 撮影 本 書籍 漫画 マンガ
        Netflix ネットフリックス Hulu U-NEXT
        ゲーム switch プレステ PS5
      ]
    },

    # ========= 収入 =========
    {
      direction: "income",
      category:  :salary,
      keywords:  %w[
        給料 給与 賃金 給与振込 給与支給 給与支払 賃金支給
      ]
    },
    {
      direction: "income",
      category:  :bonus,
      keywords:  %w[
        ボーナス 賞与
      ]
    },
    {
      direction: "income",
      category:  :side_income,
      keywords:  %w[
        メルカリ ヤフオク ラクマ フリマ 売上 売却 販売
      ]
    }
  ].freeze

  # direction: "expense" / "income"
  # description: 内容（文字列）
  # amount: 金額（整数 or 文字列）
  #
  # 戻り値：:food, :transport, :salary, :other などのシンボル
  def self.call(direction:, description:, amount:)
    return :other if description.blank?

    text = description.to_s

    # 1. キーワードマッチで判定
    RULES.each do |rule|
      next if rule[:direction] != direction

      rule[:keywords].each do |keyword|
        return rule[:category] if text.include?(keyword)
      end
    end

    # 2. 簡単な金額ベースの補助ルール（あってもなくてもOK）
    if direction == "income" && amount.to_i >= 150_000 && text.match?(/給|俸/)
      return :salary
    end

    :other
  end
end
