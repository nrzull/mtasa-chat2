## Description

This chat uses CEF and it tries to simulate behavior of default chat

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
<!-- set this resource before all other resources -->
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

The resource intercepts `outputChatBox`, `clearChatBox` and `showChat` function calls and redirect their calls to internal `output`, `clear`, `show` so you can still use default MTA functions as before and all of your resources should probably work correct.

**WARNING!** THIS FUNCTIONS DO NOT RETURN ANY VALUES NO MORE AS BEFORE. IF YOU RELY ON RETURN VALUES, THEN YOU SHOULD REWRITE YOUR CODE OR DO NOT USE THIS RESOURCE AT ALL!

After reviewing of all default mta resources code for just to be sure that there is no code that rely on return values, I made decision to change behavior of these functions. Also this decision was made when I realize that this resource is useless without easy integration in existing ecosystem. Noone will rewrite their codebase for just replacing one chat with another. And after all, some closed resources may use default chat API and you probably will not be able to change that. Sorry for this dirty hack. I apologize for it.

### Clientside

#### Functions

- `outputChatBox(string message, int red?, int green?, int blue?) -> void`
  Note that there is no last parameter `colorcoded`. Hex processing is enabled by default
- `showChat(bool show) -> void`
- `clearChatBox() -> void`
- `exports.chat2:isChatVisible() -> bool`

### Serverside

#### Functions

- `outputChatBox(string message, element elem?, int red?, int green?, int blue?) -> void`
  Note that there is no last parameter `colorcoded`. Hex processing is enabled by default
- `showChat(element elem, bool show) -> void`
- `clearChatBox(element elem) -> void`
- `exports.chat2:useDefaultOutput(bool) -> void`
  Enable/disable default output. If you disable it, then you need to write your own custom handlers for `onPlayerChat` event

### Examples:

```lua
addEventHandler("onResourceStart", resourceRoot, function()
  exports.chat2:useDefaultOutput(true) -- need to be executed if your gamemode doesn't output any messages to chat in onPlayerChat event handlers. As an example: play gamemode already uses its own output so you don't need to enable default output, but race gamemode doesn't have it, so you need to enable it.
end)

addEventHandler("onPlayerJoin", root, function()
  outputChatBox("#ccff00hellow #ffcc00world", source)
  outputChatBox("i'm red af", source, 255, 0, 0)
end)

-- listen for direct output from chat
-- should be created if useDefaultOutput wasn't set to 'true'
addEventHandler("onPlayerChat", root, function(message, messageType)
  if message ~= "ping" then
    outputChatBox("pong", source)
  end
end)
```
