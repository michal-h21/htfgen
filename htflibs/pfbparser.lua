local M = {}

function M.parse_pfb(content)
  local full_name = content:match("FullName%s*%((.-)%)")
  local family_name = content:match("FamilyName%s*%((.-)%)")
  -- full_name is family name plus style, so we need to remove the family name from
  -- it to get the style
  local style = full_name:sub( string.len(family_name) + 1)
  return family_name, style
end

function M.parse_pfbfile(filename)
  local f = io.open(filename, "rb")
  local content = f:read("*all")
  f:close()
  return M.parse_pfb(content)
end

return M
