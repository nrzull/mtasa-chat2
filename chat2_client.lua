local chatInstance
local chatInstanceLoading
local chatInstanceLoaded

local state = {
  show = false,
  activeKeyButton = nil
}

local keyButtons = {
  ["t"] = "say",
  ["y"] = "teamsay"
}

addEvent("onChat2Loaded")
addEvent("onChat2EnterButton")
addEvent("onChat2Output", true)
addEvent("onChat2Clear", true)
addEvent("onChat2Show", true)

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

  if not state.show then
    return
  end

  execute(string.format("addMessage(%s)", toJSON(message)))
end

function clear()
  execute("clear()")
end

function isChatVisible()
  return state.show
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

  execute(string.format("show(%s)", tostring(bool)))
  state.show = bool
end

function registerKeyButtons()
  for keyButton, definition in pairs(keyButtons) do
    bindKey(keyButton, "down", onChatInputButton, keyButton, definition)
  end
end

function execute(eval)
  executeBrowserJavascript(chatInstance, eval)
end

function onChatLoaded()
  chatInstanceLoaded = true
  focusBrowser(chatInstance)
end

function onChatInputButton(_, _, keyButton, definition)
  if not state.show then
    return
  end

  if state.activeKeyButton then
    return
  end

  execute(string.format("showInput(%s)", toJSON(definition)))
  focusBrowser(chatInstance)
  guiSetInputEnabled(true)
  state.activeKeyButton = keyButton
end

function onChatEnterButton(message)
  if not state.show then
    return
  end

  if not state.activeKeyButton then
    return
  end

  execute("hideInput()")
  guiSetInputEnabled(false)
  triggerServerEvent("onChat2SendMessage", resourceRoot, message, keyButtons[state.activeKeyButton])
  state.activeKeyButton = nil
end

function listenForOutputChatBox(_, _, _, _, _, message, r, g, b)
  local hexColor = ""

  if (r and g and b) then
    hexColor = RGBToHex(r, g, b)
  end

  output(string.format("%s%s", hexColor, message))
  return "skip"
end

function listenForShowChat(_, _, _, _, _, bool)
  show(bool)
  return "skip"
end

function listenForClearChatBox()
  clear()
  return "skip"
end

function onClientResourceStart()
  showChat(false)
  addDebugHook("preFunction", listenForShowChat, {"showChat"})
  addDebugHook("preFunction", listenForOutputChatBox, {"outputChatBox"})
  addDebugHook("preFunction", listenForClearChatBox, {"clearChatBox"})
  showChat(true)

  registerKeyButtons()
end

function onClientResourceStop()
  showChat(false)
  removeDebugHook("preFunction", listenForShowChat)
  removeDebugHook("preFunction", listenForOutputChatBox)
  removeDebugHook("preFunction", listenForClearChatBox)
  showChat(true)
end

addEventHandler("onChat2Loaded", resourceRoot, onChatLoaded)
addEventHandler("onChat2EnterButton", resourceRoot, onChatEnterButton)
addEventHandler("onChat2Output", localPlayer, output)
addEventHandler("onChat2Clear", localPlayer, clear)
addEventHandler("onChat2Show", localPlayer, show)
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop)
