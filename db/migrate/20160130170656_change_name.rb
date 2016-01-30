class ChangeName < ActiveRecord::Migration
  def change
  	rename_column :cal_users, :user_name, :user_id
  	change_column :cal_users, :user_id, :text
  end
end
