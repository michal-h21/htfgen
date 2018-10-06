local M = {}
local lfs = require "lfs"
local maplib = require "htflibs.maplib"
local loadenc = require "loadenc"
local parsepl = require "htflibs.parsepl"
local pfbparser = require "htflibs.pfbparser"
local pl_loader = require "htflibs.pl_loader"

local load_plist = function(prg,name)
  local command = prg .." "..name
  local prg = io.popen(command, "r")
  local result = prg:read("*all")
  prg:close()
  return result
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
      local mapfont = self.map[v.name]
      if not mapfont then 
        return nil, "font ".. v.name .. " cannot be found in the map file"
      end
      self:load_enc(mapfont.encoding)
      params.style = self:load_style(mapfont.fontfile)
      v.encoding = mapfont.encoding
      table.insert(used_fonts, v)
      -- print(mapfont, v.name, v.identifier)
    end
  end
  params.characters = self:resolve_characters(used_fonts, list)
  return params
end

function fontobj:load_enc(encoding)
  print("loading encoding: ", encoding)
  if not self.encodings[encoding] then
    self.encodings[encoding] = loadenc.load(encoding)
  end
end

function fontobj:load_style(fontfile)
  print("loading font style: ", fontfile)
  if not self.fontfiles[fontfile] then
    local familyname, styles = pfbparser.parse_pfbfile(kpse.find_file(fontfile,"type1 fonts"))
    if styles then
      -- ToDo: parse the style information for CSS
      local obj = {styles = styles, familyname = familyname}
      self.fontfiles[fontfile] = obj
      print(familyname, styles)
    end
  end
  return self.fontfiles[fontfile]
end

function fontobj:resolve_characters(used_fonts, list)
  for _,v in ipairs(used_fonts) do
    print(v.identifier)
    print(self.encodings[v.encoding])
  end
end

function fontobj:load_virtual_font(filename)
  local basename = filename:match("([^%/]+)%.vf$")
  local pl = load_plist("vftovp", filename)
  local list = parsepl.parse(pl)
  local params, msg = self:load_font(basename, list)
  if not params then self:err(msg) end
  return params
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
