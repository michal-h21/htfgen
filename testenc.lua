kpse.set_program_name("luatex")
local parsepl = require "parsepl"
local pl_loader = require "pl_loader"
local loadenc = require "loadenc"

local parse_glyphlist = function()
  local t = {}
  for line in io.lines("glyphlist-extended.txt") do
    local glyph, hex = line:match("([%a]+);([%a0-9]+)")
    if glyph then
      t[glyph] = hex
    end
  end
  return t
end



local name = arg[1] or "ntxsyralt"
local enc = arg[2] or "ntxmiaalt"
local s = parsepl.parse(pl_loader.load(name))
local symbols = loadenc.parse(loadenc.load(enc))
local glyphs = parse_glyphlist()

for k,v in ipairs(s) do
  if v.type=="character" then
    local symbol = symbols[v.value]
    print("+",v.value,string.char(v.value), symbol, glyphs[symbol])
  end
end

