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
      htf_table[k] = {k,v, hexs}
    elseif v ~= ".notdef" then
      -- print("missing",k,v)
      missing_glyphs[v] = encoding
      htf_table[k] = {k,v}
    else
      htf_table[k] = {k,v}
    end
  end
  return htf_table,min, max,missing_glyphs 
end

-- make containter for the htf font in literate programming format

function M.htf_container(name, path, content)
  local t ={}
  t[#t+1] = string.format('\\<%s\\><<<', name)
  t[#t+1] = content
  t[#t+1] = '>>>'
  t[#t+1] = string.format('\\AddFont{%s}{%s%s}{}',name,path,name)
  return table.concat(t,"\n")
end


function M.htf_table(name, htf_table, min,max)
  local t = {}
  t[#t+1] = string.format("%s\t%i\t%i",name,min,max)
  for i = min, max do 
    local v = htf_table[i] or {}
    local hex = v[3] or "''"
    local count = v[1] or ""
    local name = v[2] or ""
    t[#t+1] = string.format("%s '' %s %s",hex, name, count)
  end
  t[#t+1] = string.format("%s\t%i\t%i",name,min,max)
  return table.concat(t,"\n")
end

return M
