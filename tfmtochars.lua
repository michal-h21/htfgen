kpse.set_program_name("luatex")
local parsepl = require "parsepl"
local pl_loader = require "pl_loader"
local loadenc = require "loadenc"
local glyphs = require "glyphload"


local name = arg[1] or "bchr8t"
local enc = arg[2] or loadenc.find(name)
local s = parsepl.parse(pl_loader.load(name))
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
    print("+",v.value,mychar(v.value), symbol, glyphs[symbol])
  end
end

