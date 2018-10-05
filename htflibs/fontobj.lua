local M = {}
local maplib = require "htflibs.maplib"


local fontobj = {}
fontobj.__index = fontobj


-- return constructor
return function(mapname)
  local encfile = kpse.find_file(mapname,"map")
  fontobj.map = maplib.parse_map(encfile)
  return setmetatable({}, fontobj)
end
