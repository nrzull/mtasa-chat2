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

function output(player, message)
  triggerClientEvent(player, "onChat2Output", player, message)
end

function useCustomEventHandlers(bool)
  isDefaultOutput = not bool
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
  local text = string.format("%s: %s", nickname, message)
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

  local serverLogMessage = pregReplace(text, "#[a-f0-9]{6}", "", "i")
  if type(serverLogMessage) ~= "string" then
    serverLogMessage = text
  end

  outputServerLog(serverLogMessage)
end

function handleCommand(client, input)
  local splittedInput = split(input, " ")
  local slashCmd = table.remove(splittedInput, 1)
  local cmd = utf8.sub(slashCmd, 2, utf8.len(slashCmd))

  local args = ""
  for _, arg in ipairs(splittedInput) do
    args = string.format("%s %s", args, arg)
  end
  args = utf8.sub(args, 2, utf8.len(args))

  executeCommandHandler(cmd, client, args)
end

-- listen for "say / teamsay" from player console
function onPlayerChat(message, messageType)
  if isDefaultOutput then
    defaultOutput(source, message, messageType)
  end
end

function listenForOutputChatBox(_, _, _, _, _, message, receiver, r, g, b)
  receiver = receiver or root
  local hexColor = ""

  if (r and g and b) then
    hexColor = RGBToHex(r, g, b)
  end

  output(receiver, string.format("%s%s", hexColor, message))
  return "skip"
end

function listenForShowChat(_, _, _, _, _, player, bool)
  show(player, bool)
  return "skip"
end

function listenForClearChatBox(_, _, _, _, _, player)
  clear(player)
  return "skip"
end

function onResourceStart()
  addDebugHook("preFunction", listenForOutputChatBox, {"outputChatBox"})
  addDebugHook("preFunction", listenForShowChat, {"showChat"})
  addDebugHook("preFunction", listenForClearChatBox, {"clearChatBox"})
end

function onResourceStop()
  removeDebugHook("preFunction", listenForOutputChatBox)
  removeDebugHook("preFunction", listenForShowChat)
  removeDebugHook("preFunction", listenForClearChatBox)
end

addEventHandler("onChat2SendMessage", resourceRoot, onChatSendMessage)
addEventHandler("onPlayerChat", root, onPlayerChat)
addEventHandler("onResourceStart", resourceRoot, onResourceStart)
addEventHandler("onResourceStop", resourceRoot, onResourceStop)
