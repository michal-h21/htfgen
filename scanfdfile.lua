for line in io.lines() do
  -- local fontname = line:match("%s*%<[^%]+%>%s+[^%s]+%s+([^%s]+)")
  local fontname = line:match("%s*%<[^%]]+%>%s+[^%s]+%s+([^%s]+)")
  -- don't print font substitutions
  if fontname and not fontname:match("[%*%/]") then
    print(fontname)
  end

end
