require File.join( File.dirname(__FILE__), 'spec_helper')

describe TerrainLib::Component do
    it "returns correct output when output is manually set" do
        c = Component.new({:type => "value", :output => {"v" => 5}})
        c.output.should eq({"v" => 5})
    end
end
