require 'perlin'

OBJ_SCALAR = 0.1

#types...
#  value: outputs constant value by name "v"
#  mult: inputs{"x", "y", "z", "w", "b"} => outputs{"x", "y", "z", "w"}
#  div: inputs{"x", "y", "z", "w", "b"} => outputs{"x", "y", "z", "w"}
#  add: inputs{"x", "y", "z", "w", "a", "b", "c", "d"} => outputs{"x", "y", "z", "w"}
#  sub: inputs{"x", "y", "z", "w", "a", "b", "c", "d"} => outputs{"x", "y", "z", "w"}
#  exp: inputs{"x", "y", "z", "w", "e"} => outputs{"x", "y", "z", "w"}
#  sqrt: inputs{"x", "y", "z", "w"} => outputs{"x", "y", "z", "w"}
#  log: inputs{"b", "x", "y", "z", "w"} => outputs{"x", "y", "z", "w"}
#  random: inputs{"lo", "hi", "sd"} => outputs{"x", "y", "z", "w"}
#  perlin: inputs{"x", "y", "z", "w"} => outputs{"v"}
#  simplex: inputs{"x", "y", "z", "w"} => outputs{"v"}
#  mag: inputs{"x", "y", "z", "w"} => outputs{"m"}
#  norm: inputs{"x", "y", "z", "w"} => outputs{"x", "y", "z", "w"}
#  resize: inputs{"x", "y", "z", "w", "m"} => outputs{"x", "y", "z", "w"}

# generates from this root component, with specified dimensions and resolution

