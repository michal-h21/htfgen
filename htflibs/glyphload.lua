-- local basedir = arg[0]:match("(.+)/[^%/]+") or "."
-- local basedir = arg[0]:match("(.+%/htfgen%/)") or "."
-- find base dir for the glyph lists
local basedir = kpse.find_file("htflib.lua"):gsub("htflibs%/htflib%.lua","")
basedir = basedir .. "/glyphlists/"

-- the glyph lists contain glyphs that point to Unicode Private Use Areas, we need to skip such glyphs
-- as they are not supported in browsers
local puas = {{0xE000, 0xF8FF}, {0xF0000, 0xFFFFD}, {0x100000, 0x10FFFD}}

local is_pua = function(number)
  for hex in number:gmatch("([0-9a-fA-F]+)") do
    local num = tonumber(hex, 16) 
    if not num then print(hex) end
    for _, range in ipairs(puas) do
      if range[1] <= num and num <= range[2] then 
        return true 
      end
    end
  end
  return false
end

-- escape invalid xml characters: & < >
local xml_escapes = {[38] = "&amp;", [60] = "&lt;", [62] = "&gt;", [96] = "&#x60;"}

local make_entity = function(hex)
  -- return ascii character instead of entity if possible
  local charcode = tonumber(hex, 16) or 0
  if 32 <= charcode and charcode <= 128 then
    return xml_escapes[ charcode ] or  string.char(charcode)
  end
  return "&#x" .. hex .. ";"
end

local function update_glyph_list(t, glyph, hex)
  if glyph then
    hex = hex:gsub("%s*$","")
    -- glyph can point to several characters
    local x = {}
    for code in hex:gmatch("([a-fA-F0-9]+)") do
      if not is_pua(code) then
        x[#x+1] = make_entity(code)
      end
    end
    if #x > 0 then
      t[glyph] = table.concat(x)
    end
  end
  -- return t
end

local load_glyphlist = function(file, t)
	local t = t or {}
	if not file then return t, "No glyph list file" end
  for line in io.lines(file) do
    local glyph, hex = line:match("([%a%.0-9%_]+);([%a0-9 ]+)")
    update_glyph_list(t, glyph, hex)
  end
	return t
end

local load_alt_glyphs = function(t)
	for line in io.lines(basedir .. "altglyphs.txt") do
		if not line:match("^%s*#") then
			line = line:gsub("#.*","")
			local hex = line:match("0x([a-f0-9]+)")
			if hex and not is_pua(hex) then 
				hex = hex:upper()
				local c = string.explode(line," ")
				c[#c] = nil
				for _,item in ipairs(c)  do
					t[item] = make_entity(hex)
				end
			end
		end
	end
	return t
end

local function load_glyph_to_unicode(filename, t)
  local t = t or {}
  for line in io.lines(filename) do
    local glyph, chars = line:match("\\p.*{(.-)}{(.-)}")
    if glyph and glyph:match("tfm:zpzdr") then print(filename, glyph) end

    update_glyph_list(t, glyph, chars)
  end
  return t
end

local parse_glyphlist = function()
  local t = {}
	local glyphlist = kpse.find_file("glyphlist.txt","map")
	local texglyphs = kpse.find_file("texglyphlist.txt","map")
	local pdfglyphs = kpse.find_file("pdfglyphlist.txt","map")
  local glyphtounicode = kpse.find_file("glyphtounicode.tex", "tex")
  local ntx =kpse.find_file("glyphtounicode-ntx.tex", "tex")
  local cmr =kpse.find_file("glyphtounicode-cmr.tex", "tex")
	t = load_glyphlist(glyphlist, t)
	t = load_glyphlist(texglyphs, t)
	t = load_glyphlist(pdfglyphlist, t)
  t = load_glyph_to_unicode(glyphtounicode, t)
  t = load_glyph_to_unicode(ntx, t)
  t = load_glyph_to_unicode(cmr, t)
  t = load_glyphlist(basedir .. "unimathsymbols.txt",t)
	t = load_glyphlist(basedir .. "additional-glyphlist.txt", t)
	t = load_glyphlist(basedir .. "goadb100.txt", t)
	t = load_alt_glyphs(t)
	t = load_glyphlist(basedir .. "glyphlist-extended.txt", t)
  -- file with fixes for wrong glyphs to unicode mappings 
  -- especially the ones that map to PUA
  t = load_glyphlist(basedir .. "glyphlist-fixes.txt", t)
  g =  setmetatable({t=t},{__index = t})
	g.getGlyph = function(self,x)
		local x = x or ""
    -- match glyph in the glyph table
		local y = self[x]  
		if y then return y end
    -- glyph name may be actually unicode value
		local c =  x:match("u[n]?[i]?([A-Fa-f0-9]+)%.?.*$")
    if c then return make_entity(c) end
    -- test only part of glyph before "." -- disregard the modifier after it
    local basepart = x:match("^([^%.]+)") or ""
    return self[basepart]
	end
  g.getAllGlyphs = function(self)
    return self.t
  end
	return g
	--]]
end


return parse_glyphlist()
