class Component < ActiveRecord::Base

  before_save :serialize
  after_find :deserialize
  belongs_to :generator

  # input/output format:
  # input: { input_variable: { output_object_id: 1, output_variable: test },  }
  # output: { variable_name: value }

  attr_accessible :inputs, :outputs, :type
  attr_accessor :inputs, :outputs, :type

  def inflate
    params = {
        :outputs => inflated_outputs,
        :inputs => inflated_inputs,
        :type => type,
        :name => (name || 'default')
    }
    TerrainLib::Component.new params
  end

  private

  def inflated_outputs

  end

  def inflated_inputs
  end

  def serialize
    input = input.to_json
    output = output.to_json
  end


  def deserialize
    output = TerrainLib::Component.deserialize output
    input = TerrainLib::Component.deserialize input
  end
end
