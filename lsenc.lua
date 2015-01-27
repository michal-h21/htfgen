kpse.set_program_name("luatex")
local parsepl = require "parsepl"
local pl_loader = require "pl_loader"


local name = arg[1] or "ntxmia"
local s, fonttype = pl_loader.load(name)
--local f = io.open("ntxmia.pl","r")

--local s = f:read("*all")
--f:close()

local find_enc = function(pl)
  for k,v in ipairs(pl) do
    if v.type == "encoding" then
      return v.value
    end
  end
end
local t = parsepl.parse(s)
local print_enc = function(font,enc,fonttype,indent)
	local indent = string.rep("  ",indent)
  print(indent .. font, fonttype, enc)
end

local function list_fonts(t, indent)
	for k,v in ipairs(t) do
		if v.type=="mapfont" then
			local j,fonttype = pl_loader.load(v.name)
			--print(v.name, j:len())
			local pl = parsepl.parse(j)
			print_enc(v.name,find_enc(pl),fonttype,indent)
			if fonttype == "vf" then
				list_fonts(pl,indent+1)
			end
		end
	end
end

print_enc(name,find_enc(t),fonttype,0)

if fonttype == "vf" then
	list_fonts(t,1)
end
