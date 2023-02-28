_G.cookie = ""

local likeUpdateThread = love.thread.newThread([[
	local looped = true
	local function End(ms)
		love.thread.getChannel("likeupdate"):push("ended-"..ms)
		looped = false
	end
	local function split(add)
		local sec,hos = false,nil
		local _1 = string.find(add,":")
		if _1 then
			local _s1 = string.sub(add,0,_1-1) or "http"
			sec = (_s1=="https") and (443) or (80)
		end
		local __,_2 = string.find(add,"://")
		if _2 then
			local _3 = string.find(add,"/",_2+1) or #add+1
			local _s2 = string.sub(add,_2+1,_3-1) or "app.pou.me"
			hos = _s2
		end
		return sec,hos
	end
	
	local host,cookie,pname,mynam = ...
	local path = "/ajax/search/friend_by_nickname?n="..pname.."&_r=256&_a=1&_c=1&_v=4"
	if string.lower(pname)==string.lower(mynam) then
		path = "/ajax/account/info?_r=256&_a=1&_c=1&_v=4"
	end
	local socket = require("socket")
	local sec,hos = split(host)
	local tcp = socket.tcp()
	local address = socket.dns.toip(hos)
	if not pname then return End("no-name") end
	if not address then return End("no-address") end
	--if sec == 443 then return End("https-not-supported") end
	tcp:connect(address,sec)
	tcp:settimeout(5)
	local timer = -10
	while looped do
		local msgs = love.thread.getChannel("tolikeupdate"):pop()
		if msgs then
			if msgs == "close" then print("bye") tcp:close() End("ok") break end
		end
		if os.clock()-timer > 10 then
			tcp:send("GET "..path.." HTTP/1.1\nHost:"..hos.."\nUser-Agent:Pou-Searcher\nConnection:Keep-Alive\nCookie:"..cookie.."\n\n")
			local finres = ""
			local body = ""
			local function getchunk(heads)
				local resp
				while 1 do
					resp = tcp:receive()
					if resp then
						if tonumber(resp,16) then
							break
						end
						finres = finres..resp..((heads==true) and "\n" or "")
					else return
					end
				end
				local res = tcp:receive(tonumber(resp,16)) or ""
				if #res>0 then
					finres = finres..res
					body = body..res
					getchunk()
				end
			end
			getchunk(true)
			love.thread.getChannel("likeupdate"):push(body)
			timer=os.clock()
		end
		socket.sleep(0.1)
	end
]])

local socket = require('socket.http')
local json = require("json")
local ltn12 = require('ltn12')
local function md5encode(str)
	return love.data.encode("string","hex",love.data.hash("md5",str))
end

local host = "http://app.pou.me/"
local versionCode = 256
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
  return table.concat(t), headers, code, status
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

pou.changeHost = function(url)
	host = url
	local a,b = pcall(function() return get("/ajax/site/meta?amogus=111") end)
	if a == true then return b else return nil end
end

pou.startLive = function(name)
	live_stats.followsum = {0}
	live_stats.likesum = {0}
	likeUpdateThread:start(host,_G.cookie,name,myacc.name)
end

pou.login = function(email, pass)
print(email,pass)
  local client = {}
  if (email) and (pass) then
    local r,h,c = post("/ajax/site/login?e="..urlencode(email).."&p="..md5encode(pass),false)
    --r = string.gsub(r,"\\","")
    if not h then return "no-connection" end
    client.me = r
    local _success_,___r = pcall(function() return json.decode(r) end)
    if success then r = ___r end
    if r.error then error("Couldn't Login: "..r.error.message) end
    _G.cookie = h["set-cookie"]
    client.type = "account"
  elseif (not email) and (not pass) then
    client.type = "guest"
  elseif (email) and (not pass) then
    _G.cookie = email
    client.type = "cookie"
  end

  client.logOut = function()
    local r,h,c = post("/ajax/account/logout?testi=",j)
    if h then
      _G.cookie = h["set-cookie"]
      client.type = "guest"
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
  
  client.getGameSessions = function(pID,gID,page,per,j) --player id --8 tictac 9 four --idk
    page = page or 1 per = per or 100
    local r,h,c = get("ajax/user/game_sessions?id="..pID.."&g="..gID.."&p="..page.."&pP="..per,j) return r
  end
  
  client.getSession = function(gID,j)
    local r,h,c = get("ajax/game/session/info?id="..gID.."&v=1",j) return r
  end
  
  client.changePassword = function(old,new,j)
    local r,h,c = post("/ajax/account/change_password?o="..md5encode(old).."&n="..md5encode(new),j) return r
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
