class Generator < ActiveRecord::Base

  # For now we will assume that this takes a root node and an array
  # of other components

  attr_accessible :root
  attr_accessor :root

  has_many :components

  after_find :deserialize
  before_save :serialize

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
