local M = {}
local loadenc = require "loadenc"
local glyphs = require "glyphload"

function M.make_htf(encoding)
  local s = loadenc.parse(loadenc.load(encoding))
  local missing_glyphs = {}
  local min,max
  local htf_table = {}
  -- table fof concenating encoding chars
  for k,v in pairs(s) do
    local g = glyphs:getGlyph(v)
    if g then
      min = math.min(k, min or k)
      max = math.max(k, max or k)
      local char_parts = string.explode(g," ")
      local hexs = string.format("'&#x%s;'", table.concat(char_parts,";&#x"))
      table.insert(htf_table,{k,v, hexs})
    elseif v ~= ".notdef" then
      print("missing",k,v)
      missing_glyphs[v] = encoding
      table.insert(htf_table,{k,v})
    else
      table.insert(htf_table,{k,v})
    end
  end
  -- make checksum of the encoding
  return htf_table,missing_glyphs, min, max
end

return M
