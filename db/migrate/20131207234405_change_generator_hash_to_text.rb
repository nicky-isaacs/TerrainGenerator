class ChangeGeneratorHashToText < ActiveRecord::Migration
  def self.up
     change_column :generators, :generator_hash, :text
  end

  def self.down
     change_column :generators, :generator_hash, :string
  end
end
