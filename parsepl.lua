local parsepl = {}

parsepl.prepare_entry = function(s)
  local x = s:sub(2,-2)
  return x:match("([%a]+)%s+(.+)")
end

parsepl.parse_entry = function(s)

end

-- pl: string with contents of pl file
parsepl.parse = function(pl,actions)
  local actions = actions or {}
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
  return s 
end

parsepl.actions = {
CODINGSCHEME= function(s) return {type="encoding", value=s} end,
MAPFONT=function(s) 

end,
CHARACTER=xx 
}

local f = io.open("ntxmia.pl","r")

local s = f:read("*all")
f:close()

local t = parsepl.parse(s, parsepl.actions)
for k,v in ipairs(t) do
  print(k,v)
end

return parsepl


