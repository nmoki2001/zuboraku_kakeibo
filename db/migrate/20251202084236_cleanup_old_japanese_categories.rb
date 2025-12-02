class CleanupOldJapaneseCategories < ActiveRecord::Migration[7.2]
  def up
    # 古い日本語カテゴリを削除
    old_names = %w[
      食費
      日用品
      交通
      趣味
      趣味・娯楽
      その他
      給与
      賞与
      副収入
      その他収入
    ]

    Category.where(name: old_names).destroy_all
  end

  def down
    # down は何もしなくてOK（また戻すことはないため）
  end
end
