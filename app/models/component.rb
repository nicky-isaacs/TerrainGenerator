class Component < ActiveRecord::Base

  before_save :serialize
  after_find :deserialize
  belongs_to :generator

  attr_accessible :lock, :inputs, :outputs, :type
  attr_accessor :lock, :inputs, :outputs, :type

	#def initialize(params={})
	#	if params[:output]
	#		@output = params[:output]
	#	else
	#		@output = nil
	#	end
  #
	#	@input = params[:input]
	#end

  private

  def serialize
    input = input.to_json
    output = output.to_json
  end

  def deserialize
    output = TerrainLib::Component.deserialize output
    input = TerrainLib::Component.deserialize input
  end
end
