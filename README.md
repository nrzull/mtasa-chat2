## Description

This chat is using CEF and it tries to simulate behavior of default chat

## Pros

- Emojis (😈)
- Adaptiveness (you don't need to put-on glasses for your 1920x1080 screen to see what others write)
- Copy/paste from/to input (no more console -> say someLongMessageOrUrl)
- Customizable (now you can unify a chat for all of your players)

## Cons

- It can't execute built-in commands like `/nick`, `/login`, etc "due to security reasons." (c) mta wiki. You need to write your own custom handlers for this commands or just use console for such commands. Custom commands still work as expected.
- It can't be used until resource starts so you can't write useful messages to player in `onPlayerConnect` event handler. use `onPlayerJoin` instead

## Getting Started

- download [resource](https://github.com/nrzull/mtasa-chat2/releases/latest/download/chat2.zip)
- move this resource to `server/mods/deathmatch/resources/` directory
- add to `server/mods/deathmatch/mtaserver.conf`:

```xml
<resource src="chat2" startup="1" protected="0" />
```

- add to `server/mods/deathmatch/acl.xml`:

```xml
<group name="chat2ACLGroup">
  <acl name="chat2ACL"></acl>
  <object name="resource.chat2"></object>
</group>

<acl name="chat2ACL">
  <right name="function.executeCommandHandler" access="true"></right>
</acl>
```

## API

### Clientside

#### Functions

- **output(string message) -> void**
  Writes a message to chat. Hex colors processing is enabled by default and this behavior can't be configured by end-user.

- **clear() -> void**
  Clears all messages.

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
  handler params: (element player, string message, int messageType)
  Will be emitted only after useDefaultOutput(false)

### Examples:

```lua
addEventHandler("onPlayerJoin", root, function()
 exports.chat2:output(source, "#ccff00hello #ffcc00world")
 exports.chat2:useCustomEventHandlers(true) -- need to be executed if you want to disable default output handler and use your own output handlers
end)

-- listen for say/teamsay commands from console
-- may be created if useDefaultOutput was set to 'false'
addEventHandler("onPlayerChat", root, function(message, messageType)
  -- some logic
end)

-- listen for direct output from chat
-- may be created if useDefaultOutput was set to 'false'
addEventHandler("onPlayerChat2", root, function(sender, message, messageType)
 if message == "ping" then
   exports.chat2:output(sender, "pong")
 end
end)
```
