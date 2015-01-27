local parsepl = {}

parsepl.prepare_entry = function(s)
  local x = s:sub(2,-2)
  return x:match("([%a]+)%s+(.+)")
end

parsepl.parse_entry = function(s)

end

-- pl: string with contents of pl file
parsepl.parse = function(pl,actions)
  local actions = actions or parsepl.actions
  local t = {}
  pl:gsub("(%b())",function(list)
    local action,list = parsepl.prepare_entry(list)
    if actions[action] then
      local j = actions[action](list)
      table.insert(t,j)
    end
    return ""
  end)
  return t
end

local xx = function(s) 
  return {type="ss",value=s} 
end

-- characters are encoded either as characters (prefixed with "C"), or
-- as octal number (prefixed with "0")
local get_value = function(iden_type,identifier)
  if iden_type=="C" then
    return string.byte(identifier)
  else
    return tonumber(identifier,8)
  end
end

parsepl.actions = {
CODINGSCHEME= function(s) return {type="encoding", value=s} end,
MAPFONT=function(s) 
  local identifier = s:match("(. [0-9]+)")
  local name = s:match("FONTNAME ([^%)]+)")
  return {type="mapfont",identifier=identifier,name=name}
end,
CHARACTER=function(s)
  -- get char value
  local setchar
  local iden_type,identifier = s:match("([CO]) ([^%s]+)")
  local value = get_value(iden_type,identifier)
  local new_iden_type, new_identifier = s:match("SETCHAR (.) ([^%)]+)")
  if new_iden_type then 
    setchar = get_value(new_iden_type,new_identifier)
  end
	local setcharcnt = 0
	for x in s:gmatch("SETCHAR") do setcharcnt = setcharcnt + 1 end
  local mapfont = s:match("SELECTFONT (. [^%)]+)")
  return {type="character",iden_type=iden_type,value = value, setchar=setchar,selectfont=mapfont, setcharcnt =setcharcnt}
end
}

--[[
local f = io.open("ntxmia.pl","r")

local s = f:read("*all")
f:close()

local t = parsepl.parse(s, parsepl.actions)
for k,v in ipairs(t) do
  print(k)
  for x,y in pairs(v) do
    print("",x,y)
  end
end

--]]

return parsepl


