_G.cookie = ""
local socket = require('socket.http')
local json = require("json")
local ltn12 = require('ltn12')
local md5 = require("md5")

local host = "http://app.pou.me/"
local versionCode = 254
local versionVersion = 4

local function urlencode(str)
   str = string.gsub (str, "([^0-9a-zA-Z !'()*._~-])", -- locale independent
      function (c) return string.format ("%%%02X", string.byte(c)) end)
   str = string.gsub (str, " ", "+")
   return str
end

local function req(u,m,h)
  local t = {}
  local status, code, headers = socket.request{
    url = u,
    headers = h,
    method = m,
    sink = ltn12.sink.table(t)
  }
  return table.concat(t), headers, code
end

function get(path,_json)
  if _json == true then
    return json.decode(req(host..path.."&_a=1&_c=1&_v=4&_r="..versionCode,"GET",{Cookie = tostring(_G.cookie)}))
  else
    return req(host..path.."&_a=1&_c=1&_v=4&_r="..versionCode,"GET",{Cookie = tostring(_G.cookie)})
  end
end
function post(path,_json)
  if _json == true then
    return json.decode(req(host..path.."&_a=1&_c=1&_v=4&_r="..versionCode,"POST",{Cookie = tostring(_G.cookie)}))
  else
    return req(host..path.."&_a=1&_c=1&_v=4&_r="..versionCode,"POST",{Cookie = tostring(_G.cookie)})
  end
end

--Module
local pou = {}

pou.versionCode = versionCode
pou.versionVersion = 4

pou.isRegistered = function(email)
  local res = post("/ajax/site/check_email?e="..urlencode(email),false)
  --if res.registered then return res.registered else error("An error occurred") end
return res
end

pou.resetPassword = function(email)
  local r,h,c = post("/ajax/site/reset_password?e="..urlencode(email),false) return r
end

pou.login = function(email, pass)
  local client = {}
  
  local r,h,c = post("/ajax/site/login?e="..urlencode(email).."&p="..md5.sumhexa(pass),false)
  --r = string.gsub(r,"\\","")
  if not h then return "no-connection" end
  client.me = r
  local _success_,___r = pcall(function() return json.decode(r) end)
  if success then r = ___r end
  if r.error then error("Couldn't Login: "..r.error.message) end
  _G.cookie = h["set-cookie"]

  client.logOut = function()
    local r,h,c = post("/ajax/account/logout?testi=",j)
    if h then
      _G.cookie = h["set-cookie"]
      return true
    end
  end

  client.topLikes = function(j) --true for table, false for json string
    local a,b,c = get("/ajax/site/top_likes?testi=",j) return a
  end
  
  client.getUserByNickname = function(nick,j)
    local r,h,c = post("/ajax/search/visit_user_by_nickname?n="..urlencode(nick),j) return r
  end
  
  client.getUserByEmail = function(email,j)
    local r,h,c = post("/ajax/search/visit_user_by_email?e="..urlencode(email),j) return r
  end
  
  client.getUserById = function(id,j)
    local r,h,c = post("/ajax/user/visit?id="..id,j) return r
  end

  client.getAvatarByNickname = function(n,j)
    local r,h,c = get("/ajax/search/friend_by_nickname?n="..n,j) return r
  end

  client.getAvatarByEmail = function(e,j)
    local r,h,c = get("/ajax/search/friend_by_email?e="..urlencode(e),j) return r
  end
  
  client.randomAvatar = function(j)
    local r,h,c = get("/ajax/search/random_friend?foo=",j) return r
  end

  client.randomUser = function(j)
    local r,h,c = post("/ajax/search/visit_random_user?foo=",j) return r
  end

  client.getFavorites = function(id,j)
    local r,h,c = get("/ajax/user/favorites?id="..id,j) return r
  end

  client.getLikers = function(id,s,j)
    local r,h,c = get("/ajax/user/likers?id="..id.."&s="..s,j) return r
  end

  client.getVisitors = function(id,s,j)
    local r,h,c = get("/ajax/user/visitors?id="..id.."&s="..s,j) return r
  end

  client.getMessages = function(id,s,j)
    local r,h,c = get("/ajax/user/messages?id="..id.."&s="..s,j) return r
  end
  
  client.sendMessage = function(uID,mID,j)
    local r,h,c = post("/ajax/user/send_message?id="..uID.."&tI="..mID,j) return r
  end
  
  client.like = function(id,j)
    local r,h,c = post("ajax/user/like?id="..id,j) return r
  end
  
  client.unLike = function(id,j)
    local r,h,c = post("ajax/user/unlike?id="..id,j) return r
  end
  
  client.topScores = function(game,day,j)
    local r,h,c = get("ajax/site/top_scores?g="..game.."&d="..day,j) return r
  end
  
  client.getGameSessions = function(pID,gID,j) --player id --8 tictac 9 four --idk
    local r,h,c = get("ajax/user/game_sessions?id="..pID.."&g="..gID.."&p=1&pP=100",j) return r
  end
  
  client.getSession = function(gID,j)
    local r,h,c = get("ajax/game/session/info?id="..gID.."&v=1",j) return r
  end
  
  client.changePassword = function(old,new,j)
    local r,h,c = post("/ajax/account/change_password?o="..md5.sumhexa(old).."&n="..md5.sumhexa(new),j) return r
  end
  
  client.changeNickname = function(nickname,j)
    local r,h,c = post("/ajax/account/change_nickname?n="..urlencode(nickname),j) return r
  end
  
  client.changeEmail = function(newemail,j)
    local r,h,c = post("/ajax/account/change_email?e="..urlencode(newemail),j) return r
  end
    --[[client.delete = function(j)
    local r,h,c = post("/ajax/account/delete_account,j) return r
  end]]

  return client
end
return pou
