function RGBToHex(red, green, blue)
  if (red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) then
    return nil
  end

  return string.format("#%.2X%.2X%.2X", red, green, blue)
end

function math.round(number, decimals, method)
  decimals = decimals or 0
  local factor = 10 ^ decimals
  if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
  else return tonumber(("%."..decimals.."f"):format(number)) end
end