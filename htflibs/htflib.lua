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
      htf_table[k] = {k,v, topicture=true}
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


function M.add_copyright(name, htf_table)
  -- add copyright text to the htf_table
  local name = name or ""
  local license = {
    string.format("%% generated from %s.tfm, %s", name, os.date("%Y-%m-%d-%H:%M")),
    string.format("%% Copyright %s TeX Users Group", os.date("%Y")),
    "%",
    "% This work may be distributed and/or modified under the",
    "% conditions of the LaTeX Project Public License, either",
    "% version 1.3c of this license or (at your option) any",
    "% later version. The latest version of this license is in",
    "%   http://www.latex-project.org/lppl.txt",
    "% and version 1.3c or later is part of all distributions",
    "% of LaTeX version 2005/12/01 or later.",
    "%",
    "% This work has the LPPL maintenance status \"maintained\".",
    "%",
    "% The Current Maintainer of this work",
    "% is the TeX4ht Project <http://tug.org/tex4ht>.",
    "%",
    "% If you modify this program, changing the",
    "% version identification would be appreciated."
  }
  if not htf_table or type(htf_table) ~= "table" then return htf_table end

  -- find longest string in the htf_table, so we can nicely format the license
  local max = math.max
  local len = string.len
  local rep = string.rep
  local max_val = 0
  for i = 2, #license+1 do
    max_val = max(max_val, len(htf_table[i] or ""))
  end
  for i, text in ipairs(license) do
    -- we don't want to add copyright to the first line of the htf_table, so we must use an offset
    local ni = i + 1
    if htf_table[ni] then
      local old_text = htf_table[ni]
      -- we want to format copyright nicely, so we need to add some spacing
      local spacing  = rep(" ",max_val - len(old_text) + 2)
      htf_table[ni] =  old_text .. spacing .. text
    end
  end
  return htf_table
end

function M.htf_table(name, htf_table, min,max)
  local t = {}
  t[#t+1] = string.format("%s %i %i",name,min,max)
  for i = min, max do 
    local v = htf_table[i] or {}
    local hex = v[3] or ""
    local count = v[1] or ""
    local name = v[2] or ""
    local format = "'%s' '' %s %s"
    if v.topicture then
      format =  "'%s' '1' %s %s"
    end
    t[#t+1] = string.format(format,hex, name, count)
  end
  t[#t+1] = string.format("%s %i %i",name,min,max)
  t = M.add_copyright(name, t)
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
  local function prop_match(property, style) 
    -- match font information from either PFB or fontname
    return (propertystring:match(property) or fontname:match(property)) and style
  end
  local bold = prop_match("bold","font-weight: bold;")
  local slanted = prop_match("slanted", "font-style: oblique;")
  local italic = prop_match("italic", "font-style: italic;")
  local oblique = prop_match("oblique", "font-style: oblique;")
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
