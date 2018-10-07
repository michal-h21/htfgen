-- local basedir = arg[0]:match("(.+)/[^%/]+") or "."
local basedir = arg[0]:match("(.+%/htfgen%/)") or "."
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

local make_entity = function(hex)
  return "&#x" .. hex .. ";"
end

local load_glyphlist = function(file, t)
	local t = t or {}
	if not file then return t, "No glyph list file" end
  for line in io.lines(file) do
    local glyph, hex = line:match("([%a%.0-9%_]+);([%a0-9 ]+)")
    if glyph then
      hex = hex:gsub("%s*$","")
      if not is_pua(hex) then
        t[glyph] = make_entity(hex)
      end
    end
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

local parse_glyphlist = function()
  local t = {}
	local glyphlist = kpse.find_file("glyphlist.txt","map")
	local texglyphs = kpse.find_file("texglyphlist.txt","map")
	t = load_glyphlist(glyphlist, t)
	t = load_glyphlist(texglyphs, t)
  t = load_glyphlist(basedir .. "unimathsymbols.txt",t)
	t = load_glyphlist(basedir .. "additional-glyphlist.txt", t)
	t = load_glyphlist(basedir .. "goadb100.txt", t)
	t = load_alt_glyphs(t)
	t = load_glyphlist(basedir .. "glyphlist-extended.txt", t)
  -- file with fixes for wrong glyphs to unicode mappings 
  -- especially the ones that map to PUA
  t = load_glyphlist(basedir .. "glyphlist-fixes.txt", t)
  t =  setmetatable({},{__index = t})
	t.getGlyph = function(self,x)
		local x = x or ""
    -- match glyph in the glyph table
		local y = self[x]  
		if y then return y end
    -- glyph name may be actually unicode value
		local c =  x:match("u[n]?[i]?([A-Fa-f0-9]+)$")
    if c then return c end
    -- test only part of glyph before "." -- disregard the modifier after it
    local basepart = x:match("^([^%.]+)") or ""
    return self[basepart]
	end
	return t
	--]]
end


return parse_glyphlist()
