local M = {}
local lfs = require "lfs"
local maplib = require "htflibs.maplib"
local parsepl = require "htflibs.parsepl"
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
      table.insert(used_fonts, mapfont)
      -- print(mapfont, v.name, v.identifier)
    end
  end
  params.characters = self:resolve_characters(used_fonts, list)
  return params
end

function fontobj:load_enc(encoding)
end

function fontobj:load_style(fontfile)
end

function fontobj:resolve_characters(used_fonts, list)
end

-- the dir should be relative to the fontobj.vfdir
function fontobj:load_virtualfonts(dir)
  local virtuals = {}
  local vfdir = self.vfdir .. "/" .. dir
  local i = 0 
  for name in lfs.dir(vfdir) do
    -- parse just 10 records to speed testing
    i = i + 1
    if i > 10 then break end
    local basename = name:gsub(".vf$", "")
    local filename = vfdir .. "/" .. name
    -- test if it is valid file
    if lfs.attributes(filename)["mode"] == "file" then
      local pl = load_plist("vftovp", filename)
      local list = parsepl.parse(pl)
      local params, msg = self:load_font(basename, list)
      if not status then self:err(msg) end
      virtuals[basename] = params
    end
  end
  self.virtuals = virtuals
  return virtuals
end


-- return constructor
return function(mapname)
  local encfile = kpse.find_file(mapname,"map")
  _, fontobj.map = maplib.parse_map(encfile)
  -- path to virtual fonts directory
  fontobj.vfdir =  kpse.expand_var("$TEXMFDIST") .. "/fonts/vf"
  return setmetatable({}, fontobj)
end
