addEvent("onChat2SendMessage", true)
addEvent("onPlayerChat2")

local isDefaultOutput = true
local minLength = 1
local maxLength = 96

function clear(player)
  triggerClientEvent(player, "onChat2Clear", player)
end

function show(player, bool)
  triggerClientEvent(player, "onChat2Show", player, bool)
end

function isVisible(player)
  return getElementData(player, "chat2IsVisible", false)
end

function output(player, message)
  triggerClientEvent(player, "onChat2Output", player, message)
end

function useCustomEventHandlers(bool)
  isDefaultOutput = not bool
end

function RGBToHex(red, green, blue)
  if (red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) then
    return nil
  end

  return string.format("#%.2X%.2X%.2X", red, green, blue)
end

function onChatSendMessage(message, messageType)
  if type(message) ~= "string" or utf8.len(message) < minLength or utf8.len(message) > maxLength then
    return
  end

  if messageType ~= "0" and messageType ~= "2" then
    return
  end

  if utf8.sub(message, 0, 1) == "/" then
    handleCommand(client, message)
    return
  end

  messageType = tonumber(messageType)

  if not isDefaultOutput then
    triggerEvent("onPlayerChat2", root, client, message, messageType)
    return
  end

  defaultOutput(client, message, messageType)
end

function defaultOutput(sender, message, messageType)
  local nickname = getPlayerName(sender)
  local team = getPlayerTeam(sender)
  local text = string.format("%s#ffffff: %s", nickname, message)
  local teamColor

  if team then
    local r, g, b = getTeamColor(team)
    teamColor = RGBToHex(r, g, b)
  end

  if teamColor then
    text = string.format("%s%s", teamColor, text)
  end

  if messageType == 0 then
    for _, player in ipairs(getElementsByType("player")) do
      output(player, text)
    end
  end

  if messageType == 2 and team then
    text = string.format("%s(team) %s", teamColor, text)
    for _, player in ipairs(getPlayersInTeam(team)) do
      output(player, text)
    end
  end

  outputServerLog(pregReplace(text, "#[a-f0-9]{6}", "", "i"))
end

function handleCommand(client, input)
  local splittedInput = split(input, " ")
  local slashCmd = table.remove(splittedInput, 1)
  local cmd = utf8.sub(slashCmd, 2, utf8.len(slashCmd))
  executeCommandHandler(cmd, client, unpack(splittedInput))
end

-- listen for "say / teamsay" from player console
function onPlayerChat(message, messageType)
  if isDefaultOutput then
    defaultOutput(source, message, messageType)
  end
end

-- listen for messages that were sent from resources
function onChatMessage(message, elementOrResource)
  if not isElement(elementOrResource) then
    output(root, message)
  end
end

addEventHandler("onChat2SendMessage", resourceRoot, onChatSendMessage)
addEventHandler("onPlayerChat", root, onPlayerChat)
addEventHandler("onChatMessage", root, onChatMessage)
