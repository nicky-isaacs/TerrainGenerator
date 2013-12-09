class Generator < ActiveRecord::Base

  # For now we will assume that this takes a root node and an array
  # of other components

	self.table_name = "generators"

  attr_accessible :generator_hash
  belongs_to :user

  def obj_file

  end
  
  def make_default
    self.default = 'y'
  end
  
  def make_default!
    self.default = 'y'
    save!
  end

	def is_default?
		'y' == self.default
	end

  private

  def deserialize
    root = TerrainLib::Component.deserialize root
  end

  def serialize
    root = root.to_json
  end
end
