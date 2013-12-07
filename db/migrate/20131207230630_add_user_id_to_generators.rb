class AddUserIdToGenerators < ActiveRecord::Migration
  def change
    add_column :generators, :user_id, :int
  end
end
