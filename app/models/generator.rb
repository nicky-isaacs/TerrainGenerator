class Generator < ActiveRecord::Base

  # For now we will assume that this takes a root node and an array
  # of other components

	self.table_name = "generators"

  before_save :serialize
  after_find :deserialize

  attr_accessible :generator_hash, :user_id
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
    begin
      generator_hash = JSON.parse generator_hash
    rescue

    end
  end

  def serialize
    begin
      generator_hash = generator_hash.to_json
    rescue

    end
  end
end
