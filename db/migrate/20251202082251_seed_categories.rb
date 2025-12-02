class SeedCategories < ActiveRecord::Migration[7.2]
  def up
    categories = [
      # 支出
      { name: "food",        kind: 0 },
      { name: "daily_goods", kind: 0 },
      { name: "transport",   kind: 0 },
      { name: "hobby",       kind: 0 },
      { name: "other",       kind: 0 },

      # 収入
      { name: "salary",       kind: 1 },
      { name: "bonus",        kind: 1 },
      { name: "side_income",  kind: 1 },
      { name: "other_income", kind: 1 }
    ]

    categories.each do |attrs|
      Category.find_or_create_by!(name: attrs[:name]) do |c|
        c.kind = attrs[:kind]
      end
    end
  end

  def down
    # 元に戻す場合は削除（不要なら空でもOK）
    Category.where(name: %w[
      food daily_goods transport hobby other
      salary bonus side_income other_income
    ]).delete_all
  end
end
