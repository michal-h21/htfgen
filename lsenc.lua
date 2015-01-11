kpse.set_program_name("luatex")
local parsepl = require "parsepl"
local pl_loader = require "pl_loader"

local s = pl_loader.load("ntxmia")
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
for k,v in ipairs(t) do
  if v.type=="mapfont" then
    local j = pl_loader.load(v.name)
    print(v.name, j:len())
    local pl = parsepl.parse(j)
    print(v.name,find_enc(pl))
  end
end
