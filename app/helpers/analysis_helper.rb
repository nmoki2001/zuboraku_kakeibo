# app/helpers/analysis_helper.rb
module AnalysisHelper
  # Entry のカテゴリを日本語ラベルにして表示する
  def entry_category_label(entry)
    return "-" unless entry.category

    case entry.category.name
    when "food"         then "食費"
    when "daily_goods"  then "日用品"
    when "transport"    then "交通"
    when "hobby"        then "趣味・娯楽"
    when "other"        then "その他"

    when "salary"       then "給与"
    when "bonus"        then "賞与"
    when "side_income"  then "副収入"
    when "other_income" then "その他収入"
    else
      entry.category.name # 想定外はそのまま出す（デバッグ用）
    end
  end
end
