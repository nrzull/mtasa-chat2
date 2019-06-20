addEvent("onChat2Message", true)

local isDefaultOutput = false
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

function useDefaultOutput(bool)
  isDefaultOutput = bool
end

function defaultOutput(message, messageType)
  if not isDefaultOutput then
    return
  end

  if messageType ~= 0 and messageType ~= 2 then
    return
  end

  local sender = source
  local nickname = getPlayerName(sender)
  local nicknameColor = ""
  local r, g, b = getPlayerNametagColor(sender)

  if (r and g and b) then
    nicknameColor = RGBToHex(r, g, b)
    nickname = string.format("%s%s", nicknameColor, nickname)
  end

  local team = getPlayerTeam(sender)
  local text = string.format("%s: #ffffff%s", nickname, message)
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

function onChatMessage(message, messageType)
  if type(message) ~= "string" or utf8.len(message) < minLength or utf8.len(message) > maxLength then
    return
  end

  if type(messageType) ~= "number" then
    return
  end

  if utf8.sub(message, 0, 1) == "/" then
    return handleCommand(client, message)
  end

  triggerEvent("onPlayerChat", client, message, messageType)
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

addEventHandler("onPlayerChat", root, defaultOutput)
addEventHandler("onChat2Message", resourceRoot, onChatMessage)
addEventHandler("onResourceStart", resourceRoot, onResourceStart)
addEventHandler("onResourceStop", resourceRoot, onResourceStop)
