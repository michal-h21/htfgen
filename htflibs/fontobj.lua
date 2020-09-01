local M = {}
local lfs = require "lfs"
local md5 = require "md5"
local maplib = require "htflibs.maplib"
local glyphs = require "htflibs.glyphload"
local loadenc = require "loadenc"
local parsepl = require "htflibs.parsepl"
local pfbparser = require "htflibs.pfbparser"
local pl_loader = require "htflibs.pl_loader"


local uchar = unicode.utf8.char

local load_plist = function(prg,name)
  local command = prg .." "..name
  local prg = io.popen(command, "r")
  local result = prg:read("*all")
  prg:close()
  return result
end

-- font encoding for fonts without map records without encoding
local function null_encoding()
  local t = {}
  for i=0,255 do
    t[i] = ".notdef"
  end
  return t
end

local fontobj = {}
fontobj.__index = fontobj

function fontobj:err(msg)
  print("% font parser error: " .. msg)
end

function fontobj:load_font(fontname, list)
  local params = {}
  local used_fonts = {}
  for _,v in pairs(list) do
    if v.type == "mapfont" then
      -- load all fonts used by virtual font
      local mapfont = self.map[v.name]
      if not mapfont then
        -- probably another virtual font
        local font_plist = pl_loader.load(v.name)
        local list = parsepl.parse(font_plist)
        print("load font", v.name)
        -- TODO: get encoding for that file
        local subfnt,msg = self:load_font(v.name, list)
        -- make encoding by resolving the font
        if subfnt then
          local encoding = self:characters_to_encoding(subfnt.characters) 
          if encoding then
            v.encoding = v.name
            self.map[v.name] = {encoding = v.name}
            self.encodings[v.name] = encoding
            table.insert(used_fonts, v)
          end
        else
          print(msg)
        end
        -- return nil, "font ".. v.name .. " cannot be found in the map file"
      else
        -- print("font encoding", mapfont.encoding)
        if mapfont.encoding then
          self:load_enc(mapfont.encoding)
        else
          -- use encoding from the pfb file
          mapfont.encoding = self:load_pfb_enc(mapfont.fontfile)
        end
        params.style = params.style or self:load_style(mapfont.fontfile)
        v.encoding = mapfont.encoding
        -- print(mapfont, v.name, v.identifier)
        table.insert(used_fonts, v)
      end
    end
  end
  -- if the font is not virtual, use the current font encoding or 8r
  if #used_fonts == 0 then
    local mapfont = self.map[fontname]
    if not mapfont then return nil, "Cannot load font "..fontname end
    local enc = mapfont and mapfont.encoding 
    if not enc then
      enc = self:load_pfb_enc(mapfont.fontfile)
    else
      self:load_enc(enc)
    end
    params.style = self:load_style(mapfont.fontfile)
    used_fonts = {{encoding = enc, identifier="D 0"}}
  end
  -- print("resolve font", fontname)
  params.font_file = fontname

  params.characters, params.missing_glyphs = self:resolve_characters(used_fonts, list)
  params.min, params.max = self:get_font_range(params)
  params.hash = self:get_hash(params)
  -- print("hash", params.hash)
  return params
end

function fontobj:load_enc(encoding)
  -- print("loading encoding: ", encoding)
  if not self.encodings[encoding] then
    local rawenc = loadenc.load(encoding)
    if rawenc then
      self.encodings[encoding] = loadenc.parse(rawenc)
    end
  end
end

function fontobj:characters_to_encoding(characters) 
  local t = {}
  for k,v in pairs(characters) do
    -- glyphs are at the second position in the characters table
    t[k] = v[2]
  end
  return t
end

function fontobj:load_pfb_enc(fontfile)
  if not fontfile then
    -- use the 8r encoding if pfb loading fails
    local enc = "8r"
    self:load_enc(enc)
    return enc
  end
  local pfbfile = kpse.find_file(fontfile, "type1 fonts")
  -- we must fake encoding name. we will name it after the pfb font
  if pfbfile and not self.encodings[fontfile] then
    self.encodings[fontfile] = pfbparser.get_encoding(pfbfile)
  elseif not pfbfile then
    -- return 8r enc if we cannot find the pfb file using kpse
    self:err("Cannot find pfb file for: " .. (fontfile or "unknown"))
    return self:load_pfb_enc(nil)
  end
  return fontfile
end

function fontobj:load_style(fontfile)
  -- print("loading font style: ", fontfile)
  if not fontfile then return "" end
  if not self.fontfiles[fontfile] then
    local pfbfile = kpse.find_file(fontfile, "type1 fonts")
    if pfbfile then
      local familyname, styles = pfbparser.parse_pfbfile(pfbfile)
      if styles then
        -- ToDo: parse the style information for CSS
        local obj = {styles = styles, familyname = familyname}
        self.fontfiles[fontfile] = obj
        -- print(familyname, styles)
      end
    else
      self.fontfiles[fontfile] = {}
    end
  end
  return self.fontfiles[fontfile]
end

-- find lowest and highest character in the font
function fontobj:get_font_range(params)
  local min, max
  for k, _ in pairs(params.characters) do
    min = math.min(k, min or k)
    max = math.max(k, max or k)
  end
  -- print("min, max", min, max)
  return min, max
end

