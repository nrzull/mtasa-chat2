addEvent("onChat2SendMessage", true)
addEvent("onPlayerChat2")

local isDefaultOutput = true
local minLength = 1
local maxLength = 96

--Reduce event calls for onPlayerChat
local rootPlayers = createElement("rootPlayers"))
setElementParent(rootPlayers, root)
local function registerPlayer(p) setElementParent(p or source, rootPlayers) end
for _, p in ipairs(getElementsByType("player")) do registerPlayer(p) end
addEventHandler("onPlayerJoin", root, function() registerPlayer() end)

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

  local sender = client

  if utf8.sub(message, 0, 1) == "/" then
    handleCommand(sender, message)
    return
  end

  if not isDefaultOutput then
    triggerEvent("onPlayerChat2", rootPlayers, sender, message)
    return
  end

  local nickname = getPlayerName(sender)

  for _, player in ipairs(getElementsByType("player")) do
    local text = string.format("%s#ffffff: %s", nickname, message)
  end
  output(player, text)
  outputServerLog(text)
end

function handleCommand(client, input)
  local splittedInput = split(input, " ")
  local slashCmd = table.remove(splittedInput, 1)
  local cmd = utf8.sub(slashCmd, 2, utf8.len(slashCmd))
  executeCommandHandler(cmd, client, unpack(splittedInput))
end

addEventHandler("onChat2SendMessage", resourceRoot, onChatSendMessage)
