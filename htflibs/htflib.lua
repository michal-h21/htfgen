local M = {}
local loadenc = require "loadenc"
local glyphs = require "htflibs.glyphload"

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
      -- local hexs = string.format("'&#x%s;'", table.concat(char_parts,";&#x"))
      local hexs = table.concat(char_parts)
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
  t[#t+1] = string.format("%s %i %i",name,min,max)
  for i = min, max do 
    local v = htf_table[i] or {}
    local hex = v[3] or ""
    local count = v[1] or ""
    local name = v[2] or ""
    t[#t+1] = string.format("'%s' '' %s %s",hex, name, count)
  end
  t[#t+1] = string.format("%s %i %i",name,min,max)
  return table.concat(t,"\n")
end

-- convert the font object to the htf table
function M.fontobj_to_htf_table(fontobj)
  return M.htf_table(fontobj.font_file, fontobj.characters, fontobj.min, fontobj.max)
end

function M.make_css(fontname, propertystring, familyname)
  local t = {}
  local propertystring = propertystring or ""
  propertystring= propertystring:lower()
  local fontname = fontname:lower()
  local bold = propertystring:match("bold") and "font-weight: bold;"
  local slanted = propertystring:match("slanted") and "font-style: oblique;"
  local italic = propertystring:match("italic") and "font-style: italic;"
  local oblique = propertystring:match("oblique") and "font-style: oblique;"
  local smallcaps = (fontname:match("sc") or fontname:match("smallcaps")) and "font-variant: small-caps;"
  local sans = fontname:match("sans") and "sans-serif"
  local mono = fontname:match("mono") and "monospace"
  local basefamily = sans or mono or "serif";
  local family = string.format("font-family: '%s', %s;", familyname, basefamily)
  table.insert(t,bold)
  table.insert(t,slanted)
  table.insert(t,italic)
  table.insert(t,smallcaps)
  table.insert(t, oblique)
  table.insert(t, family)
  return table.concat(t, " ")
end

function M.fontobj_get_css(fontobj)
  local fontname = fontobj.font_file
  local style = fontobj.style or {}
  return "htfcss:  " .. fontname .. "  " .. M.make_css(fontname, style.styles,  style.familyname) 
end

-- convert the font object to the htf container
function M.fontobj_to_htf_container(fontobj)

end



return M
