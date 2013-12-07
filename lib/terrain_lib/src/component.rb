require 'perlin'

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
    # converts metadata to Components, and then generates terrain from it.
    def convert(metadata, node = "result", prev = {})
        newnode = {:type => metadata[node]["type"], :outputs => metadata[node]["outputs"], :inputs => {}}
        prev[node] = newnode
        metadata[node]["inputs"].each do |k,v|
            newnode[:inputs][k] = [convert(metadata, v.first, prev), v[-1]]
        end
        return Terrain::Component.new(newnode)
    end

    def generate(metadata)
        return convert(metadata).generate()
    end

  class Component
    def initialize( params={} )
      @outputs = params[:outputs]
      if @outputs == nil then @outputs = {} end
      @inputs = params[:inputs]
      if @inputs == nil then @inputs = {} end
      @type = params[:type]
      if @type == nil then @type = "value" end
    end

    def sample(coord)
        @@sampler = coord
        result = self.output
        reset()
        return result
    end
    
    def reset()
        if @type != "value" then @outputs = {} end
        @inputs.each do |k,v|
            if v.first != "sampler" then
                v.first.reset()
            end
        end
    end
    
    def generate()
      filename = Time.new.getutc.to_s + ".obj"
      File.open(filename, mode="w"){ |file|
        # TO WRITE: file.write(str)
        # NOTE: does not append \n
        for x in 0..200
          for y in 0..200
            # get the value at this position
            hgt = self.sample({"x" => x, "y" => y})["z"]
            self.reset()
            file.write("v #{x.to_s} #{hgt.to_s} #{y.to_s}\n")
          end
        end
        for x in 1..200
          for y in 1...200
            nrow = 201 * x
            row = nrow - 201
            curr = row + y
            ncurr = nrow + y
            file.write("f #{ncurr.to_s} #{(ncurr + 1).to_s} #{(curr + 1).to_s} #{curr.to_s}\n")
          end
        end
      }
      return filename
    end

    def output()
      if @outputs.keys.size > 0 then return @outputs end
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
      @outputs["z"] = invalue("v")
      return @outputs
    end

    def value()
      return @outputs
    end

    def mult()
      @outputs["x"] = invalue("x") * invalue("b")
      @outputs["y"] = invalue("y") * invalue("b")
      @outputs["z"] = invalue("z") * invalue("b")
      @outputs["w"] = invalue("w") * invalue("b")
      return @outputs
    end

    def div()
      @outputs["x"] = invalue("x") / invalue("b")
      @outputs["y"] = invalue("y") / invalue("b")
      @outputs["z"] = invalue("z") / invalue("b")
      @outputs["w"] = invalue("w") / invalue("b")
      return @outputs
    end

    def add()
      @outputs["x"] = invalue("x") + invalue("a")
      @outputs["y"] = invalue("y") + invalue("b")
      @outputs["z"] = invalue("z") + invalue("c")
      @outputs["w"] = invalue("w") + invalue("d")
      return @outputs
    end

    def sub()
      @outputs["x"] = invalue("x") - invalue("a")
      @outputs["y"] = invalue("y") - invalue("b")
      @outputs["z"] = invalue("z") - invalue("c")
      @outputs["w"] = invalue("w") - invalue("d")
      return @outputs
    end

    def exp()
      @outputs["x"] = invalue("x") ** invalue("e")
      @outputs["y"] = invalue("y") ** invalue("e")
      @outputs["z"] = invalue("z") ** invalue("e")
      @outputs["w"] = invalue("w") ** invalue("e")
      return @outputs
    end

    def sqrt()
      @outputs["x"] = Math.sqrt(invalue("x"))
      @outputs["y"] = Math.sqrt(invalue("y"))
      @outputs["z"] = Math.sqrt(invalue("z"))
      @outputs["w"] = Math.sqrt(invalue("w"))
      return @outputs
    end

    def log()
      @outputs["x"] = Math.log(invalue("x"), invalue("b"))
      @outputs["y"] = Math.log(invalue("y"), invalue("b"))
      @outputs["z"] = Math.log(invalue("z"), invalue("b"))
      @outputs["w"] = Math.log(invalue("w"), invalue("b"))
      return @outputs
    end

    def random()
      r = Random.new(invalue("sd"))
      @outputs["x"] = invalue("lo") + r.rand(invalue("hi"))
      @outputs["y"] = invalue("lo") + r.rand(invalue("hi"))
      @outputs["z"] = invalue("lo") + r.rand(invalue("hi"))
      @outputs["w"] = invalue("lo") + r.rand(invalue("hi"))
      return @outputs
    end

    def perlin()
        sd = invalue("sd")
        if sd.to_s == "NaN" then sd = 0 end
        sd = sd.abs
        if sd < 1 then sd = sd + 1 end
        p = Perlin::Generator.new(sd.to_int, 1, 1, {:classic => true})
        x = invalue("x")
        y = invalue("y")
        z = invalue("z")
        puts("(#{x}, #{y}, #{z})\n")
        if x.to_s == "NaN" then x = 98.1222 end
        if y.to_s == "NaN" then y = 2877.211 end
        if z.to_s == "NaN" then z = 12383.122 end
        @outputs["v"] = p[x, y, z]
        return @outputs
    end

    def simplex()
        sd = invalue("sd")
        if sd.to_s == "NaN" then sd = 0 end
        sd = sd.abs
        if sd < 1 then sd = sd + 1 end
        s = Perlin::Generator.new(sd.to_int, 1, 1, {:classic => false})
        x = invalue("x")
        y = invalue("y")
        z = invalue("z")
        if x.to_s == "NaN" then x = 98.1222 end
        if y.to_s == "NaN" then y = 2877.211 end
        if z.to_s == "NaN" then z = 12383.122 end
        @outputs["v"] = s[x, y, z]
        return @outputs
    end

    def mag()
      @outputs["m"] = Math.sqrt(invalue("x") * invalue("x") +
                                invalue("y") * invalue("y") +
                                invalue("z") * invalue("z") +
                                invalue("w") * invalue("w"))
      return @outputs
    end

    def norm()
      @outputs["m"] = Math.sqrt(invalue("x") * invalue("x") +
                                invalue("y") * invalue("y") +
                                invalue("z") * invalue("z") +
                                invalue("w") * invalue("w"))
      @outputs["x"] = invalue("x") / @outputs["m"]
      @outputs["y"] = invalue("x") / @outputs["m"]
      @outputs["z"] = invalue("x") / @outputs["m"]
      @outputs["w"] = invalue("x") / @outputs["m"]
      return @outputs
    end

    def resize()
      @outputs["m"] = Math.sqrt(invalue("x") * invalue("x") +
                                    invalue("y") * invalue("y") +
                                    invalue("z") * invalue("z") +
                                    invalue("w") * invalue("w"))
      @outputs["x"] = invalue("x") * invalue("m") / @outputs["m"]
      @outputs["y"] = invalue("x") * invalue("m") / @outputs["m"]
      @outputs["z"] = invalue("x") * invalue("m") / @outputs["m"]
      @outputs["w"] = invalue("x") * invalue("m") / @outputs["m"]
      return @outputs
    end
  end
end

