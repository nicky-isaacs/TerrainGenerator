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
    # converts metadata to Components, and then generates terrain from it.
    def generate(metadata)
    
    end

  class Component
    def initialize( params={} )
      @outputs = params[:outputs]
      if @outputs == nil then @outputs = {} end
      @inputs = params[:inputs]
      if @inputs == nil then @inputs = {} end
      @type = params[:type]
      if @type == nil then @type = "value" end
      @name = params[:name]
      if @name == nil then @name = "unnamed" end
    end

    def sample(coord)
        @@sampler = coord
        result = self.output
        reset()
        return result
    end
    
    def reset()
        @outputs = {}
        @@sampler = nil
        @inputs.each do |k,v|
            if v != "sampler" then
                v.first.reset()
            end
        end
    end
    
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
}
=end
    def generate()
      
      filename = Time.new.getutc.to_s + ".obj"
      File.open(filename, mode="w"){ |file|
        # TO WRITE: file.write(str)
        # NOTE: does not append \n
        
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
      end
      # -1 indicates last element (have to remind myself not to "fix" this)
      return src.first.output[src[-1]]
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
      r = Random.new(invalue("sd") + 1233)
      @outputs["x"] = invalue("lo") + r.rand(invalue("hi"))
      @outputs["y"] = invalue("lo") + r.rand(invalue("hi"))
      @outputs["z"] = invalue("lo") + r.rand(invalue("hi"))
      @outputs["w"] = invalue("lo") + r.rand(invalue("hi"))
      return @outputs
    end

    def perlin()
        sd = invalue("sd")
        if sd == Float.NAN then sd = 0 end
        sd = sd.abs
        p = Perlin::Generator.new(sd, 1, 1, {:classic = true})
        x = invalue("x")
        y = invalue("y")
        z = invalue("z")
        w = invalue("w")
        if x == Float.NAN then x = 0 end
        if y == Float.NAN then y = 0 end
        if z == Float.NAN then z = 0 end
        if w == Float.NAN then w = 0 end
        @outputs["v"] = p[x, y, z, w]
        return @outputs
    end

    def simplex()
        sd = invalue("sd")
        if sd == Float.NAN then sd = 0 end
        sd = sd.abs
        s = Perlin::Generator.new(sd, 1, 1, {:classic = false})
        x = invalue("x")
        y = invalue("y")
        z = invalue("z")
        w = invalue("w")
        if x == Float.NAN then x = 0 end
        if y == Float.NAN then y = 0 end
        if z == Float.NAN then z = 0 end
        if w == Float.NAN then w = 0 end
        @outputs["v"] = s[x, y, z, w]
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
