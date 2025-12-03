class CreateAnalysisRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :analysis_requests do |t|
      t.datetime :used_at

      t.timestamps
    end
  end
end
