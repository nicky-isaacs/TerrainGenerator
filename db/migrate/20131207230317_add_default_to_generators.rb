class AddDefaultToGenerators < ActiveRecord::Migration
  def change
    add_column :generators, :default, :string, :default => 'n'
  end
end
