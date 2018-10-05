kpse.set_program_name("luatex")
local glyphload = require "htflibs.glyphload"
local loadenc =  require "loadenc"

local encfile = arg[1]

local enc = loadenc.parse(loadenc.load(encfile))

for i, k in pairs(enc) do
	print(i,k)
end

