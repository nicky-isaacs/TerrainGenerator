require File.join( File.dirname(__FILE__), 'spec_helper')

describe TerrainLib::Component do
    it "returns correct output from value types" do
        c = TerrainLib::Component.new({:type => "value", :outputs => {"v" => 5}})
        c.sample({"x" => 0, "y" => 0})["v"].should eq(5)
    end
    
    it "processes inter-component communications properly" do
        a = TerrainLib::Component.new({:type => "value", :outputs => {"v" => 3}})
        b = TerrainLib::Component.new({:type => "value", :outputs => {"v" => 4}})
        c = TerrainLib::Component.new({:type => "add", :inputs => {"x" => [a, "v"], "a" => [b, "v"]}})
        c.sample({"x" => 0, "y" => 0})["x"].should eq(7)
    end
    
    it "generates a heightmap properly" do
        a = TerrainLib::Component.new({:type => "add", :inputs => {"x" => ["sampler", "x"], a => ["sampler", "y"]}})
        filepath = a.generate()
    end
end

describe TerrainLib do
    it "should properly generate a heightmap given user info" do
    
    end
end
