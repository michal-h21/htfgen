kpse.set_program_name("luatex")
local parsepl = require "parsepl"

pl_loader.load("ntxmia")
local f = io.open("ntxmia.pl","r")

local s = f:read("*all")
f:close()

local t = parsepl.parse(s, parsepl.actions)
for k,v in ipairs(t) do
  if v.type=="mapfont" then
    local j = pl_loader.load(v.name)
    print(v.name,string.len(j))
  end
end
