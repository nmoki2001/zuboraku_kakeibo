# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# ===== カテゴリ初期データ =====

categories = [
  # 支出カテゴリ
  { name: "food",        kind: 0 },  # 食費
  { name: "daily_goods", kind: 0 },  # 日用品
  { name: "transport",   kind: 0 },  # 交通
  { name: "hobby",       kind: 0 },  # 趣味・娯楽
  { name: "other",       kind: 0 },  # その他支出

  # 収入カテゴリ
  { name: "salary",       kind: 1 }, # 給与
  { name: "bonus",        kind: 1 }, # 賞与
  { name: "side_income",  kind: 1 }, # 副収入（メルカリなど）
  { name: "other_income", kind: 1 }  # その他収入
]

categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |c|
    c.kind = attrs[:kind]
  end
end