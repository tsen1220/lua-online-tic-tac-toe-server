# Online TicTacToe Server

This is lua runtime for nakama game server.

These lua file is in the nakama folder  ./data/modules.

TicTacToe Unity Client : https://github.com/tsen1220/UnityOnlineTicTacToeClient

We need to export the lua modules to let nakama server run the specific match handler API.

## Start Database
We need to start the cockroachDB. This is my start setting.

```
cockroach start --insecure --store=path="./cdb-store1/" --listen-addr=localhost --background
```


## Nakama Match API

We need to set the nakama module to use the nakama features and table M to export the module by returning M.

### Lua Modules
```

local nakama = require("nakama")

local M ={}

...
...
...
...
...
...
...
...
...

---- return M to export.

return M

```

### Match_Create

If nakama matchmaker matched, it would create the match room with matchID and setupState (ex:room rule, room presences...).

And players can join the match by matchID.

```
local function CreateMatchID(context, match_user) 
  
--[[
  match_user data cotains the match info.
  setupState table uses for create the match.
]]

  local setupState={
    invited = match_user
  }


--[[

  The matchmaker matched hook must return a match ID or nil.

  if the match should proceed as relayed multiplayer.

  For Lua it should be the module name.
   In this example it'd be a file named MatchRun.lua, so the match module is MatchRun.
]]

---------------- My runtime module is MatchRun

  local module = "MatchRun"
  local matchID;

---------------- Create the match with module and setupState.

  matchID = nakama.match_create(module, setupState)

  return matchID;
end


---------------- This RPC is for creating the match.


nakama.register_matchmaker_matched(CreateMatchID)


```

## Match Handler API

Then , use the nakama match handler API to ensure the online game smoothly.

We need to use Nakama match handler API.

### Match_Init

M.match_init(context, setupState)

```

function M.match_init(context, setupState)

    --[[
        When you succeed to create the match. Then you will initiate the match. 


        You must return three values.
        
        (table) - The initial in-memory state of the match. May be any non-nil Lua term, or nil to end the match. This variable comes from setupState of match_create. You can customize.
        
        (number) - Tick rate representing the desired number of match_loop() calls per second. Must be between 1 and 30, inclusive.
        
        (string) - A string label that can be used to filter matches in listing operations. Must be between 0 and 2048 bytes long. This is used in match listing to filter matches.
    ]]


    local gamestate = setupState      or      { setupState, setupState.invited[1].presence, setupState.invited[2].presence }
    local tickrate = 2
    local label = "TicTacToe"

    return gamestate, tickrate, label

end

```

### Match_Join_Attempt

M.match_join_attempt(context, dispatcher, tick, state, presence, metadata)

```
function M.match_join_attempt(context, dispatcher, tick, state, presence, metadata)

      --[[
          After initiating , check the user join attempt.

          We need to return 2 values , 1 is optional.
          
          (table) - An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
          
          (boolean) - True if the join attempt should be allowed, false otherwise.
          
          (string) *optionally - If the join attempt should be rejected, an optional string rejection reason can be returned to the client.
      ]]

      --[[ 
          which comes from nakama server

          Presence format(     Presence data format    ):
          {
            user_id = "user unique ID",
            session_id = "session ID of the user's current connection",
            username = "user's unique username",
            node = "name of the Nakama node the user is connected to"
          }
         ]]

    local acceptUser = true

    return state , acceptUser

end

```

### Match_Join

M.match_join(context, dispatcher, tick, state, presences)

```
function M.match_join(context, dispatcher, tick, state, presences)

    --[[
        Join the room.

        We need to return 1 value.
        (table) - An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
    ]]    


  return state

end

```

### Match_Loop

M.match_loop(context, dispatcher, tick, state, messages)

```
function M.match_loop(context, dispatcher, tick, state, messages)

    --[[
        This is the server runtime during the match.
        Messages is the data which comes from the client.
        return nil  ===========> stop the match loop.
   ]] 

   for _,msg in ipairs(messages) do 
      .....
      .....
      .....

    --[[
      This section want to send data to the client. To keep match working.
    ]]
      dispatcher.broadcast_message(op_code, data, presences, sender)

   end


    return state

end
```

### Match_Leave

M.match_leave(context, dispatcher, tick, state, presences)

```
function M.match_leave(context, dispatcher, tick, state, presences)

  --[[
    When someone leave the match, exit match_loop function and execute match_leave.
    
      We need to return 1 value.
      (table) - An (optionally) updated state. May be any non-nil Lua term or nil to end the match.
  ]]  


  return state
end
```


### Match Runtime API

The Nakama match handler API contains dispatcher which is match runtime API to send the messages to client .

Recommend that use this in function match_loop.

We need to use it to complete the online game.


```
dispatcher.broadcast_message(op_code, data, presences, sender):

1. op_code is number.
2. data is json_encode data.
3. presences is table which contains presence(s) data.  ex: {presences[1],presences[2]} or {presences[1]}
4. sender is table which contains presence(s) data.


For example, function is in match_loop ===========> dispatcher.broadcast_message(1, Nakama.json_encode(data), { state.presences[1] }, { state.presences[2] })

        Presence format:
        presence  {
            user_id = "user unique ID",
            session_id = "session ID of the user's current connection",
            username = "user's unique username",
            node = "name of the Nakama node the user is connected to"
          }


    |Param    |	Type	|                                                   Description                                                  |
    |---------|---------|----------------------------------------------------------------------------------------------------------------|
    |op_code  |	number	|Numeric message op code.                                                                                        |
    |data     |	string	|Data payload string, or nil.                                                                                    |
    |presences|	table	|List of presences (a subset of match participants) to use as message targets, or nil to send to the whole match.|
    |sender   |	table	|A presence to tag on the message as the 'sender', or nil.                                                       |
```
