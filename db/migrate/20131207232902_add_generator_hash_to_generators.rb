class AddGeneratorHashToGenerators < ActiveRecord::Migration
  def change
    add_column :generators, :generator_hash, :string
  end
end
