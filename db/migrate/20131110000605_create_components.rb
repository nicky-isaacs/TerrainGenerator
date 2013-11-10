class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.boolean :lock

      t.timestamps
    end
  end
end
