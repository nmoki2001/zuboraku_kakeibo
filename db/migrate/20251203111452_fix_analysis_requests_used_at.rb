class FixAnalysisRequestsUsedAt < ActiveRecord::Migration[7.2]
  def change
    # used_at を null: false に変更
    change_column_null :analysis_requests, :used_at, false

    # used_at に index を追加
    add_index :analysis_requests, :used_at
  end
end
