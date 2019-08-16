-- update the tex4ht literate source for the htf fonts
-- usage texlua update_literate_sources.lua `ls *.htf` < tex4ht-fonts-filename.tex  > tex4ht-fonts-updated.tex

local content = io.read("*all")

local function read_file(filename)
  local f = io.open(filename, "r")
  local content = f:read("*all")
  f:close()
  return content
end

local function update_container(content, font_name, htf_content)
  local matched = false -- detect if we found the htf file
  local escape_name = function(name)
    return name:gsub("%-", "%%-")
  end
  local pattern = "\\<" .. escape_name(font_name) .. "\\><<<(.-)>>>"
  content = content:gsub(pattern, function()
    --  mark this filename as matched in the literate source
    matched = true
    -- replace the match group in the pattern with contents of the htf file
    return pattern:gsub("%%", ""):gsub("%(%.%-%)", function(s) 
      -- the function is used because htf_content may contain characters that 
      -- break gsub function
      return "\n" .. htf_content:gsub("%s*$", "\n")
    end)
  end)
  return content, matched
end


local missing = {}
for _,htf_name in ipairs(arg) do
  local matched
  local font_name = htf_name:gsub(".htf$", "")
  -- if the file isn't 
  local htf_content = read_file(htf_name)
  content, matched = update_container(content, font_name,  htf_content)
  if not matched then 
    -- first try if there is an alternative name for the font container
    -- for example \AddFont{pcrr7t-uni}{unicode/adobe/courier/pcrr7t} 
    local alternative_name = content:match("\\AddFont{([^%}]+)}{[^%}]-%/"..font_name .."}")
    content, matched = update_container(content, alternative_name, htf_content)
    if not  matched then
      table.insert(missing, font_name) 
    end
  end
end

if #missing > 0 then
  print "Some fonts were missing"
  print "Add containers for these to the literate file"
  print "\\<font_name\\><<<"
  print ">>>"
  print ""
  print "\\AddFont{font_name}{path/font_name}"
  for _, name in ipairs(missing) do
    print("Mising font", name)
  end
else 
  print(content)
end



