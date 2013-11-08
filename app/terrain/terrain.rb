#!/usr/bin/ruby

class HeightMap
    def export(format, filename)
    
    end
    
    def import(format, filename)
    
    end
end

#types...
#  pipe: forwards inputs by name
#  value: outputs constant value by name "v"
#  mult: inputs{"x", "y", "z", "w", "b"} => outputs{"x", "y", "z", "w"}
#  div: inputs{"x", "y", "z", "w", "b"} => outputs{"x", "y", "z", "w"}
#  add: inputs{"x", "y", "z", "w", "a", "b", "c", "d"} => outputs{"x", "y", "z", "w"}
#  sub: inputs{"x", "y", "z", "w", "a", "b", "c", "d"} => outputs{"x", "y", "z", "w"}
#  exp: inputs{"x", "y", "z", "w", "e"} => outputs{"x", "y", "z", "w"}
#  root: inputs{"x", "y", "z", "w", "r"} => outputs{"x", "y", "z", "w"}
#  log: inputs{"b", "x", "y", "z", "w"} => outputs{"x", "y", "z", "w"}
#  random: inputs{"l", "u", "s"} => outputs{"x", "y", "z", "w"}
#  perlin: inputs{"x", "y", "z", "w"} => outputs{"v"}
#  simplex: inputs{"x", "y", "z", "w"} => outputs{"v"}
#  mag: inputs{"x", "y", "z", "w"} => outputs{"m"}
#  norm: inputs{"x", "y", "z", "w"} => outputs{"x", "y", "z", "w"}
#  resize: inputs{"x", "y", "z", "w", "m"} => outputs{"x", "y", "z", "w"}

class Component
    attr_accessor :lock
    
    def new()
        @output = nil
        @lock = false
        @type = "value"
        @name = "noname"
    end

    def output
        return @output
    end
    
    def output=(val)
        if not @lock then
            @output = val
            if @type == "value" then
                @lock = true
            end
        end
    end

# Component getvalue methods
    def pipe()
    
    end

    def value()
    
    end
    
    def mult()
    
    end
    
    def div()
    
    end
    
    def add()
    
    end
    
    def sub()
    
    end
    
    def exp()
    
    end
    
    def root()
    
    end
    
    def log()
    
    end
    
    def random()
    
    end
    
    def perlin()
    
    end
    
    def simplex()
    
    end
    
    def mag()
    
    end
    
    def norm()
    
    end
    
    def resize()
    
    end
end

# generates from this root component, with specified dimensions and resolution
def generate(root, dim, res)

end

