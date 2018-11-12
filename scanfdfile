local used = {}
for line in io.lines() do
  -- local fontname = line:match("%s*%<[^%]+%>%s+[^%s]+%s+([^%s]+)")
  local fontname = line:match("%s*%<[^%]]+%>%s+[^%s]+%s+([^%s]+)")
  -- don't print font substitutions
  if fontname and not fontname:match("[%*%/]") and not used[fontname] then
    print(fontname)
    used[fontname] = true
  end
end
