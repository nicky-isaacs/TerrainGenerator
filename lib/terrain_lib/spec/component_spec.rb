require 'rspec'
require 'terrain_lib'

describe TerrainLib.Component do
    it "returns correct output when output is manually set" do
        c = Component.new({:type => "value", :output => {"v" => 5}})
        c.output.should eq({"v" => 5})
    end
end
