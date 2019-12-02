# Online TicTacToe Server

This is lua runtime for nakama game server.

We need to export the lua modules to let nakama server run the specific match handler API.

First, we need to set the nakama module to use the nakama features and table M to export the module by returning M.

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

If nakama matchmaker matched, it would create the match room with matchID and setupState (ex:room rule).

And players can join the match by matchID.

```
local function CreateMatchID( context , match_user ) 
  
-- Function
-----------------------------------------------------------------------
--[[
  match_user data cotains the match info.
  setupState table uses for create the match.
]]

  local setupState={
    invited = match_user
  }


-----------------------------------------------------------------------
--[[

  The matchmaker matched hook must return a match ID or nil.

  if the match should proceed as relayed multiplayer.

  For Lua it should be the module name.
   In this example it'd be a file named pingpong.lua, so the match module is pingpong.
]]

---------------- My runtime module is MatchRun

  local module = "MatchRun"
  local matchID;

---------------- Create the match with module and setupState.

  matchID = nakama.match_create(module,setupState)

  return matchID;
end


---------------- This RPC is for creating the match.


nakama.register_matchmaker_matched(CreateMatchID)

```



Then , use the nakama match handler API to ensure the online game smoothly.

Nakama match handler API:

M.match_init( context , setupState )

```

function M.match_init( context , setupState )


    --[[
        When you succeed to create the match. Then you will initiate the match. 


        You must return three values.
        (table) - The initial in-memory state of the match. May be any non-nil Lua term, or nil to end the match. This variable comes from setupState of match_create .
        (number) - Tick rate representing the desired number of match_loop() calls per second. Must be between 1 and 30, inclusive.
        (string) - A string label that can be used to filter matches in listing operations. Must be between 0 and 2048 bytes long. This is used in match listing to filter matches.
    ]]


    local gamestate = setupState
    local tickrate = 2
    local label = "TicTacToe"

    return gamestate, tickrate, label

end

```


M.match_init( context , setupState )

```

function M.match_init( context , setupState )


    --[[
        When you succeed to create the match. Then you will initiate the match. 


        You must return three values.
        (table) - The initial in-memory state of the match. May be any non-nil Lua term, or nil to end the match. This variable comes from setupState of match_create .
        (number) - Tick rate representing the desired number of match_loop() calls per second. Must be between 1 and 30, inclusive.
        (string) - A string label that can be used to filter matches in listing operations. Must be between 0 and 2048 bytes long. This is used in match listing to filter matches.
    ]]


    local gamestate = setupState
    local tickrate = 2
    local label = "TicTacToe"

    return gamestate, tickrate, label

end

```


M.match_join_attempt( context , dispatcher, tick, state, presence, metadata)

```
function M.match_join_attempt( context , dispatcher, tick, state, presence, metadata )
--[[

    After initiating , check the user join attempt.

    We need to return 2 values , 1 is optional.
    (table) - An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
    (boolean) - True if the join attempt should be allowed, false otherwise.
    (string) *optionally - If the join attempt should be rejected, an optional string rejection reason can be returned to the client.
]]


--[[
 Presence format(     Presence data format    ):
  {
    user_id = "user unique ID",
    session_id = "session ID of the user's current connection",
    username = "user's unique username",
    node = "name of the Nakama node the user is connected to"
  }
]]


    return state , true

end

```

M.match_join( context, dispatcher, tick, state, presences )

```
function M.match_join(context, dispatcher, tick, state, presences)
  print(presences)
    --[[
        Join the room.

        We need to return 1 value.
        (table) - An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
    ]]    
  return state

end

```
  
M.match_leave(context, dispatcher, tick, state, presences)

```
function M.match_leave(context, dispatcher, tick, state, presences)

  --[[
      When match_loop return nil. 
      Runtime Code will enter this .
    
      We need to return 1 value.
      (table) - An (optionally) updated state. May be any non-nil Lua term or nil to end the match.
  ]]  


  return state
end
```

M.match_loop(context, dispatcher, tick, state, messages)

```
function M.match_loop(context, dispatcher, tick, state, messages)

    --[[
        This is the server runtime during the match.
        return nil  ===========> You will go to the match_leave function. 
   ]] 


    for _,msg in ipairs(messages) do
      dispatch.dispatchGameMessage(dispatcher,op_code,msg.data,nil,nil)
    end



    return state

end
```


