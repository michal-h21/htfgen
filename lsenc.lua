kpse.set_program_name("luatex")
local parsepl = require "parsepl"
local pl_loader = require "pl_loader"


local name = arg[1] or "ntxmia"
local s = pl_loader.load(name)
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
local print_enc = function(font,enc)
  print(font.."="..enc)
end

print_enc(name,find_enc(t))
for k,v in ipairs(t) do
  if v.type=="mapfont" then
    local j = pl_loader.load(v.name)
    --print(v.name, j:len())
    local pl = parsepl.parse(j)
    print_enc(v.name,find_enc(pl))
  end
end
