require File.join( File.dirname(__FILE__), 'spec_helper')
require 'json'

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
    
    it "receives input from sampler properly" do
        a = TerrainLib::Component.new({:type => "add", :inputs => {"x" => ["sampler", "x"], "a" => ["sampler", "y"]}})
        a.sample({"x" => 3, "y" => 2})["x"].should eq(5)
    end
    
    it "generates a heightmap properly" do
        factor = TerrainLib::Component.new({:type => "value", :outputs => {"v" => 0.1}})
        stretch = TerrainLib::Component.new({:type => "mult", :inputs => {"x" => ["sampler", "x"], "y" => ["sampler", "y"], "b" => [factor, "v"]}})
        simplex = TerrainLib::Component.new({:type => "simplex", :inputs => {"x" => [stretch, "x"], "y" => [stretch, "y"]}})
        result = TerrainLib::Component.new({:type => "result", :inputs => {"v" => [simplex, "v"]}})
        filepath = result.generate()
        File::delete(filepath)
    end
    
    it "should recognize valid and invalid hashes" do
        TerrainLib::Component::isValidHash?(JSON.parse(File.open("lib/terrain_lib/spec/gen/mountains.gen").read)).should eq([true, nil])
    end
    
    it "should properly generate a heightmap given user info" do
        metadata = JSON.parse(File.open("lib/terrain_lib/spec/gen/hills.gen").read)
        TerrainLib::Component::isValidHash?(metadata).should eq([true, nil])
        filepath = TerrainLib::Component::generate(metadata)
    end
end
