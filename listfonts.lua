kpse.set_program_name "luatex"

-- projít fonty z balíčku psnfss a vytvořit pro ně 4ht soubory
--
--
local function process_package(name, fonts)
  -- find the sty file location
  local find_font = function(str,command) 
    local search_term = "\\" .. command .."default}?{(.-)}"
    local match = str:match(search_term)
    return match
  end
  local pkgfile = kpse.find_file(name .. ".sty", "tex")
  if not pkgfile then return nil, "Cannot locate package " .. name end
  local f = io.open(pkgfile, "r")
  local content = f:read("*all")
  -- find font family names
  for _, cmd in ipairs {"rm", "sf", "tt"} do
    local font = find_font(content,cmd)
    table.insert(fonts, font)
  end
  return fonts
end

local function remove_duplicates(fonts)
  -- remove duplicate family names
  local t = {}
  table.sort(fonts)
  local used = {}
  for _, k in ipairs(fonts) do
    if not used[k] then
      t[#t+1] = k
    end
    used[k] = true
  end
  return t
end

local function find_fd_files(family)
  local encodings = {"ot1", "ts1", "t1", "8r"}
  for _, enc in ipairs(encodings) do
    local filename = enc .. family .. ".fd"
    print(kpse.find_file(filename, "tex"))
  end
end


local fonts = {}
local font_packages = {"avant", "bookman", "chancery", "newcent"} 

for _, pkg_name in ipairs(font_packages) do
  fonts = process_package(pkg_name, fonts)
end

fonts = remove_duplicates(fonts)

for _, family in ipairs(fonts) do
  find_fd_files(family)
end



