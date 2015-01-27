kpse.set_program_name("luatex")
local parsepl = require "parsepl"
local pl_loader = require "pl_loader"
local loadenc = require "loadenc"
local glyphs = require "glyphload"


local name = arg[1] or "bchr8t"
local enc = arg[2] or loadenc.find(name)
if not enc then 
	print("Cannot load enc file for "..name)
	os.exit()
end

local list,fonttype = pl_loader.load(name)
local s = parsepl.parse(list)
local symbols = loadenc.parse(loadenc.load(enc))


local mychar = function(x)
	if x > 31 then
		return string.char(x)
	end
	return ""
end

for k,v in ipairs(s) do
  if v.type=="character" then
    local symbol = symbols[v.value]
    if v.iden_type == "C" then
      print(v.value, symbol, symbol)
    else
      print(v.value, symbol, glyphs:getGlyph(symbol))
    end
  end
end
