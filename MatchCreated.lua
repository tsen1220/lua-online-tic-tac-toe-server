local nakama = require("nakama")

local function CreateMatchID(context, match_user) 
  
-- Function
-----------------------------------------------------------------------
--[[
  配對完成後,傳進來的 Query 中的房間設定
]]

  local setupState={
    invited = match_user
  }

-----------------------------------------------------------------------
--[[

  The matchmaker matched hook must return a match ID or nil.
  這個hook需要回傳MatchID 或nil

  if the match should proceed as relayed multiplayer.

  For Lua it should be the module name.
   In this example it'd be a file named pingpong.lua, so the match module is pingpong.

  在這裡的module 為我要跑nakama Match Runtime Code的檔案．
]]

  local module = "MatchRun"
  local matchID;

  matchID = nakama.match_create(module, setupState)

  return matchID;
end

nakama.register_matchmaker_matched(CreateMatchID)
