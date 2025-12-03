# app/services/monthly_analysis.rb
class MonthlyAnalysis
  Result = Struct.new(:good_point, :improve_point)

  def self.call(reference_date: Date.current)
    new(reference_date: reference_date).call
  end

  def initialize(reference_date:)
    @date = reference_date.to_date
  end

  def call
    Result.new(good_point_message, improve_point_message)
  end

  private

  attr_reader :date

  def good_point_message
    return "データが少なく、十分な分析ができません。" if last_month_food.zero? && this_month_food.zero?

    if last_month_food.zero? && this_month_food.positive?
      "先月は食費の記録がなく、今月から記録がスタートしました。継続して記録できていて良いですね。"
    elsif this_month_food < last_month_food
      rate = calc_rate(last_month_food, this_month_food)
      "先月より食費が#{rate}%減少しました。とても良いペースです！"
    else
      "食費は先月と同じか少し増加しています。無理のない範囲で、少しずつ意識できているかもしれません。"
    end
  end

  def improve_point_message
    # カテゴリ別に今月の支出増加が大きいものを1つピックアップ
    increased = expense_totals_this_month
                .map { |name, amount| [name, amount, diff_from_last_month(name)] }
                .select { |_, _, diff| diff.positive? }
                .max_by { |_, _, diff| diff }

    return "特に大きく増えている項目はありませんでした。" if increased.nil?

    name, _, diff = increased
    "今月は「#{name}」の支出が先月よりも#{number_with_delimiter(diff)}円多くなっています。少し意識してみても良いかもしれません。"
  end

  # --- 以下、集計用メソッド群 ---

  def this_month_range
    date.beginning_of_month..date.end_of_month
  end

  def last_month_range
    (date.prev_month.beginning_of_month..date.prev_month.end_of_month)
  end

  def food_category
    @food_category ||= Category.find_by(name: "food")
  end

  def expense_scope
    Entry.where(direction: :expense)
  end

  def this_month_food
    return 0 unless food_category

    expense_scope
      .where(occurred_on: this_month_range, category: food_category)
      .sum(:amount)
  end

  def last_month_food
    return 0 unless food_category

    expense_scope
      .where(occurred_on: last_month_range, category: food_category)
      .sum(:amount)
  end

  def expense_totals_this_month
    expense_scope
      .where(occurred_on: this_month_range)
      .includes(:category)
      .group("categories.name")
      .sum(:amount)
  end

  def expense_totals_last_month
    expense_scope
      .where(occurred_on: last_month_range)
      .includes(:category)
      .group("categories.name")
      .sum(:amount)
  end

  def diff_from_last_month(category_name)
    this_month = expense_totals_this_month[category_name] || 0
    last_month = expense_totals_last_month[category_name] || 0
    this_month - last_month
  end

  def calc_rate(before, after)
    return 0 if before.zero?

    (((before - after).to_f / before) * 100).round
  end

  # view ヘルパの number_with_delimiter を使いたいので簡易実装
  def number_with_delimiter(number)
    whole, decimal = number.to_s.split(".")
    whole_with_comma = whole.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
    [whole_with_comma, decimal].compact.join(".")
  end
end
