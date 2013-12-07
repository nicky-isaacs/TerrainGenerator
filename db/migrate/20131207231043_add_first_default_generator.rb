class AddFirstDefaultGenerator < ActiveRecord::Migration
  def change
    hash = JSON.parse '{
  "h_stretch":{
    "inputs":{
      "y":["sampler","y"],
      "x":["sampler","x"],
      "b":["h_factor","v"]
    },
    "type":"div"
  },
  "v_factor":{
    "outputs":{
      "v":10
    },
    "type":"value"
  },
  "v_stretch":{
    "inputs":{
      "b":["v_factor","v"],
      "x":["noise","v"]
    },
    "type":"mult"
  },
  "h_factor":{
    "outputs":{
      "v":30
    },
    "type":"value"
  },
  "result":{
    "inputs":{
      "v":["v_stretch","x"]
    },
    "type":"result"
  },
  "noise":{
    "inputs":{
      "y":["h_stretch","y"],
      "x":["h_stretch","x"]
    },
    "type":"simplex"
  }
}'
    a = Generator.new(hash)
    a.make_default!
  end
end
