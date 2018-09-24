local M = {}

function M.parse_pfb(content)
  local full_name = content:match("FullName%s*%((.-)%)")
  local family_name = content:match("FamilyName%s*%((.-)%)")
  return family_name, full_name
end

function M.parse_pfbfile(filename)
  local f = io.open(filename, "rb")
  local content = f:read("*all")
  f:close()
  return M.parse_pfb(content)
end

return M
