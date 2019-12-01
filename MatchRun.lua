local nakama = require("nakama")
local dispatch = require("Dispatcher")

print("Nakama Run")

-------------------------------------------------------------------
local  M = {}


function M.match_init( context , setupState )
    --[[
        When you succeed to create the match. Then you will initiate the match. 


        You must return three values.
        (table) - The initial in-memory state of the match. May be any non-nil Lua term, or nil to end the match. This variable comes from setupState of match_create 
        (number) - Tick rate representing the desired number of match_loop() calls per second. Must be between 1 and 30, inclusive.
        (string) - A string label that can be used to filter matches in listing operations. Must be between 0 and 2048 bytes long. This is used in match listing to filter matches.
    ]]
    local gamestate = setupState
    local tickrate = 2
    local label = "TicTacToe"

    return gamestate, tickrate, label

end

function M.match_join_attempt( context , dispatcher, tick, state, presence, metadata )
--[[

    After initiating , check the user join attempt.

    We need to return 2 values , 1 is optional.
    (table) - An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
    (boolean) - True if the join attempt should be allowed, false otherwise.
    (string) *optionally - If the join attempt should be rejected, an optional string rejection reason can be returned to the client.
]]


--[[
 Presence format(     Presence 資料組成     ):
  {
    user_id = "user unique ID",
    session_id = "session ID of the user's current connection",
    username = "user's unique username",
    node = "name of the Nakama node the user is connected to"
  }
]]


    return state , true

end

function M.match_join(context, dispatcher, tick, state, presences)

    --[[
        Join the room.

        We need to return 1 value.
        (table) - An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
    ]]    
  return state

end

function M.match_leave(context, dispatcher, tick, state, presences)

  --[[
      When match_loop return nil. 
      Runtime Code will enter this .
    
      We need to return 1 value.
      (table) - An (optionally) updated state. May be any non-nil Lua term or nil to end the match.
  ]]  

  print("Leave the match!")
  return state
end

function M.match_loop(context, dispatcher, tick, state, messages)

    --[[
        return nil  ===========> You will go to match leave. 
   ]] 


    for _,msg in ipairs(messages) do
      dispatch.dispatchGameMessage(dispatcher,3,msg.data,nil,nil)
    end



    return state

end

function M.match_terminate(context, dispatcher, tick, state, grace_seconds)
    --[[
        You must return:
        (table) - An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
    ]]
  return state
end

return M