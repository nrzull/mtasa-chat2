function RGBToHex(red, green, blue)
  if (red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) then
    return nil
  end

  return string.format("#%.2X%.2X%.2X", red, green, blue)
end
