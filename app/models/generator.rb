class Generator < ActiveRecord::Base

  # For now we will assume that this takes a root node and an array
  # of other components

  attr_accessible :generator_hash
  attr_accessor :generator_hash
  belongs_to :user

  def obj_file

  end

  private

  def deserialize
    root = TerrainLib::Component.deserialize root
  end

  def serialize
    root = root.to_json
  end
end
