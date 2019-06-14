local chatInstance
local chatInstanceLoading
local chatInstanceLoaded

-- addEvent("__onChatShow", true)
addEvent("__onChatLoaded")
addEvent("__onChatInput")
addEvent("__onChatSendMessage")
addEvent("__onChatReceiveMessage", true)

function show(bool)
  if chatInstanceLoaded ~= true then
    if chatInstanceLoading ~= true then
      create()
      setTimer(show, 300, 1, bool)
    else
      setTimer(show, 300, 1, bool)
    end
  end

  local eval = "show(" .. tostring(bool) .. ");"
  executeBrowserJavascript(chatInstance, eval)
end

function create()
  chatInstance = guiGetBrowser(guiCreateBrowser(0, 0, 1, 1, true, true, true))
  chatInstanceLoading = true
  addEventHandler("onClientBrowserCreated", chatInstance, load)
end

function load()
  loadBrowserURL(chatInstance, "http://mta/local/index.html")
  -- setDevelopmentMode(true, true)
  -- toggleBrowserDevTools(chatInstance, true)
end

function onResourceStart()
  showChat(false)
  show(true)
end

function onChatLoaded()
  chatInstanceLoaded = true
  focusBrowser(chatInstance)
end

function onChatInput(isActive)
  if isActive == "true" then
    toggleAllControls(false)
  else
    toggleAllControls(true)
  end
end

function onChatSendMessage(message)
  triggerServerEvent("__onChatSendMessage", resourceRoot, message)
end

function onChatReceiveMessage(nickname, message)
  local eval = "addMessage(" .. toJSON({nickname = nickname, text = message}) .. ")"
  executeBrowserJavascript(chatInstance, eval)
end

-- addEventHandler("__onChatShow", resourceRoot, show)
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)
addEventHandler("__onChatLoaded", resourceRoot, onChatLoaded)
addEventHandler("__onChatInput", resourceRoot, onChatInput)
addEventHandler("__onChatSendMessage", resourceRoot, onChatSendMessage)
addEventHandler("__onChatReceiveMessage", localPlayer, onChatReceiveMessage)
