addEvent("onChat2SendMessage", true)

function clear(player)
  triggerClientEvent(player, "onChat2Clear", player)
end

function show(player, bool)
  triggerClientEvent(player, "onChat2Show", player, bool)
end

function onChatSendMessage(message)
  local sender = client
  local nickname = getPlayerName(sender)

  if string.len(message) == 0 then
    return
  end

  if string.sub(message, 0, 1) == "/" then
    handleCommand(sender, message)
    return
  end

  for _, player in ipairs(getElementsByType("player")) do
    local text = string.format("%s#ffffff: %s", nickname, message)
    triggerClientEvent(player, "onChat2ReceiveMessage", player, text)
  end
end

function handleCommand(client, input)
  local splittedInput = split(input, " ")
  local cmd = string.sub(splittedInput[1], 2, string.len(splittedInput[1]))
  local args = {}

  for i, arg in ipairs(splittedInput) do
    if (i ~= 1) then
      args[i - 1] = arg
    end
  end

  for i, part in ipairs(splittedInput) do
    if i == 1 then
      cmd = string.sub(part, i + 1, string.len(part))
    end
  end

  executeCommandHandler(cmd, client, unpack(args))
end

addEventHandler("onChat2SendMessage", resourceRoot, onChatSendMessage)
