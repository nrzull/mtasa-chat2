## Description

The chat uses CEF and it tries to simulate behavior of default chat

## Pros

- Emojis (😈)
- Adaptiveness (you don't need to put-on glasses for your 1920x1080 screen to see what others write)
- Copy/paste from/to input (no more console -> say someLongMessageOrUrl)
- Customizable (now you can unify a chat for all of your players)
- Extendable (for example you can make url links in chat clickable or add markdown support)

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

### Examples

```lua
addEventHandler("onResourceStart", resourceRoot, function()
  -- need to be executed if your gamemode doesn't output any messages to chat in
  -- onPlayerChat event handlers. As an example: play gamemode already uses its own output
  -- so you don't need to enable default output, but race gamemode doesn't have it,
  -- so you need to enable default output.
  exports.chat2:useDefaultOutput(true)
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

### FAQ

- #### I started this resource but I don't see the chat

  You should execute `exports.chat2:useDefaultOutput(true)` because your gamemode doesn't have built-in output

- #### The chat shows the same messages twice

  Execute `exports.chat2:useDefaultOutput(false)` somewhere in your code

- #### How can I add new input types for, let's say, global/local/private chats?

  You need to add new entries in clientside [inputKeyButtons](https://github.com/nrzull/mtasa-chat2/blob/master/chat2_client.lua#L11) table with unique `messageType` values and then process this messageTypes in `onPlayerChat` event handlers
