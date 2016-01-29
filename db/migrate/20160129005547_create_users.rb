class CreateUsers < ActiveRecord::Migration
  def up
    create_table :cal_users do |t|
      t.string :user_name
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at	

      t.timestamps
    end
  end

  def down
    drop_table :cal_users
  end
end