module TerrainLib
=begin
{
    <component_name:string> => 
    {
        "type" => <type_name:string>,
        
        # not necessary if type is "value"
        "inputs" =>
        {
            "input_names" => [<source_name:string>, <output_name:string>]
        },
        
        # not necessary unless type is "value"
        "outputs" =>
        {
            "output_names" => <output_value:number>
        },
    }
    
    # mandatory root node
    "result" =>
    {
        "type" => "result"
        "inputs" =>
        {
            "v" => [<source_name:string>, <output_name:string>]
        }
    }
}
=end

  class Component
    attr_accessor :inputs

    def initialize( params={} )
      @outputs = params[:outputs]
      @outputs = nil if @outputs.nil? || @outputs.empty?
      @inputs = params[:inputs]
      if @inputs == nil then @inputs = {} end
      @type = params[:type]
      if @type == nil then @type = "value" end
    end

    def self.convert(metadata)
      components = {}
      metadata.each do |k,v|
        if v.has_key?("inputs") then
          v[:inputs] = v["inputs"]
          v["inputs"] = nil
        end
        if v.has_key?("outputs") then
          v[:outputs] = v["outputs"]
          v["outputs"] = nil
        end
        if v.has_key?("type") then
          v[:type] = v["type"]
          v["type"] = nil
        end
        components[k] = self.new(v)
      end

      components.each do |k,v|
        v.inputs().each do |i,j|
          if j.first != "sampler" then
            j[0] = components[j.first]
          end
        end
      end

      return components["result"]
    end

    def self.generate(metadata)
      return self.convert(metadata).generate()
    end

    def self.isValidHash?(hash)
      return [false, "hash has no valid result component"] unless hash.class.name == "Hash" && hash.has_key?("result") && hash["result"].has_key?("type") && hash["result"]["type"] == "result"
      hash.each do |k,v|
        a,b = self.isValidComponent?(k, v, hash)
        if not a then return [false, b] end
      end
      return [true, nil]
    end

    def self.isValidComponent?(k, v, hash, prev = [].to_set)
      if prev.include?(k) then return [true, nil] end
      prev.add(k)
      if v.class.name != "Hash" then return [false, "component #{k} is not a hash!"] end
      if not v.has_key?("type") then return [false, "component #{k} has no type!"] end
      if v["type"].class.name != "String" then return [false, "component #{k}'s type field must be a string!"] end
      if not TerrainLib::ComponentTypesLookup::lookup_table.has_key?(v["type"]) then return [false, "component #{k} has an invalid type!"] end
      if v.has_key?("outputs") then
        out = v["outputs"]
        if out.class.name != "Hash" then return[false, "component #{k}'s outputs are not a hash!"] end
        out.each do |l,w|
          if l.class.name != "String" then return [false, "component #{k}'s outputs include non-string keys!"] end
          if not w.respond_to?(:to_f) then return [false, "component #{k}'s outputs include non-convertible-to-float values"] end
        end
      end
      if v.has_key?("inputs") then
        inp = v["inputs"]
        if inp.class.name != "Hash" then return [false, "component #{k}'s inputs are not a hash!"] end
        inp.each do |l,w|
          if l.class.name != "String" then return [false, "component #{k}'s inputs include non-string keys!"] end
          if w.class.name != "Array" then return [false, "component #{k}'s input #{l} must be an array!"] end
          if w.first != "sampler" then
            if w.first.class.name != "String" or not hash.has_key?(w.first) then return [false, "component #{k}'s input #{l}'s first element must be the name of another component!"] end
            s,m = self.isValidComponent?(w.first, hash[w.first], hash, prev)
            if not s then return [false, m] end
            if w[-1].class.name != "String" or ((not hash[w.first].has_key?("outputs") or hash[w.first]["outputs"].class.name != "Hash" or not hash[w.first]["outputs"].has_key?(w[-1])) and (not TerrainLib::ComponentTypesLookup::lookup_table[hash[w.first]["type"]][-1].include?(w[-1]))) then return [false, "component #{k}'s input #{l}'s last element must be the name of an output of another component!"] end
          end
        end
      end
      return [true, nil]
    end

    def sample(coord)
      @@sampler = coord
      result = self.output
      reset()
      return result
    end

    def reset()
      if @type != "value" then @outputs = nil end
      @inputs.each do |k,v|
        if v.first != "sampler" and not v.first.nil? then
          v.first.reset()
        end
      end
    end

    def generate()
      filename = "lib/terrain_lib/out/" + Time.new.getutc.to_s + ".obj"
      File.open(filename, mode="w"){ |file|
        # TO WRITE: file.write(str)
        # NOTE: does not append \n
        file.write("o terrain\n")
        for x in 0..200
          for y in 0..200
            # get the value at this position
            hgt = self.sample({"x" => x, "y" => y})["z"]
            [x, y, hgt].each_with_index{ |t, i| raise "\nIndex #{i} was nil" if t.nil?}
            file.write("v #{(x * OBJ_SCALAR).to_s} #{(hgt * OBJ_SCALAR).to_s} #{(y * OBJ_SCALAR).to_s}\n")
            self.reset()
          end
        end
        for x in 1..200
          for y in 1...200
            nrow = 201 * x
            row = nrow - 201
            curr = row + y
            ncurr = nrow + y
            file.write("f #{ncurr.to_s} #{(ncurr + 1).to_s} #{(curr + 1).to_s}\n")
            file.write("f #{curr.to_s} #{ncurr.to_s} #{(curr + 1).to_s}\n")
          end
        end
      }
      return filename
    end

    def output()
      if not @outputs.nil? then return @outputs end
      return self.send(@type)
    end

    def invalue(name)
      src = @inputs[name]
      if src == nil then return Float::NAN end
      if src.first == "sampler" then
        return @@sampler[src[-1]]
      else
        # -1 indicates last element (have to remind myself not to "fix" this)
        return src.first.output[src[-1]].to_f
      end
    end

    def result()
      @outputs = {}
      @outputs["z"] = invalue("v")
      return @outputs
    end

    def value()
      @outputs = {}
      return @outputs
    end

    def mult()
      @outputs = {}
      @outputs["x"] = invalue("x") * invalue("b")
      @outputs["y"] = invalue("y") * invalue("b")
      @outputs["z"] = invalue("z") * invalue("b")
      @outputs["w"] = invalue("w") * invalue("b")
      return @outputs
    end

    def div()
      @outputs = {}
      @outputs["x"] = invalue("x") / invalue("b")
      @outputs["y"] = invalue("y") / invalue("b")
      @outputs["z"] = invalue("z") / invalue("b")
      @outputs["w"] = invalue("w") / invalue("b")
      return @outputs
    end

    def add()
      @outputs = {}
      @outputs["x"] = invalue("x") + invalue("a")
      @outputs["y"] = invalue("y") + invalue("b")
      @outputs["z"] = invalue("z") + invalue("c")
      @outputs["w"] = invalue("w") + invalue("d")
      return @outputs
    end

    def sub()
      @outputs = {}
      @outputs["x"] = invalue("x") - invalue("a")
      @outputs["y"] = invalue("y") - invalue("b")
      @outputs["z"] = invalue("z") - invalue("c")
      @outputs["w"] = invalue("w") - invalue("d")
      return @outputs
    end

    def exp()
      @outputs = {}
      e = invalue("e")
      @outputs["x"] = invalue("x") ** e
      @outputs["y"] = invalue("y") ** e
      @outputs["z"] = invalue("z") ** e
      @outputs["w"] = invalue("w") ** e
      return @outputs
    end

    def sqrt()
      @outputs = {}
      x = invalue("x")
      y = invalue("y")
      z = invalue("z")
      w = invalue("w")
      @outputs["x"] = x / Math.sqrt(x.abs)
      @outputs["y"] = y / Math.sqrt(y.abs)
      @outputs["z"] = z / Math.sqrt(z.abs)
      @outputs["w"] = w / Math.sqrt(w.abs)
      return @outputs
    end

    def log()
      @outputs = {}
      b = invalue("b")
      @outputs["x"] = Math.log(invalue("x"), b)
      @outputs["y"] = Math.log(invalue("y"), b)
      @outputs["z"] = Math.log(invalue("z"), b)
      @outputs["w"] = Math.log(invalue("w"), b)
      return @outputs
    end

    def random()
      @outputs = {}
      r = Random.new(invalue("sd"))
      lo = invalue("lo")
      hi = invalue("hi")
      @outputs["x"] = lo + r.rand(hi)
      @outputs["y"] = lo + r.rand(hi)
      @outputs["z"] = lo + r.rand(hi)
      @outputs["w"] = lo + r.rand(hi)
      return @outputs
    end

    def perlin()
      @outputs = {}
      sd = invalue("sd")
      if sd.nan? then sd = 0 end
      sd = sd.abs
      if sd < 1 then sd = sd + 1 end
      p = Perlin::Generator.new(sd.to_int, 1, 1, {:classic => true})
      x = invalue("x")
      y = invalue("y")
      z = invalue("z")
      if x.nan? then x = 98.1222 end
      if y.nan? then y = 2877.211 end
      if z.nan? then z = 12383.122 end
      @outputs["v"] = p[x, y, z]
      return @outputs
    end

    def simplex()
      @outputs = {}
      sd = invalue("sd")
      if sd.nan? then sd = 0 end
      sd = sd.abs
      if sd < 1 then sd = sd + 1 end
      s = Perlin::Generator.new(sd.to_int, 1, 1, {:classic => false})
      x = invalue("x")
      y = invalue("y")
      z = invalue("z")
      if x.nan? then x = 98.1222 end
      if y.nan? then y = 2877.211 end
      if z.nan? then z = 12383.122 end
      @outputs["v"] = s[x, y, z]
      return @outputs
    end

    def mag()
      @outputs = {}
      x = invalue("x")
      if x.nan? then x = 0 end
      y = invalue("y")
      if y.nan? then y = 0 end
      z = invalue("z")
      if z.nan? then z = 0 end
      w = invalue("w")
      if w.nan? then w = 0 end
      @outputs["m"] = Math.sqrt(x * x +
                                    y * y +
                                    z * z +
                                    w * w)
      return @outputs
    end

    def norm()
      @outputs = {}
      x = invalue("x")
      if x.nan? then x = 0 end
      y = invalue("y")
      if y.nan? then y = 0 end
      z = invalue("z")
      if z.nan? then z = 0 end
      w = invalue("w")
      if w.nan? then w = 0 end
      @outputs["m"] = Math.sqrt(x * x +
                                    y * y +
                                    z * z +
                                    w * w)
      @outputs["x"] = x / @outputs["m"]
      @outputs["y"] = y / @outputs["m"]
      @outputs["z"] = z / @outputs["m"]
      @outputs["w"] = w / @outputs["m"]
      return @outputs
    end

    def resize()
      @outputs = {}
      x = invalue("x")
      if x.nan? then x = 0 end
      y = invalue("y")
      if y.nan? then y = 0 end
      z = invalue("z")
      if z.nan? then z = 0 end
      w = invalue("w")
      if w.nan? then w = 0 end
      m = invalue("m")
      if m.nan? then m = 1 end
      @outputs["m"] = Math.sqrt((x * x) +
                                    (y * y) +
                                    (z * z) +
                                    (w * w))
      @outputs["x"] = x * m / @outputs["m"]
      @outputs["y"] = y * m / @outputs["m"]
      @outputs["z"] = z * m / @outputs["m"]
      @outputs["w"] = w * m / @outputs["m"]
      return @outputs
    end

    def min()
      @outputs = {}
      x = invalue("x")
      y = invalue("y")
      z = invalue("z")
      w = invalue("w")
      a = invalue("a")
      b = invalue("b")
      c = invalue("c")
      d = invalue("d")
      if x.nan? then x = 0 end
      if y.nan? then y = 0 end
      if z.nan? then z = 0 end
      if w.nan? then w = 0 end
      if a.nan? then a = 0 end
      if b.nan? then b = 0 end
      if c.nan? then c = 0 end
      if d.nan? then d = 0 end
      @outputs["x"] = [x, a].min
      @outputs["y"] = [y, b].min
      @outputs["z"] = [z, c].min
      @outputs["w"] = [w, d].min
      return @outputs
    end

    def max()
      @outputs = {}
      x = invalue("x")
      y = invalue("y")
      z = invalue("z")
      w = invalue("w")
      a = invalue("a")
      b = invalue("b")
      c = invalue("c")
      d = invalue("d")
      if x.nan? then x = 0 end
      if y.nan? then y = 0 end
      if z.nan? then z = 0 end
      if w.nan? then w = 0 end
      if a.nan? then a = 0 end
      if b.nan? then b = 0 end
      if c.nan? then c = 0 end
      if d.nan? then d = 0 end
      @outputs["x"] = [x, a].max
      @outputs["y"] = [y, b].max
      @outputs["z"] = [z, c].max
      @outputs["w"] = [w, d].max
      return @outputs
    end

    def abs()
      @outputs = {}
      x = invalue("x")
      y = invalue("y")
      z = invalue("z")
      w = invalue("w")
      if x.nan? then x = 0 end
      if y.nan? then y = 0 end
      if z.nan? then z = 0 end
      if w.nan? then w = 0 end
      @outputs["x"] = x.abs
      @outputs["y"] = y.abs
      @outputs["z"] = z.abs
      @outputs["w"] = w.abs
      return @outputs
    end

    def cmp()
      @outputs = {}
      if invalue("d") < 0 then
        @outputs["x"] = invalue("a")
        @outputs["y"] = invalue("b")
        @outputs["z"] = invalue("c")
        @outputs["w"] = invalue("d")
      else
        @outputs["x"] = invalue("x")
        @outputs["y"] = invalue("y")
        @outputs["z"] = invalue("z")
        @outputs["w"] = invalue("w")
      end
      return @outputs
    end
  end
end

