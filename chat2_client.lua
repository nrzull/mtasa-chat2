local chatInstance
local chatInstanceLoading
local chatInstanceLoaded

addEvent("onChat2Loaded")
addEvent("onChat2Input")
addEvent("onChat2SendMessage")
addEvent("onChat2Output", true)
addEvent("onChat2Clear", true)
addEvent("onChat2Show", true)

function execute(eval)
  executeBrowserJavascript(chatInstance, eval)
end

function create()
  chatInstance = guiGetBrowser(guiCreateBrowser(0.01, 0.01, 0.25, 0.4, true, true, true))
  chatInstanceLoading = true
  addEventHandler("onClientBrowserCreated", chatInstance, load)
end

function load()
  loadBrowserURL(chatInstance, "http://mta/local/index.html")
end

function output(message)
  if not chatInstanceLoaded then
    return setTimer(output, 250, 1, message)
  end

  local eval = string.format("addMessage(%s)", toJSON(message))
  execute(eval)
end

function clear()
  local eval = "clear()"
  execute(eval)
end

function show(bool)
  if chatInstanceLoaded ~= true then
    if chatInstanceLoading ~= true then
      create()
      return setTimer(show, 300, 1, bool)
    else
      return setTimer(show, 300, 1, bool)
    end
  end

  local eval = "show(" .. tostring(bool) .. ");"
  execute(eval)
  setElementData(localPlayer, "chat2IsVisible", bool)
end

function isVisible()
  return getElementData(localPlayer, "chat2IsVisible", false)
end

function onResourceStart()
  showChat(false)
  show(true)
end

function onResourceStop()
  show(false)
  showChat(true)
end

function onChatLoaded()
  chatInstanceLoaded = true
  focusBrowser(chatInstance)
end

function onChatInput(isActive)
  if isActive == "1" then
    guiSetInputEnabled(true)
  else
    guiSetInputEnabled(false)
  end
end

function onChatSendMessage(message, messageType)
  triggerServerEvent("onChat2SendMessage", resourceRoot, message, messageType)
end

function listenForOutputChatBox(_, _, _, _, _, message, r, g, b)
  local hexColor = ""

  if (r and g and b) then
    hexColor = RGBToHex(r, g, b)
  end

  output(string.format("%s%s", hexColor, message))
end

function listenForShowChat(_, _, _, _, _, bool)
  show(bool)
  return "skip"
end

function onClientResourceStart()
  addDebugHook("postFunction", listenForOutputChatBox, {"outputChatBox"})
  addDebugHook("preFunction", listenForShowChat, {"showChat"})
end

function onClientResourceStop()
  removeDebugHook("postFunction", listenForOutputChatBox)
  removeDebugHook("preFunction", listenForShowChat)
end

addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)
addEventHandler("onClientResourceStop", resourceRoot, onResourceStop)
addEventHandler("onChat2Loaded", resourceRoot, onChatLoaded)
addEventHandler("onChat2Input", resourceRoot, onChatInput)
addEventHandler("onChat2SendMessage", resourceRoot, onChatSendMessage)
addEventHandler("onChat2Output", localPlayer, output)
addEventHandler("onChat2Clear", localPlayer, clear)
addEventHandler("onChat2Show", localPlayer, show)
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop)
