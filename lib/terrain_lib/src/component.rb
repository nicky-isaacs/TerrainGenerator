require 'json'

#types...
#  result: forwards a single value "z"
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
  class Component
    attr_accessor :inputs

    class << self

      def deserialize(json_string)
        args = JSON.parse(json_string).symbolize_keys
        inflated_outputs=[]
        inflated_inputs=[]

        args[:outputs].each do |o|
          inflated_outputs << deserialize(o)
        end

        args[:inputs].each do |i|
          inflated_inputs << deserialize(i)
        end

        args[:inputs] = inflated_inputs
        args[:outputs] = inflated_outputs

        self.new(args)
      end

    end

    def initialize( params={} )
      @outputs = params[:outputs]
      @inputs = params[:inputs]
      @lock = true unless( @lock = params[:lock] )
      @type = params[:type]
      @name = params[:name]

      if @type == "value" then
        @output
        @lock = true
      end
    end

    def to_json
      json_outputs = []
      json_inputs = []

      inputs.each{ |i| json_inputs << i.to_json }
      outputs.each{ |o| json_outputs << o.to_json }

      {
          :inputs => json_inputs,
          :outputs => json_outputs,
          :lock => lock,
          :type => type
      }.to_json
    end

    def generate(dim, res)
      return self.output["z"]
    end

    def output
      if @outputs != nil or @lock then return @outputs end
      return self.send(@type)
    end

    def output=(val)
      if val == nil then return end
      if not @lock then
        @outputs = val
        if @type == "value" then
          @lock = true
        end
      end
    end

    def invalue(name)
      src = @inputs[name]
      return src.first.output[src[-1]]
    end

    def reset()
      if @type != "value" then @outputs = nil end
    end

# Component getvalue methods
    def pipe()
      @inputs.each{ |name, source|
        @outputs = Hash.new()
        @outputs[name] = invalue(name)
      }
      return @outputs
    end

    def value()
      @lock = true
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

    end

    def simplex()

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
