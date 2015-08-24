local t = {}

local utfchar = unicode.utf8.char
local function write_record(pos, record)
  local pattern = record and "'&#x%04X;'\t''\t%i\t%s" or "'|'\t''\t%i"
  local record = record or pos
  print(string.format(pattern, record, pos, utfchar(record) ))
end

local function write_header(name, min, max)
  print(string.format("%s %i %i", name, min, max))
end

local function write_htf(t)
  local min = t.min or 0
  local max = t.max or 255
  local name =  t.name or ""
  write_header(name, min, max)
  for i=min,max do
    write_record(i, t[i])
  end
  write_header(name, min, max)
end


local pos = 0

local function pos_parse(p)
  if type(p) == "number" then
    return p
  else
    return string.byte(p)
  end
end

local function set_pos(p)
  pos = pos_parse(p)
end

local function get_value(val)
  if type(val) == "number" then 
    return val
  else
    val = val:gsub("[G-Zg-z%+%&%#]","")
    return tonumber(val, 16)
  end
end

local function add_record(t, value)
  local min = math.min(t.min or 255, pos)
  local max = math.max(t.max or 0, pos)
  t.max = max
  t.min= min
  t[pos] = get_value(value)
  pos = pos + 1
end

local function add_sequence(t,init, count)
  local init = get_value(init)
  for x = init, init + count - 1 do
    add_record(t, x)
  end
end

local function set_value(t, pos, val)
  local val = get_value(val)
  local pos = pos_parse(pos)
  t[pos] = val
end


-- sample usage:
--
-- local t = {name="bbm"}
-- set_pos(40)
-- add_record(t,40)
-- add_record(t,41)
-- set_pos(49)
-- add_sequence(t,"U+1D7D9",2)
-- set_pos(65)
-- add_sequence(t,"U+1D538", 26)
-- add_record(t,91)
-- set_pos(93)
-- add_record(t,93)
-- set_pos(97)
-- add_sequence(t,"U+1D552", 26)
-- set_value(t,"C","U+2102")
-- set_value(t,"H","U+210D")
-- set_value(t,"N","U+2115")
-- set_value(t,"P","U+2119")
-- set_value(t,"Q","U+211A")
-- set_value(t,"R","U+211D")
-- set_value(t,"Z","U+2124")

-- write_htf(t)
