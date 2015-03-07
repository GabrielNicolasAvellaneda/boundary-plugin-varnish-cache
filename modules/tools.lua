--
-- Module.
--
local tools = {}


-- Requires.
local string = require('string')

--
-- Limit a given number x between two boundaries.
-- Either min or max can be nil, to fence on one side only.
--
tools.fence = function(x, min, max)
  return (min and x < min and min) or (max and x > max and max) or x
end

--
-- Encode data in Base64 format.
--
tools.base64 = function(data)
  local _lookup = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  return ((data:gsub('.', function(x)
    local r, b = '', x:byte()
    for i = 8, 1, -1 do
      r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
    end
    return r
  end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if #x < 6 then
      return ''
    end
    local c = 0
    for i = 1, 6 do
      c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
    end
    return _lookup:sub(c + 1, c + 1)
  end) .. ({
    '',
    '==',
    '='
  })[#data % 3 + 1])
end


--
-- Split a string into a table
-- 

tools.split = function (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; local i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

--
-- Export.
--
return tools