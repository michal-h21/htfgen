local M = {}

local pfbfiles = {}
local stdenc = require "htflibs.adobestdenc"

local function load_pfb_file(filename)
  local content = pfbfiles[filename]
  if not content then
    local f = io.open(filename, "rb")
    content = f:read("*all")
    pfbfiles[filename] = content
    f:close()
  end
  return content
end

local function parse_encoding(encodingstring)
  local t = {}
  -- initialize the encoding table with .notdef glyphs
  for i=0,255 do
    t[i] = ".notdef"
  end
  for position, glyph in encodingstring:gmatch("dup ([0-9]+) %/(.-) put") do
    t[tonumber(position)] = glyph
  end

end

function M.get_encoding(filename)
  local content = load_pfb_file(filename)
  local encodingstring = content:match("/Encoding (.-) def")
  if encodingstring == "StandardEncoding" then
    return stdenc
  end
  return parse_encoding(encodingstring)
end

function M.parse_pfb(content)
  local full_name = content:match("FullName%s*%((.-)%)")
  local family_name = content:match("FamilyName%s*%((.-)%)")
  -- full_name is family name plus style, so we need to remove the family name from
  -- it to get the style
  local style = full_name:sub( string.len(family_name) + 1)
  return family_name, style
end

function M.parse_pfbfile(filename)
  local content = load_pfb_file(filename)
  return M.parse_pfb(content)
end

return M
