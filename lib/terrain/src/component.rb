require 'json'

#types..
#  pipe: forwards inputs by name
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

class Component
  attr_accessor :lock, :inputs
	
	class << self
	
		def deserialize(json_string)
			args = JSON.parse(json_string).symbolize_keys
			inflated_outputs=[]
			inflated_inputs=[]

			args[:outputs].each do |o|
				inflated_outputs << deserialize o
			end

			args[:inputs].each do |i|
				inflated_inputs << deserialize i
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

  end

  def output
    if @output != nil or @lock then return @output end
    return self.send(@type)
  end

  def output=(val)
    if val == nil then return end
    if not @lock then
      @output = val
      if @type == "value" then
        @lock = true
      end
    end
  end

  def invalue(name)
    source, sname = @input[name]
    return source.output[sname]
  end

  def reset()
    if @type != "value" then @output = nil end
  end

# Component getvalue methods
  def pipe()
    @input.each{ |name, source|
      @output = Hash.new()
      @output[name] = invalue(name)
    }
    return @output
  end

  def value()
    @lock = true
    return @output
  end

  def mult()
    @output["x"] = invalue("x") * invalue("b")
    @output["y"] = invalue("y") * invalue("b")
    @output["z"] = invalue("z") * invalue("b")
    @output["w"] = invalue("w") * invalue("b")
    return @output
  end

  def div()
    @output["x"] = invalue("x") / invalue("b")
    @output["y"] = invalue("y") / invalue("b")
    @output["z"] = invalue("z") / invalue("b")
    @output["w"] = invalue("w") / invalue("b")
    return @output
  end

  def add()
    @output["x"] = invalue("x") + invalue("a")
    @output["y"] = invalue("y") + invalue("b")
    @output["z"] = invalue("z") + invalue("c")
    @output["w"] = invalue("w") + invalue("d")
    return @output
  end

  def sub()
    @output["x"] = invalue("x") - invalue("a")
    @output["y"] = invalue("y") - invalue("b")
    @output["z"] = invalue("z") - invalue("c")
    @output["w"] = invalue("w") - invalue("d")
    return @output
  end

  def exp()
    @output["x"] = invalue("x") ** invalue("e")
    @output["y"] = invalue("y") ** invalue("e")
    @output["z"] = invalue("z") ** invalue("e")
    @output["w"] = invalue("w") ** invalue("e")
    return @output
  end

  def sqrt()
    @output["x"] = Math.sqrt(invalue("x"))
    @output["y"] = Math.sqrt(invalue("y"))
    @output["z"] = Math.sqrt(invalue("z"))
    @output["w"] = Math.sqrt(invalue("w"))
    return @output
  end

  def log()
    @output["x"] = Math.log(invalue("x"), invalue("b"))
    @output["y"] = Math.log(invalue("y"), invalue("b"))
    @output["z"] = Math.log(invalue("z"), invalue("b"))
    @output["w"] = Math.log(invalue("w"), invalue("b"))
    return @output
  end

  def random()
    r = Random.new(invalue("sd") + 1233)
    @output["x"] = invalue("lo") + r.rand(invalue("hi"))
    @output["y"] = invalue("lo") + r.rand(invalue("hi"))
    @output["z"] = invalue("lo") + r.rand(invalue("hi"))
    @output["w"] = invalue("lo") + r.rand(invalue("hi"))
    return @output
  end

  def perlin()

  end

  def simplex()

  end

  def mag()
    @output["m"] = Math.sqrt(invalue("x") * invalue("x") +
                                 invalue("y") * invalue("y") +
                                 invalue("z") * invalue("z") +
                                 invalue("w") * invalue("w"))
    return @output
  end

  def norm()
    @output["m"] = Math.sqrt(invalue("x") * invalue("x") +
                                 invalue("y") * invalue("y") +
                                 invalue("z") * invalue("z") +
                                 invalue("w") * invalue("w"))
    @output["x"] = invalue("x") / @output["m"]
    @output["y"] = invalue("x") / @output["m"]
    @output["z"] = invalue("x") / @output["m"]
    @output["w"] = invalue("x") / @output["m"]
    return @output
  end

  def resize()
    @output["m"] = Math.sqrt(invalue("x") * invalue("x") +
                                 invalue("y") * invalue("y") +
                                 invalue("z") * invalue("z") +
                                 invalue("w") * invalue("w"))
    @output["x"] = invalue("x") * invalue("m") / @output["m"]
    @output["y"] = invalue("x") * invalue("m") / @output["m"]
    @output["z"] = invalue("x") * invalue("m") / @output["m"]
    @output["w"] = invalue("x") * invalue("m") / @output["m"]
    return @output
  end
end
