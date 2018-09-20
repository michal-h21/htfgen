local libertineproperty = function(x)
  local property = x:gsub("I","italic")
  property = property:gsub("B", "bold")
  return string.lower(property)
end


local fontfixes = {
["Lin Libertine"] = function(x)
  return "Linux Libertine O", libertineproperty(x)
end,
["Lin Biolinum"] = function(x)
  return "Linux Biolinum O", libertineproperty(x) .. "sans"
end
}

for rec in io.lines() do
  local filename = rec:match("([^%/]+).tfm$")
  local propertystring = filename:lower()
  local fontname = filename:match("([^%-]+)")
  local t = {}
  fontname:gsub("([A-Z]*[a-z]+)", function(x) t[#t+1] = x end)
  fontname = table.concat(t," ")
  local fontfunc = fontfixes[fontname]
  if fontfunc then
    fontname, propertystring = fontfunc(filename)
    propertystring = string.lower(propertystring)
  end
  local bold = propertystring:match("bold") and "font-weight: bold;"
  local slanted = propertystring:match("slanted") and "font-style: oblique;"
  local italic = propertystring:match("italic") and "font-style: italic;"
  local smallcaps = (propertystring:match("sc") or propertystring:match("smallcaps")) and "font-variant: small-caps;"
  local sans = propertystring:match("sans") and "sans-serif"
  local mono = propertystring:match("mono") and "monospace"
  local cssfontname = string.format("font-name: '%s', %s", fontname,(mono or sans) or "serif")
  local t = {}
  table.insert(t,bold)
  table.insert(t,slanted)
  table.insert(t,italic)
  table.insert(t,smallcaps)
  table.insert(t,cssfontname)
  local css = table.concat(t, " ")
  print(string.format('\\<%s\\><<<', filename))
  print(".lm-ec")
  print("htfcss: ".. filename .." " ..css)
  print(">>>")
  print(string.format("\n\\AddFont{%s}{alias/t1fonts/%s}{}\n", filename, filename))
end
