addEvent("onChat2SendMessage", true)
addEvent("onPlayerChat2")

local isDefaultOutput = true
local minLength = 1
local maxLength = 96

local rootPlayers = createElement("rootPlayers")
setElementParent(rootPlayers, root)

function registerPlayer(p)
  setElementParent(p or source, rootPlayers)
end

for _, p in ipairs(getElementsByType("player")) do
  registerPlayer(p)
end

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

function useDefaultOutput(bool)
  isDefaultOutput = bool
end

function onChatSendMessage(message)
  if type(message) ~= "string" or utf8.len(message) < minLength or utf8.len(message) > maxLength then
    return
  end

  if utf8.sub(message, 0, 1) == "/" then
    handleCommand(client, message)
    return
  end

  if not isDefaultOutput then
    triggerEvent("onPlayerChat2", rootPlayers, client, message)
    return
  end

  defaultOutput(client, message)
end

function defaultOutput(sender, message)
  local nickname = getPlayerName(sender)
  local text = string.format("%s#ffffff: %s", nickname, message)

  for _, player in ipairs(getElementsByType("player")) do
    output(player, text)
  end

  outputServerLog(text)
end

function handleCommand(client, input)
  local splittedInput = split(input, " ")
  local slashCmd = table.remove(splittedInput, 1)
  local cmd = utf8.sub(slashCmd, 2, utf8.len(slashCmd))
  executeCommandHandler(cmd, client, unpack(splittedInput))
end

function onPlayerJoin()
  registerPlayer(source)
end

function onPlayerChat(message)
  defaultOutput(source, message)
end

addEventHandler("onChat2SendMessage", resourceRoot, onChatSendMessage)
addEventHandler("onPlayerJoin", root, onPlayerJoin)
addEventHandler("onPlayerChat", root, onPlayerChat)
