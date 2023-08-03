class ChangeCloumnsNotnullAddReports < ActiveRecord::Migration[7.0]
  def change
    change_column_null :reports, :user_id, false
  end
end
