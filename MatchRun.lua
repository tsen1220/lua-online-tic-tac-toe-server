local nakama = require("nakama")
local dispatch = require("Dispatcher")

-------------------------------------------------------------------
local  M = {}

function M.match_init(context, setupState)
    --[[
        When you succeed to create the match. Then you will initiate the match. 


        You must return three values.
        (table) - The initial in-memory state of the match. May be any non-nil Lua term, or nil to end the match. This variable comes from setupState of match_create. Contains match and user's info.
        (number) - Tick rate representing the desired number of match_loop() calls per second. Must be between 1 and 30, inclusive.
        (string) - A string label that can be used to filter matches in listing operations. Must be between 0 and 2048 bytes long. This is used in match listing to filter matches.
    ]]

  local TurnControl = 2
  local gamestate = {setupState.invited[1].presence, setupState.invited[2].presence, TurnControl}
  local tickrate = 2
  local label = "TicTacToe"

  return gamestate, tickrate, label
end

function M.match_join_attempt(context, dispatcher, tick, state, presence, metadata)
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

  return state, true
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

  When someone leave the match, execute this.

      We need to return 1 value.
      (table) - An (optionally) updated state. May be any non-nil Lua term or nil to end the match.
  ]]  

  return state
end

function M.match_loop(context, dispatcher, tick, state, messages)
    --[[
        This is the server runtime during the match.
        return nil  ===========> stop the match loop.
  ]] 

  --when receiving messages
  for _,msg in ipairs(messages) do
      
    if (msg.op_code == 1 or msg.op_code == 2) then 
  
      dispatch.dispatchGameMessage(dispatcher, 3, msg.data, {state[state[3]]}, nil)
    
      nakama.logger_info(nakama.json_encode(state))

      state[3] = state[3]+1
      if(state[3] == 3) then
        state[3] = 1
      end
    end

    if(msg.op_code == 4) then
      local gameControl ={
        ["control"] = false;
      }
      
      local encode_data = nakama.json_encode(gameControl)
      dispatch.dispatchGameMessage(dispatcher, 5, encode_data, {state[1]}, nil)
    end

    if(msg.op_code == 8) then 
      dispatch.dispatchGameMessage(dispatcher, 10, "O Win", nil, nil)
    end

    if(msg.op_code == 9) then 
      dispatch.dispatchGameMessage(dispatcher, 10, "X Win", nil, nil)
    end
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
