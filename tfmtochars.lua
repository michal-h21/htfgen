kpse.set_program_name("luatex")
local parsepl = require "htflibs.parsepl"
local pl_loader = require "htflibs.pl_loader"
local loadenc = require "loadenc"
local glyphs = require "htflibs.glyphload"


local name = arg[1] or "bchr8t"
local enc = arg[2] or loadenc.find(name)
if not enc then 
	print("Cannot load enc file for "..name)
	os.exit()
end

local list,fonttype = pl_loader.load(name)
local s = parsepl.parse(list)
local encfile = loadenc.load(enc)
if not encfile then
	print("Cannot load enc file "..enc)
	os.exit()
end

local symbols = loadenc.parse(encfile)


for k,v in ipairs(s) do
  if v.type=="character" then
    local symbol = symbols[v.value]
    --[[if v.iden_type == "C" then
      print(v.value, symbol, symbol)
    else -- ]]
      print(v.value, symbol, glyphs:getGlyph(symbol))
    -- end
  end
end