-- calculate font hash
function fontobj:get_hash(params)
  local characters = params.characters
  local t = {}
  -- loop over font characters, we can't use ipairs as there may be holes
  -- and min can be zero
  for i = params.min, params.max do
    -- the characters contain list of subtables
    -- the third element in a subtable contains the HTF string
    local current_char = characters[i] or {}
    t[#t+1] = current_char[3]
  end
  return md5.sumhexa(table.concat(t))

end

-- mapping from wrong accent glyph names 
local accent_replaces =  {
  quoteright = "caron"
}

-- translate font list to the unicode character table
function fontobj:resolve_characters(used_fonts, list)
  local encodings = {}
  local chartable = {}
  local glyph_table = {}
  local missing_glyphs = {}
  local default_encoding 
  local function expand_entities(str)
    local str = str or ""
    local expanded = str:gsub("&#x([0-9a-fA-F]+);", function(a) return uchar(tonumber(a, 16) or 32) end )
    return expanded
  end
  local function update(glyph, current_chars, current_glyphs, current_unicodes)
    local glyph_value = glyphs:getGlyph(glyph) 
    if not glyph_value then
      if glyph ~=".notdef" then
        table.insert(missing_glyphs, glyph)
      end
      glyph_value = ""
    end
    table.insert(current_chars, glyph_value)
    table.insert(current_glyphs, glyph)

    table.insert(current_unicodes, expand_entities(glyph_value))
  end
  local function combine(glyphtbl)
    local combine_glyph = function(first, second)
      return glyphs:getGlyph(second .. first) or glyphs:getGlyph(first .. second) 
    end
    local function try_fixed_accent(name)
      return accent_replaces[name] or name
    end
    -- try to normalize chars composed from accent and base char
    if #glyphtbl == 2 then 
      local first_glyph, second_glyph = expand_entities(glyphtbl[1] or ""), expand_entities(glyphtbl[2] or "")
      local combined = combine_glyph(first_glyph, second_glyph) 
      if not combined then
        -- sometimes wrong names for accents are used, for example "quoteright" in place of caron
        local updated_first = try_fixed_accent(first_glyph)
        local updated_second = try_fixed_accent(second_glyph)
        combined = combine_glyph(updated_first, updated_second)
      end
      return combined
    end
    return nil
  end
  for _,v in ipairs(used_fonts) do
    local enc_pos = v.identifier
    encodings[enc_pos] = self.encodings[v.encoding]
    -- select first encoding as the default encoding
    default_encoding = default_encoding or self.encodings[v.encoding]
  end
  for _, v in ipairs(list) do
    if v.type == "character" then
      local current_glyphs = {}
      -- find the glyphs in the default encoding unless diferent encoding is selected
      local current_enc = default_encoding
      local current_chars = {}
      local current_unicodes = {}
      if #v.map > 0 then
        for _,h in ipairs(v.map) do 
          if h.type == "selectfont" then
            -- select encoding by the name stored in the list
            current_enc = encodings[h.value] or null_encoding()
          elseif h.type == "setchar" then
            -- get the glyph from the current encoding
            local glyph = current_enc[h.value]
            update(glyph, current_chars, current_glyphs, current_unicodes)
          end
        end
      -- probably tfm font with no mappings
      else
        local glyph = default_encoding[v.value]
        update(glyph, current_chars, current_glyphs, current_unicodes)
      end
      -- try to combine accented letters composed from two characters
      local chars = combine(current_glyphs)
      if not chars then
        chars = table.concat(current_chars,"")
      end
      local unicodes = table.concat(current_unicodes)
      local used_glyphs = table.concat(current_glyphs, " ")
      -- print(v.value, chars, unicodes, used_glyphs)
      chartable[v.value] = {v.value, used_glyphs, chars}
    end

  end
  return chartable, missing_glyphs
end

function fontobj:load_font_file(filename, basename, plcommand)
  local pl = load_plist(plcommand, filename)
  local list = parsepl.parse(pl)
  local params, msg = self:load_font(basename, list)
  if not params then self:err(msg) end
  return params
end
function fontobj:load_virtual_font(filename)
  local basename = filename:match("([^%/]+)%.vf$")
  return self:load_font_file(filename, basename, "vftovp")
end

function fontobj:load_tfm_font(filename)
  local basename = filename:match("([^%/]+)%.tfm$")
  return self:load_font_file(filename, basename, "tftopl")
end

-- the dir should be relative to the fontobj.vfdir
-- this function should be probably moved to a support script
function fontobj:load_virtual_fonts(dir)
  local virtuals = {}
  local vfdir = self.vfdir .. "/" .. dir
  local i = 0 
  for name in lfs.dir(vfdir) do
    -- parse just 10 records to speed testing
    i = i + 1
    if i > self.maxvf then break end
    local basename = name:gsub(".vf$", "")
    local filename = vfdir .. "/" .. name
    -- test if it is valid file
    if lfs.attributes(filename)["mode"] == "file" then
      local params = self:load_virtual_font(filename, basename)
      virtuals[basename] = params
    end
  end
  self.virtuals = virtuals
  return virtuals
end


-- return constructor
return function(mapname)
  local encfile = kpse.find_file(mapname,"map")
  -- set to a different value for testing purposes
  fontobj.maxvf = 100000000
  fontobj.encodings = {}
  fontobj.fontfiles = {}
  _, fontobj.map = maplib.parse_map(encfile)
  -- path to virtual fonts directory
  fontobj.vfdir =  kpse.expand_var("$TEXMFDIST") .. "/fonts/vf"
  return setmetatable({}, fontobj)
end
