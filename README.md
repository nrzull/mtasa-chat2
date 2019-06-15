## Description

This chat is using CEF and it tries to become full replacement for default chat

## Pros

- Emojis (😈)
- Adaptiveness (you don't need to put-on glasses for your 1920x1080 screen to see what others write)
- Copy/paste from/to input (no more console -> say someLongMessageOrUrl)
- Customizable (now you can unify a chat for all of your players)

## Cons

- For execution of custom commands resource needs an access right for [ExecuteCommandHandler](https://wiki.multitheftauto.com/wiki/ExecuteCommandHandler) in ACL
- It can't execute built-in commands like `/nick`, `/login`, etc "due to security reasons." (c) mta wiki. You need to write your own custom handlers for this commands
- It can't be used until resource starts so you can't write useful messages to player in `onPlayerConnect` event handler

## API

### Clientside

#### Functions

- **output(string message) -> void**
  Writes a message to chat. Hex colors processing is enabled by default and this behavior can't be configured by end-user.

- **clear() -> void**
  Clears all messages. Chat doesn't have history.

- **isVisible() -> bool**
  Returns true/false if chat is visible.

- **show(bool b) -> void**
  Shows/hides a chat.

### Serverside

#### Functions

- **output(element player, string message) -> void**
- **clear(element player) -> void**
- **isVisible(element player) -> bool**
- **show(element player, bool b) -> void**

#### Events

- **onPlayerChat2**
  handler params: (element player, string message)
  Will be emitted only after useDefaultOutput(false)

### Examples:

```lua
addEventHandler("onPlayerJoin", root, function()
 exports.chat2:output(source, "#ccff00hello from default output #ffcc00chat")
 exports.chat2:useDefaultOutput(false) -- disable built-in handler and use own handlers that listen for "onPlayerChat2" event
end)

addEventHandler("onPlayerChat2", root, function(sender, message)
 for _, player in ipairs(getElementsByType("player")) do
    local text = string.format("%s wrote: %s", nickname, message)
    output(player, text)
  end
end)
```
