require 'rspec'
require 'terrain_lib'

describe TerrainLib::Component do
    it "returns correct output from value types" do
        c = TerrainLib::Component.new({:type => "value", :output => {"v" => 5}})
        c.sample(c, {"x" => 0, "y" => 0}).should eq(5)
    end
    
    it "processes inter-component communications properly" do
        a = TerrainLib::Component.new({:type => "value", :output => {"v" => 3}})
        b = TerrainLib::Component.new({:type => "value", :output => {"v" => 4}})
        c = TerrainLib::Component.new({:type => "add", :input => {"x" => [a, "v"], "a" => [b, "v"]}})
        TerrainLib.sample(c, {"x" => 0, "y" => 0}).should eq(7)
    end
    
    it "generates a heightmap properly" do
        a = TerrainLib::Component.new({:type => "add", :input => {"x" => ["sampler", "x"], a => ["sampler", "y"]}})
        filepath = TerrainLib.generate(a)
    end
end


