--[[
  _____               _____                     _     
 |  __ \             / ____|                   | |    
 | |__) |__  _   _  | (___   ___  __ _ _ __ ___| |__  
 |  ___/ _ \| | | |  \___ \ / _ \/ _` | '__/ __| '_ \ 
 | |  | (_) | |_| |  ____) |  __/ (_| | | | (__| | | |
 |_|   \___/ \__,_| |_____/ \___|\__,_|_|  \___|_| |_|
                                                      
Pou Search is an open source project in GitHub (https://github.com/H401217/pou-search).
TODO:
* support for pou 3d
* fast switch between public and private server (with separate saved data)
* a DELETE ALL DATA FROM APP option
]]

function love.run()
	love.graphics.origin() love.graphics.draw(love.graphics.newImage("assets/icons/splashscreen.png")) love.graphics.present()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.setBackgroundColor(0.3,0.6,1)
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end

_G.Pou = require("pou")
_G.json = require("json")
function sColor(p)
	if p <= 50 then
		love.graphics.setColor(1,p/50,0)
	else
		love.graphics.setColor(1-(p-50)/50,1,0)
	end
end

function love.load()
	--love.window.showMessageBox("Warning!","This version of Pou-Search is still in construction (fast commit).\r\nRemember to NEVER put any personal information in this program unless you really and surely know what you're doing.\r\nThe original program is only located in Github, however you still need to check the code before proceeding.\r\n\r\nThis work is not in any way related or associated with Zakeh or other Pou creators.","warning")
	versionName = "v0.81"
	
	width = love.graphics:getWidth()
	height = love.graphics:getHeight()
	
	poudrawtest = love.graphics.newCanvas(500,500)
	pouvisit = love.graphics.newCanvas(300,300)
	minipou = love.graphics.newCanvas(300,300)
	gridpou = {}
	for count = 1,10 do
		gridpou[count] = love.graphics.newCanvas(300,300)
	end
	statspou = love.graphics.newCanvas(300,300)
	tictactable = love.graphics.newCanvas(500,500)
	extra = require("extra")
	translate = require("translate")
	bannerTime = 1234567
	bannerType = "success"
	bannerMsg = ""
	
	logShad = love.graphics.newShader([[
	vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ) {
		vec4 c = Texel(tex,texture_coords);
		c.w = texture_coords.y*c.w;
		return c;
	}
]])

	icons = {
		loginBG = love.graphics.newImage("assets/icons/loginBG.png"),
		logincard = love.graphics.newImage("assets/icons/logincard.png"),
		success = love.graphics.newImage("assets/icons/success.png"),
		trouble = love.graphics.newImage("assets/icons/error.png"),
		lvl = love.graphics.newImage("assets/icons/lvl.png"),
		followers = love.graphics.newImage("assets/icons/followers.png"),
		following = love.graphics.newImage("assets/icons/following.png"),
		nofollow = love.graphics.newImage("assets/icons/nofollow.png"),
		yesfollow = love.graphics.newImage("assets/icons/yesfollow.png"),
		energy = love.graphics.newImage("assets/icons/energy.png"),
		fun = love.graphics.newImage("assets/icons/fun.png"),
		hunger = love.graphics.newImage("assets/icons/fullness.png"),
		hp = love.graphics.newImage("assets/icons/health.png"),
		home = love.graphics.newImage("assets/icons/home.png"),
		zakeh = love.graphics.newImage("assets/icons/zakeh.png"),
		insta = love.graphics.newImage("assets/icons/insta.png"),
		fbico = love.graphics.newImage("assets/icons/fb.png"),
		twitter = love.graphics.newImage("assets/icons/twitter.png"),
		b0 = love.graphics.newImage("assets/icons/button0.png"),
		login = love.graphics.newImage("assets/icons/login0.png"),
		refresh = love.graphics.newImage("assets/icons/refresh.png"),
		prev = love.graphics.newImage("assets/icons/prev.png"),
		next = love.graphics.newImage("assets/icons/next.png"),
		missingpou = love.graphics.newImage("assets/icons/missing.jpg"),
		about = love.graphics.newImage("assets/icons/about.png"),
		more = love.graphics.newImage("assets/icons/more.png"),
		b1 = love.graphics.newImage("assets/icons/button1.png"),
		b2 = love.graphics.newImage("assets/icons/button2.png"),
		b3 = love.graphics.newImage("assets/icons/button3.png"),
		b4 = love.graphics.newImage("assets/icons/button4.png"),
		b5 = love.graphics.newImage("assets/icons/button5.png"),
		b6 = love.graphics.newImage("assets/icons/button6.png"),
		b7 = love.graphics.newImage("assets/icons/button7.png"),
		b8 = love.graphics.newImage("assets/icons/button8.png"),
	}
	drawPou = require("draw")
	drawPou:drawPou(pouvisit,{color = 1,sz = 0.5})

	drawPou:drawPou(poudrawtest,{color = 1,sz = 0.5})

	sounds = {
		trouble = love.audio.newSource("assets/sounds/error.mp3","static"),
		success = love.audio.newSource("assets/sounds/levelup.ogg","static"),
		good = love.audio.newSource("assets/sounds/effect.ogg","static"),
		touch = love.audio.newSource("assets/sounds/touch.ogg","static"),
	}
	
	items = require("items")
	fonts = {
		pou = love.graphics.newFont("pou.ttf",80),
		medpou = love.graphics.newFont("pou.ttf",40),
		mpou = love.graphics.newFont("pou.ttf",30),
		smolpou = love.graphics.newFont("pou.ttf",20),
		def = love.graphics.getFont()
	}
	state = "home"--"pouDrawTestPleaseDoNotUseThis"
	substate = ""
	account = {
		name = "Pou",
		id = 666,
		last = os.time(),
		following = 1,
		followers = 777,
		lvl = 22,
		isFollowing = false,
		isFollowed = false,
		type="normal",
		stats={},
		state = {
			food = 10,
			hp = 100,
			fun = 100,
			sleep = 100,
			cC = 0, --coins Current
			cE = 0, --coins Erased
		},
	}
	myacc = {
		id = 0,
		name = "",
	}
	live_stats = {
		name = "[Unnamed]",
		id = 0,
		following = 0,
		likesum = {0},
		followers = 0,
		followsum = {0},
	}
	server = {
		name = "Pou",
		description = "Pou Official Server",
		image = "iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAIAAAD9iXMrAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAnSURBVChTYyAB1BMChNVtfSYLJAmrgwCoOmIBVBduQFjdCHUfAwMAXG6UCb238f8AAAAASUVORK5CYII=",
		creator = 98,
		links = {
			facebook = "mypou",
			instagram = "pou.gram",
			twitter = "poualien",
			web = "https://www.zakeh.com",
		}
	}
	
	serverIcon = nil
	
	function updateServerImage(base64)
		local a = love.data.decode("data","base64",base64)
		local b = love.image.newImageData(a)
		serverIcon = love.graphics.newImage(b)
		serverIcon:setFilter("nearest", "nearest")
		a:release() b:release()
	end
	
	updateServerImage(server.image)
	
	configchanged = false
	
	function updateServer(js,host)
		print(js,host,"dos")
		local _,t = pcall(function() return drawPou.toTable(js) end)
		if type(t) ~= "table" then t = {} love.window.showMessageBox(translate:Get("warn"),string.format(translate:Get("no-meta"),tostring(host)),"warning") end
		server.name = t.name or "Unnamed"
		server.description = t.description or ""
		server.image = t.image or "iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAIAAAD9iXMrAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAnSURBVChTYyAB1BMChNVtfSYLJAmrgwCoOmIBVBduQFjdCHUfAwMAXG6UCb238f8AAAAASUVORK5CYII="
		server.creator = t.creator or 0
		server.links = t.links or {facebook="",instagram="",twitter="",web=""}
		if host == "http://app.pou.me/" then
			server = {name = "Pou",description = "Pou Official Server",image = "",creator = 98,links = {	facebook = "mypou",	instagram = "pou.gram",	twitter = "poualien",	web = "https://www.zakeh.com", }}
		end
		pcall(function() updateServerImage(server.image) end)
	end
	
	function meUpdate(str)
		local js = drawPou.toTable(str)
		myacc.id = js.i or 0
		myacc.name = js.n or ""
	end

	function userChange(option,arg1,arg2)
		local res = ""
		if option == "mail" then
			if (arg1:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
				res = _G.Client.changeEmail(arg1)
			else
				badState(translate:Get("badmail")) return
			end
		elseif option == "pass" then
			res = _G.Client.changePassword(arg1,arg2)
		elseif option == "name" then
			res = _G.Client.changeNickname(arg1)
		end
		local a,b = pcall(function() return _G.json.decode(res) end)
		print(res,a,b)
		if a then
			if b.error then
				badState(translate:Get(b.error.type))
			end
			if b.success == true then
				configchanged = true
				local aa2=arg1
				if option == "pass" then aa2 = arg2 end
				local msg = string.format(translate:Get("change"..option),aa2)
				goodState(msg)
			end
		else
			badState("An unknown error occurred")
		end
	end
	
	function badState(msg)
		sounds.trouble:play()
		bannerMsg = msg
		bannerType = "error"
		bannerTime = 0
	end
	function goodState(msg)
		sounds.good:play()
		bannerMsg = msg
		bannerType = "success"
		bannerTime = 0
	end
	
	function updateUser(tab,isMini)
		account.id = tab.i
		live_stats.id = tab.i
		account.name = tab.n
		live_stats.name	= tab.n
		account.following = tab.nF
		live_stats.following = tab.nF
		account.followers = tab.nL
		live_stats.followers = tab.nL
		account.isFollowing = tab.iL
		account.isFollowed = tab.lM
		tab.state = tab.state or {}
		account.last = (tab.state.time or 0)
		account.state.food = tab.state.fullness or 100
		account.state.hp = tab.state.health or 100
		account.state.fun = tab.state.fun or 100
		account.state.sleep = tab.state.energy or 100
		account.stats = tab.state.stats or {}
		account.lvl = (tab.state.lvl or 0)
		account.xp = tab.state.xp or 0
		account.vV = tab.version or 0
		account.vC = tab.revision or 0
		local ext2 = tab.state.coins or {}
		local tn = tonumber
		local function tonumber(n) local m = tn(n) if m == nil then return 0 else return m end end
		account.state.cC = tonumber(ext2.c)+tonumber(ext2.g)+tonumber(ext2.b)+tonumber(ext2.x)+tonumber(ext2.h)
		account.state.cE = tonumber(ext2.s)
		account.type = (isMini) and "mini" or "normal"
		drawPou:drawPou(pouvisit,drawPou:toDrawer( isMini and tab.minI or (tab.state) ))
		drawPou:drawPou(statspou,drawPou:toDrawer( isMini and tab.minI or (tab.state) ))
	end
	
	function login(e,p,isdata)
		local client = _G.Pou.login(e,p)
		print(client.type,e,p)
		local errord = false
		if client == "no-connection" then badState("No Internet Connection") return false end
		if client.type ~= "guest" then
			if client.type == "cookie" then client.me = config.mypou end
			if client.type == "account" then config.lastlogged = os.time() end
			meUpdate(client.me)
			local tab = drawPou.toTable(client.me)
			if tab.error then
				local __ = tab.error.argument or {}
				local ___ = __.name or "unknown"
				badState(string.format(translate:Get(tab.error.type),___))
				errord = true
			else
				if not isdata then
					config.password = p
					config.mail = e
					config.cookie = _G.cookie
					config.mypou = client.me
					print(config.mypou)
					love.filesystem.write("conf.json",_G.json.encode(config))
				end
				if _G.Client then if _G.Client.type ~= "guest" then logout() end end
				updateUser(tab)
			end
			if tab and tab.n then
				items.texts.newNick.text = tab.n
			end
		end
		_G.Client = client
		if errord == true then _G.Client.type = "guest" return end
		print(_G.Client,"dhsaj")
		state = "home"
	end
	function newNick(new)
		local res = _G.Client.changeNickname(new)
		if string.len(res)<1 then return end
		local t = _G.json.decode(res)
		if t.error then
			badState(t.error.message)
		else
			goodState("Changed nick to '"..new.."'")
			account.name = new
			local tab = _G.json.decode(config.mypou)
			tab.n = new
			config.mypou = _G.json.encode(tab)
		end
	end
	function like()
		local res = _G.Client.like(account.id)
		if string.len(res)<1 then return end
		local t = _G.json.decode(res)
		if t.error then
			badState(t.error.message)
		else
			goodState(translate:Get("goodstate"))
			account.followers = t.nL
			account.isFollowing = 1
		end
	end
	function unlike()
		local res = _G.Client.unLike(account.id)
		if string.len(res)<1 then return end
		local t = _G.json.decode(res)
		if t.error then
			badState(t.error.message)
		else
			goodState(translate:Get("goodstate"))
			account.followers = t.nL
			account.isFollowing = 0
		end
	end
	function visit(info,mini)
		if _G.Client.type == "guest" then
			state = "login"
			return
		end
		print(info)
		local tab
		if not info then
			tab = drawPou.toTable(_G.Client.me)
		else
			if string.len(info)==0 then badState("An Error Occurred") return end
			tab = drawPou.toTable(info)
			if tab.error then
				tab.error.resource = tab.error.resource or {}
				badState(string.format(translate:Get(tab.error.type),tab.error.resource.type,tab.error.resource.id))
				return
			elseif tab.found == false then
				badState(translate:Get("noUserEmpty")) return
			end
		end
			updateUser(tab,mini)
			state = "visit"
			substate = "page1"
			items.texts.sNick.text = ""
			items.texts.sMail.text = ""
			items.texts.sID.text = ""
	end
	function getMsgs(id)
		local s,_ = pcall(function() return _G.Client.getMessages(id,0) end)
		if s then
			if #_ == 0 then badState("An Error Occurred") return end
			local tab = drawPou.toTable(_)
			if tab.items then
				topLikes = tab or {}
			else badState("No list found") return end
			state = "guestbook"
		end
	end
	topLikes = {}
	function drawPous()
		for count= 1,10 do
			local pou = topLikes.items[(tonumber(substate:gsub("page",""),10)-1)*10+count]
			if pou then
				local mini = pou.minI or pou.oMinI or pou.sMinI or ""
				local _s,JSON = pcall(function() return drawPou.toTable(mini) end)
				if _s then
					drawPou:drawPou(gridpou[count],drawPou:toDrawer(JSON))
				end
			end
		end
	end
	function updateTop(str,news)
		print(str)
		if #str == 0 then badState("An Error Occurred") return end
		local tab = drawPou.toTable(str)
		if tab.items then
				topLikes = tab or {}
		else badState("No list found") return end
		state = news or "top"
		substate = "page1"
		drawPous()
	end
	opname = "" --opponent name
	curMatch = {}
	function updateGame(str)
		local tab = drawPou.toTable(str)
		print(str)
		topLikes = tab or {}
		drawPous()		
	end
	
	function updateMatch(str)
		local tab = drawPou.toTable(str) print(str)
		if tab then
			if tab.error then badState(translate:Get(tab.error.type)) return end
			curMatch = tab
			print(tab.s,"hehehehe")
			drawPou:drawGame(tictactable,tab.s,tab.mI)
			state = "tictacpou"
		end
	end
	
	function clickgame(id)
		--if id == 31 or id == 28 then return badState(translate:Get("noTop")) end if id == 8 then items.buttons.button7.func(items) return elseif id == 9 then items.buttons.button8.func(items) return end
		local _s,top = pcall(function() return _G.Client.topScores(id,extra.options.gtopday) end)
		if _s then
			updateTop(top,"topscores")
		else badState("An error occurred")
		end
	end
	
	function changeHost(newHost)
		local a = love.window.showMessageBox(translate:Get("warn"),translate:Get("newserver"),{"No","Yes!",escapebutton=1},"warning")
		if a == 2 then
			logout(true)
			local res = _G.Pou.changeHost(newHost)
			config.host = newHost
			love.filesystem.write("conf.json",_G.json.encode(config))
			print(res,newHost)
			updateServer(res,newHost)
		else
			--not
		end
	end
	
	function relogin()
		if _G.Client.type ~= "guest" then
			local mail,pass = config.mail,config.password
			logout()
			love.timer.sleep(1)
			login(mail,pass)
		else
			badState("Can't relogin while not logged in")
		end
	end
	
	function logout(force)
		local s = _G.Client.logOut()
		if s or force==true then
			goodState("Success!")
			config.mail = "" config.password = "" config.cookie = "" config.mypou = "" love.filesystem.write("conf.json",_G.json.encode(config))
			_G.Client.type = "guest"
			items.texts.mail.text = ""
			items.texts.pass.text = ""
			state = "login"
		end
	end
	
	function clickuser(i)
		if state == "top" or state == "tictaclobby" or state == "guestbook" or state == "guestsend" or state == "userlist" or state == "topscores" then
			local _,__ = string.gsub(substate,"page","")
			local mul = tonumber(_) or 1
			mul = mul-1
			local ps = i+10*mul --position
			if state == "guestsend" then
				local _s,_res = pcall(function() return _G.Client.sendMessage(account.id,ps) end)
				if _s and _res then
					local js = drawPou.toTable(_res)
					if js.error then
						badState(translate:Get(js.error.type))
					else
						goodState(translate:Get("goodstate"))
						state = "visit"
					end
				else badState(translate:Get("baderror"))
				end
				return
			end
			if topLikes then
				local _tab = topLikes.items[ps]
				local id = _tab.i or _tab.sI or "undefined"
				if state == "top" or state == "guestbook" or state == "userlist" or state == "topscores" then
					if id == account.id then visit() else local inf = _G.Client.getUserById(id) visit(inf) end
				else
					local a = _G.Client.getSession(id)
					opname = _tab.oN or "[Unnamed]"
					updateMatch(a)
				end
			end
		end
	end
	
	--local c,s = love.filesystem.read("poulogin")
	conf,_suc = love.filesystem.read("conf.json")
	local temptab = {fastlog = false,mail = "",password = "",cookie = "",mypou="",host="http://app.pou.me/",lastlogged=0}
	if (not conf) or (string.len(conf)==0) then
		love.filesystem.write("conf.json",_G.json.encode(temptab)) config = temptab
		login()
	else
		_sus,config = pcall(function() return json.decode(conf) end)
		if _sus == false then
			love.filesystem.write("conf.json",_G.json.encode(temptab))
			config = temptab
			login()
		else
			local a = _G.Pou.changeHost(config.host)
			if a and config.host ~= "http://app.pou.me/" then updateServer(a,config.host) end
			if #config.mail > 0 and #config.password > 0 then
				if #config.cookie > 0 and #config.mypou > 0 then
					login(config.cookie,nil,true)
				else
					login(config.mail,config.password,true)
				end
			else
				login()
			end
		end
	end
	
	--[[if c then
		local find = string.find(c,"¬") or 0
		local mail = string.sub(c,0,find-1)
		local pass = string.sub(c,find+2,1000)
		local sus = login(mail,pass,true)
	end]]
	--changeHost("http://app.pou.me/")
	love.timer.step() --disable splash screen
end

function love.keypressed(key)
	items:keypress(key)
end

function love.textinput(txt)
	items:press(txt)
end

function love.mousepressed(x,y)
	items:click(x,y)
	print(x,y)
end

function love.update(dt)
	--drawPou:drawPou(poudrawtest,{color = 1,sz = 0.5, talk = math.random()*2})
	bannerTime = bannerTime+dt
	items:update(dt)
	for a,b in pairs(items.buttons) do
		b.v = false
		b.e = false
	end
	for a,b in pairs(items.texts) do
		b.v = false
		b.e = false
	end
	if state == "login" then
		items.texts.mail.v = true items.texts.mail.e = true items.texts.pass.v = true items.texts.pass.e = true
		items.buttons.login.v = true items.buttons.login.e = true
		items.buttons.exit.e = true
	elseif state == "home" then
		for a,b in pairs(items.buttons) do
			if string.match(a,"button") then
				b.e = true
			end
		end
		items.buttons.zakehweb.e = true
		items.buttons.instagram.e = true
		items.buttons.facebook.e = true
		items.buttons.twitter.e = true
	elseif state == "visit" then
		items.buttons.like.e = true
		items.buttons.exit.v = false items.buttons.exit.e = true
		items.buttons.usermenu.v = true items.buttons.usermenu.e = true
		items.buttons.guestbook.v = true items.buttons.guestbook.e = true
	elseif state == "search" then
		items.texts.sNick.v = true items.texts.sNick.e = true
		items.texts.sMail.v = true items.texts.sMail.e = true
		items.texts.sID.v = true items.texts.sID.e = true
		items.buttons.sNick.v = true items.buttons.sNick.e = true
		items.buttons.sMail.v = true items.buttons.sMail.e = true
		items.buttons.miniNick.v = true items.buttons.miniNick.e = true
		items.buttons.miniMail.v = true items.buttons.miniMail.e = true
		items.buttons.sID.v = true items.buttons.sID.e = true
		items.buttons.exit.v = false items.buttons.exit.e = true
	elseif state == "conf" then
		for a,b in pairs(items.buttons) do
			if string.match(a,"conf") then
				b.e = true
				b.v = true
			end
		end
		items.buttons.exit.v = false items.buttons.exit.e = true
		items.buttons.about.e = true
		items.texts.host.v = true items.texts.host.e = true
		items.texts.newNick.v = true items.texts.newNick.e = true
		items.texts.newMail.v = true items.texts.newMail.e = true
		items.texts.newPass.v = true items.texts.newPass.e = true
		items.texts.oldPass.v = true items.texts.oldPass.e = true
	elseif state == "top" or state == "tictaclobby" or state == "guestbook" or state == "guestsend" or state == "userlist" or state == "topscores" then
		items.buttons.exit.v = false items.buttons.exit.e = true
		local _,__ = string.gsub(substate,"page","")
		local itCount = (state == "guestsend") and 18 or #topLikes.items --item count
		local num = tonumber(_) or 1
		if num > 1 then items.buttons.left.e = true items.buttons.left.v = true end
		if num*10 < itCount then items.buttons.right.e = true items.buttons.right.v = true end
		for a,b in pairs(items.buttons) do
			if string.match(a,"pou_user") then
				local count = string.gsub(a,"pou_user","")
				--print(#topLikes.items,(num-1)*10+count,topLikes.items[(num-1)*10+count],num,a)
				if itCount >= (num-1)*10+count then
					b.e = true
				end
			end
		end
		if state == "guestbook" then
			items.buttons.gbmenu.e = true
		end
	elseif state == "tictacpou" or state == "fourpous" then
		items.buttons.exit.v = false items.buttons.exit.e = true
	elseif state == "about" then
		items.buttons.exit.v = false items.buttons.exit.e = true
		items.buttons.git.v = true items.buttons.git.e = true
	elseif state == "usermenu" then
		items.buttons.likes.v = true items.buttons.likes.e = true
		items.buttons.follows.v = true items.buttons.follows.e = true
		items.buttons.visitors.v = true items.buttons.visitors.e = true
		items.buttons.states.v = true items.buttons.states.e = true
		items.buttons.livestats.v = true items.buttons.livestats.e = true
		items.buttons.exit.v = false items.buttons.exit.e = true
	elseif state == "topgame" then
		items.buttons.exit.v = false items.buttons.exit.e = true
		for a,b in pairs(items.buttons) do
			if string.match(a,"pou_game") then
				local count = string.gsub(a,"pou_game","")
				--print(#topLikes.items,(num-1)*10+count,topLikes.items[(num-1)*10+count],num,a)
				if 32 >= tonumber(count) then
					b.e = true
				end
			end
			if string.match(a,"gday") then
				b.e = true
			end
		end
	elseif state == "livestats" then
		items.buttons.exit.v = false items.buttons.exit.e = true
	end
	local likeupdatestr = love.thread.getChannel("likeupdate"):pop()
	if likeupdatestr then
		local _s,tab = pcall(function() return drawPou.toTable(likeupdatestr) end)
		if _s then
			if #live_stats.likesum >= 15 then table.remove(live_stats.likesum,1) end
			if #live_stats.followsum >= 15 then table.remove(live_stats.followsum,1) end
			table.insert(live_stats.likesum,tab.nL-live_stats.followers)
			table.insert(live_stats.followsum,tab.nF-live_stats.following)
			live_stats.id = tab.i
			live_stats.name = tab.n
			live_stats.followers = tab.nL
			live_stats.following = tab.nF
			if tab.minI then
				drawPou:drawPou(statspou,drawPou:toDrawer(tab.minI))
			end
		end
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.3,0.6,1)
	love.graphics.setFont(fonts.pou)
	love.graphics.print("Pou",love.graphics:getWidth()/2-fonts.pou:getWidth("Pou")/2,10)
	
	--bg
	love.graphics.setShader(logShad)
	love.graphics.draw(icons.loginBG,0,200,0,800/1000,800/1000)
	love.graphics.setShader()
	
	if state == "visit" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.setFont(fonts.medpou)
		love.graphics.draw(pouvisit,80,190,0,1/3,1/3)
		if server.creator == account.id then love.graphics.setColor(0.96,0.87,0.2,1) end
		love.graphics.print(account.name,200,190)
		love.graphics.setColor(1,1,1,1)
		if account.isFollowing==1 and account.isFollowed==1 then
			love.graphics.draw(icons.yesfollow,80,320,0,100/icons.yesfollow:getWidth(),100/icons.yesfollow:getHeight())
		elseif account.isFollowing==1 then
			love.graphics.draw(icons.following,80,320,0,100/icons.following:getWidth(),100/icons.following:getHeight())
		elseif account.isFollowed==1 then
			love.graphics.draw(icons.followers,80,320,0,100/icons.followers:getWidth(),100/icons.followers:getHeight())
		else
			love.graphics.draw(icons.nofollow,80,320,0,100/icons.nofollow:getWidth(),100/icons.nofollow:getHeight())
		end
		love.graphics.print("x"..account.followers,190,370-(fonts.medpou:getHeight()/2))
		
		love.graphics.setFont(fonts.def)
		love.graphics.print("ID: "..account.id,200,230)
		if account.type == "normal" then
		love.graphics.print(os.date("Last time saved: %x %X",account.last),200,250)
		if account.vV == 4 then
			love.graphics.print("Coins: "..account.state.cC-account.state.cE.." (unaccurate)",200,270)
		end
		if account.vV == _G.Pou.versionVersion and account.vC == _G.Pou.versionCode then
			love.graphics.print("Pou has same version as client!",200,290)
		end
		sColor(account.state.food)
		love.graphics.rectangle("fill",500,240-account.state.food/2,50,account.state.food/2)
		sColor(account.state.hp)
		love.graphics.rectangle("fill",550,240-account.state.hp/2,50,account.state.hp/2)
		sColor(account.state.fun)
		love.graphics.rectangle("fill",600,240-account.state.fun/2,50,account.state.fun/2)
		sColor(account.state.sleep)
		love.graphics.rectangle("fill",650,240-account.state.sleep/2,50,account.state.sleep/2)
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(icons.hunger,500,190,0,50/icons.hunger:getWidth(),50/icons.hunger:getHeight())
		love.graphics.draw(icons.hp,550,190,0,50/icons.hp:getWidth(),50/icons.hp:getHeight())
		love.graphics.draw(icons.fun,600,190,0,50/icons.fun:getWidth(),50/icons.fun:getHeight())
		love.graphics.draw(icons.energy,650,190,0,50/icons.energy:getWidth(),50/icons.energy:getHeight())
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(icons.lvl,500,260,0,60/icons.lvl:getWidth(),55/icons.lvl:getHeight())
		love.graphics.setColor(0,0,0,1)
		love.graphics.print(account.lvl,530-fonts.def:getWidth(account.lvl)/2,287.5-fonts.def:getHeight()/2)
		local percentagelvl = extra.fixNum(math.floor(((((account.lvl+1)*55)-account.xp)/((account.lvl+1)*55))*100),0,100) .. "%"
		love.graphics.print(percentagelvl, 530-fonts.def:getWidth(percentagelvl)/2,320)
		end
		
	elseif state == "home" then
		if _G.Client then
			if _G.Client.type ~= "guest" then
				love.graphics.draw(icons.b0,items.buttons.button0.x,items.buttons.button0.y,0,items.buttons.button0.sx/icons.b0:getWidth(),items.buttons.button0.sy/icons.b0:getHeight())
				love.graphics.setFont(fonts.smolpou)
				local time = os.time()-config.lastlogged
				local str = translate:Get("tS")
				if time >= 60 then
					time = math.floor(time/60)
					str = translate:Get("tM")
					if time >= 60 then
						time = math.floor(time/60)
						str = translate:Get("tH")
						if time >= 24 then
							time = math.floor(time/24)
							str = translate:Get("tD")
						end
					end
				end
				love.graphics.print(string.format(translate:Get("lastlog"),time.." "..str),110,565)
				love.graphics.setFont(fonts.pou)
			else
				love.graphics.draw(icons.login,items.buttons.button0.x,items.buttons.button0.y,0,items.buttons.button0.sx/icons.login:getWidth(),items.buttons.button0.sy/icons.login:getHeight())
			end
		end
		love.graphics.draw(icons.b1,items.buttons.button1.x,items.buttons.button1.y,0,items.buttons.button1.sx/icons.b1:getWidth(),items.buttons.button1.sy/icons.b1:getHeight())
		love.graphics.draw(icons.b2,items.buttons.button2.x,items.buttons.button2.y,0,items.buttons.button2.sx/icons.b2:getWidth(),items.buttons.button2.sy/icons.b2:getHeight())
		love.graphics.draw(icons.b3,items.buttons.button3.x,items.buttons.button3.y,0,items.buttons.button2.sx/icons.b3:getWidth(),items.buttons.button3.sy/icons.b3:getHeight())
		love.graphics.draw(icons.b4,items.buttons.button4.x,items.buttons.button4.y,0,items.buttons.button2.sx/icons.b4:getWidth(),items.buttons.button4.sy/icons.b4:getHeight())
		love.graphics.draw(icons.b5,items.buttons.button5.x,items.buttons.button5.y,0,items.buttons.button5.sx/icons.b5:getWidth(),items.buttons.button5.sy/icons.b5:getHeight())
		love.graphics.draw(icons.b6,items.buttons.button6.x,items.buttons.button6.y,0,items.buttons.button6.sx/icons.b6:getWidth(),items.buttons.button6.sy/icons.b6:getHeight())
		love.graphics.draw(icons.b7,items.buttons.button7.x,items.buttons.button7.y,0,items.buttons.button7.sx/icons.b7:getWidth(),items.buttons.button7.sy/icons.b7:getHeight())
		love.graphics.draw(icons.b8,items.buttons.button8.x,items.buttons.button8.y,0,items.buttons.button8.sx/icons.b8:getWidth(),items.buttons.button8.sy/icons.b8:getHeight())
		love.graphics.draw(icons.zakeh,items.buttons.zakehweb.x,items.buttons.zakehweb.y,0,items.buttons.zakehweb.sx/icons.zakeh:getWidth(),items.buttons.zakehweb.sy/icons.zakeh:getHeight())
		love.graphics.draw(icons.insta,items.buttons.instagram.x,items.buttons.instagram.y,0,items.buttons.instagram.sx/icons.insta:getWidth(),items.buttons.instagram.sy/icons.insta:getHeight())
		love.graphics.draw(icons.fbico,items.buttons.facebook.x,items.buttons.facebook.y,0,items.buttons.facebook.sx/icons.fbico:getWidth(),items.buttons.facebook.sy/icons.fbico:getHeight())
		love.graphics.draw(icons.twitter,items.buttons.twitter.x,items.buttons.twitter.y,0,items.buttons.twitter.sx/icons.twitter:getWidth(),items.buttons.twitter.sy/icons.twitter:getHeight())
		if os.time()-config.lastlogged >= 86400 then
			love.graphics.setColor(0,1,0,1)
		end
		love.graphics.draw(icons.refresh,items.buttons.button.x,items.buttons.button.y,0,items.buttons.button.sx/icons.refresh:getWidth(),items.buttons.button.sy/icons.refresh:getHeight())
		love.graphics.setColor(1,1,1,1)
	elseif state == "search" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
	elseif state == "top" or state == "tictaclobby" or state == "guestbook" or state == "guestsend" or state == "userlist" or state == "topscores" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		--[[love.graphics.setColor(0.5,0.5,0.5,0.8)
		love.graphics.rectangle("fill",170,130,470,450)
		
		love.graphics.setColor(1,1,1,1)
		love.graphics.print(ttl1..ttl2,200,150)]]
		local _unn_=string.gsub(substate,"page","") --unnecesary/temp/randomnamexd
		local mul = tonumber(_unn_) or 1
		mul=mul-1
		
		
		for b = 0,4 do
			for a = 0,1 do
				local position = ((a+1)+(2*b))+mul*10
				if state ~= "guestsend" then
					--local position = ( (b+1)+(5*a) )+mul*10
					local pou = topLikes.items[position]
					if pou then
						love.graphics.setColor(0.7,0.7,0.7,0.6)
						love.graphics.rectangle("fill",90+330*a,130+90*b,290,80)
						love.graphics.setColor(1,1,1,1)
						love.graphics.setFont(fonts.smolpou)
						
						local mini = pou.minI or pou.oMinI or pou.sMinI or ""
						local nam = pou.n or pou.oN or pou.sN or "[Unnamed]"
						local idd = pou.i or pou.oI or pou.sI or 0
	
						if mini~="" then
							local _s,JSON = pcall(function() return drawPou.toTable(mini) end)
							if _s then
								--drawPou:drawPou(minipou,drawPou:toDrawer(JSON))
								love.graphics.draw(gridpou[(a+1)+(2*b)],90+330*a,130+90*b,0,80/300,80/300)
							else
								love.graphics.draw(icons.missingpou,90+330*a,130+90*b,0,80/icons.missingpou:getWidth(),80/icons.missingpou:getHeight())
							end
						else
							love.graphics.draw(icons.missingpou,90+330*a,130+90*b,0,80/icons.missingpou:getWidth(),80/icons.missingpou:getHeight())
						end
						
						love.graphics.rectangle("line",90+330*a,130+90*b,290,80)
						love.graphics.print(nam,175+330*a,133+90*b)
						love.graphics.setFont(fonts.def)
						love.graphics.print("ID: ".. idd,175+330*a,155+90*b)
						if state == "top" then
							love.graphics.print("Likes: ".. pou.nL,175+330*a,170+90*b)
							love.graphics.print("Position: ".. position,175+330*a,185+90*b)
						elseif state == "tictaclobby" then
							local _str = "Unknown state"
							if pou.e then
								if pou.wB == 0 then
									_str = translate:Get("matchtie") love.graphics.setColor(0.4,0.4,0.4,1)
								elseif pou.wB == pou.mI then
									_str = translate:Get("matchwin") love.graphics.setColor(0,1,0.3,1)
								else
									_str = string.format(translate:Get("matchlose"),nam) love.graphics.setColor(1,0.2,0.2,1)
								end
								love.graphics.print(_str,175+330*a,170+90*b)
							else
								if pou.tO == pou.mI then
									_str = translate:Get("matchUturn") love.graphics.setColor(0,0.7,1,1)
								else
									_str = string.format(translate:Get("matchturn"),nam)
								end
								love.graphics.print(_str,175+330*a,170+90*b)
							end
						elseif state == "guestbook" then
							love.graphics.print(string.format(translate:Get("book"..pou.tI),account.name),175+330*a,170+90*b)
						elseif state == "userlist" then
							love.graphics.print("Likes: ".. pou.nL,175+330*a,170+90*b)
						elseif state == "topscores" then
							love.graphics.print("Likes: ".. pou.nL,175+330*a,170+90*b)
							love.graphics.print("Score: "..(pou.s or "Unknown"),175+330*a,185+90*b)
						end
						love.graphics.setColor(1,1,1,1)
						if pou.iL==1 and pou.lM==1 then
							love.graphics.draw(icons.yesfollow,305+330*a,140+90*b,0,60/icons.yesfollow:getWidth(),60/icons.yesfollow:getHeight())
						elseif pou.iL==1 then
							love.graphics.draw(icons.following,305+330*a,140+90*b,0,60/icons.yesfollow:getWidth(),60/icons.yesfollow:getHeight())
						elseif pou.lM==1 then
							love.graphics.draw(icons.followers,305+330*a,140+90*b,0,60/icons.yesfollow:getWidth(),60/icons.yesfollow:getHeight())
						else
							love.graphics.draw(icons.nofollow,305+330*a,140+90*b,0,60/icons.yesfollow:getWidth(),60/icons.yesfollow:getHeight())
						end
					end
				elseif position <= 18 then
					love.graphics.setColor(0.7,0.7,0.7,0.6) love.graphics.rectangle("fill",90+330*a,130+90*b,290,80) love.graphics.setColor(1,1,1,1)
					love.graphics.rectangle("line",90+330*a,130+90*b,290,80)
					love.graphics.setFont(fonts.smolpou)
					local txt = string.format(translate:Get("book"..position),account.name)
					love.graphics.print(txt,(235+330*a)-fonts.smolpou:getWidth(txt)/2,(170+90*b)-fonts.smolpou:getHeight()/2)
					love.graphics.setFont(fonts.def)
				end
			end
		end
		if state == "guestbook" then
			love.graphics.setFont(fonts.mpou)
			love.graphics.setColor(0.7,0.7,0.7,0.6)
			love.graphics.rectangle("fill",90,83,620,42) love.graphics.setColor(1,1,1,1)
			love.graphics.draw(icons.more,115,104,0,35/icons.more:getWidth(),35/icons.more:getHeight(),icons.more:getWidth()/2,icons.more:getHeight()/2)
			love.graphics.rectangle("line",90,83,620,42)
			love.graphics.print(translate:Get("booknew"),420-fonts.mpou:getWidth(translate:Get("booknew"))/2,104-fonts.mpou:getHeight()/2)
			love.graphics.setFont(fonts.def)
		end
	elseif state == "tictacpou" or state == "fourpous" then
		love.graphics.draw(tictactable,400,300,0,300/tictactable:getWidth(),300/tictactable:getHeight(),tictactable:getWidth()/2,tictactable:getHeight()/2)
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		--anti-DRY moment
		local _str = ""
		if curMatch.e=="1" then
			if curMatch.wB == "0" then
				_str = translate:Get("matchtie") love.graphics.setColor(0.4,0.4,0.4,1)
			elseif curMatch.wB == tostring(curMatch.mI) then
				_str = translate:Get("matchwin") love.graphics.setColor(0,1,0.2,1)
			else
				_str = string.format(translate:Get("matchlose"),opname) love.graphics.setColor(1,0.2,0.2,1)
			end
		else
			if curMatch.tO == tostring(curMatch.mI) then
				_str = translate:Get("matchUturn") love.graphics.setColor(0,0.7,1,1)
			else
				_str = string.format(translate:Get("matchturn"),opname) love.graphics.setColor(0.2,0.2,0.2,1)
			end
		end
		love.graphics.setFont(fonts.medpou)
		love.graphics.print(_str,400 - fonts.medpou:getWidth(_str)/2,500)
		love.graphics.setFont(fonts.def)
		love.graphics.setColor(1,1,1,1)
	elseif state == "about" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.setFont(fonts.medpou)
		love.graphics.print("About Pou Search "..versionName,110,160)
		love.graphics.setFont(fonts.smolpou)
		love.graphics.print("'Pou Search' is an open source project in GitHub.\n(https://github.com/H401217/pou-search)\n\nCredits to:\n** Zakeh (Paul Salameh): Creator of Pou videogame\n** rxi: Creator of json.lua\n	(https://github.com/rxi/json.lua)\n**u/oesky: Brazilian Portuguese translation\n	(https://www.reddit.com/u/oesky)",110,220)
		love.graphics.setFont(fonts.def)
	elseif state == "login" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.draw(icons.logincard,50,200,0,200/icons.logincard:getWidth(),200/icons.logincard:getHeight())
	elseif state == "conf" then
		--heads
		love.graphics.setFont(fonts.smolpou)
		love.graphics.print(translate:Get("opNick"),130,100)
		love.graphics.print(translate:Get("opMail"),130,165)
		love.graphics.print(translate:Get("opPass"),130,230)
		love.graphics.print(translate:Get("opHost"),400,350)
		love.graphics.setColor(0.1,0.1,0.1,1)
		love.graphics.print(translate:Get("currentLang"),245-fonts.smolpou:getWidth(translate:Get("currentLang"))/2,495) love.graphics.setColor(1,1,1,1)
		--content
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.draw(serverIcon,400,100,0,150/serverIcon:getWidth(),150/serverIcon:getHeight())
		love.graphics.print(server.name,560,100)
		love.graphics.setFont(fonts.def)
		love.graphics.print(server.description,560,120)
		love.graphics.print("Host: "..config.host.."\nFacebook: "..server.links.facebook.."\nTwitter: "..server.links.twitter.."\nInstagram: "..server.links.instagram.."\nWebsite: "..server.links.web,410,260)
		love.graphics.draw(icons.about,items.buttons.about.x,items.buttons.about.y,0,items.buttons.about.sx/icons.about:getWidth(),items.buttons.about.sy/icons.about:getHeight())
	elseif state == "usermenu" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.setFont(fonts.smolpou)
		love.graphics.print(account.following,160-fonts.smolpou:getWidth(account.following)/2,255)
		love.graphics.print(account.followers,320-fonts.smolpou:getWidth(account.followers)/2,255)
	elseif state == "topgame" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		local siz = 90
		for d=0,4,1 do
			for c = 0,6,1 do
				local pos = (c+1)+(7*d)
				if pos <= #extra.games then
					love.graphics.setColor(1,1,1,0.4)
					love.graphics.rectangle("fill",85+siz*c,130+siz*d,siz,siz)
					love.graphics.setColor(1,1,1,1)
					love.graphics.rectangle("line",85+siz*c,130+siz*d,siz,siz)
					local gamimg = extra.imgs["assets/icons/games/"..extra.games[pos]..".png"]
					love.graphics.draw(gamimg,(85+siz*c)+siz/2,(130+siz*d)+siz/2,0,siz*0.9/gamimg:getWidth(),siz*0.9/gamimg:getWidth(),gamimg:getWidth()/2,gamimg:getHeight()/2)
				end
			end
		end
		love.graphics.setColor(1,1,1,0.3)
		if extra.options.gtopday == "today" then
			love.graphics.rectangle("fill",124,90,138,30)
		elseif extra.options.gtopday == "week" then
			love.graphics.rectangle("fill",262,90,138,30)
		elseif extra.options.gtopday == "month" then
			love.graphics.rectangle("fill",400,90,138,30)
		elseif extra.options.gtopday == "alltime" then
			love.graphics.rectangle("fill",538,90,138,30)
		end
		love.graphics.setColor(1,1,1,1)
		love.graphics.setFont(fonts.def)
		love.graphics.rectangle("line",124,90,138,30)
		love.graphics.print(translate:Get("today"),193-fonts.def:getWidth(translate:Get("today"))/2,105-fonts.def:getHeight()/2)
		love.graphics.rectangle("line",262,90,138,30)
		love.graphics.print(translate:Get("week"),331-fonts.def:getWidth(translate:Get("week"))/2,105-fonts.def:getHeight()/2)
		love.graphics.rectangle("line",400,90,138,30)
		love.graphics.print(translate:Get("month"),469-fonts.def:getWidth(translate:Get("month"))/2,105-fonts.def:getHeight()/2)
		love.graphics.rectangle("line",538,90,138,30)
		love.graphics.print(translate:Get("alltime"),607-fonts.def:getWidth(translate:Get("alltime"))/2,105-fonts.def:getHeight()/2)
	elseif state == "livestats" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.draw(statspou,400,80,0,1/3,1/3,50,0)
		love.graphics.setFont(fonts.smolpou)
		love.graphics.print("Followers",400-fonts.smolpou:getWidth("Followers")/2,310)
		love.graphics.print("Following",90,350)
		love.graphics.print("ID:",90,420)
		love.graphics.setFont(fonts.medpou)
		love.graphics.print(live_stats.name,400-fonts.medpou:getWidth(live_stats.name)/2,185)
		love.graphics.print(live_stats.following,90,370)
		love.graphics.print(live_stats.id,90,440)
		love.graphics.setFont(fonts.pou)
		love.graphics.print(live_stats.followers,400-fonts.pou:getWidth(live_stats.followers)/2,230)
		
		local function cl(tab)
			local a = math.max(unpack(tab)) a=(a>1) and a or 1
			local b = math.max(unpack(tab)) b=(b<-1) and b or -1
			return a,b
		end
		local function calc(tab1,x,y,sx,sy)
			local likemax,likemin = cl(tab1)
			local liketab = {x,y+sy/2}
			for i,v in pairs(tab1) do
				table.insert(liketab,x+((i/#tab1)*sx))
				if v >= 0 then
					table.insert(liketab,(y+sy/2)+((v/likemax)*((sy/2)*-1)))
				else
					table.insert(liketab,(y+sy/2)+((v/likemin)*(sy/2)))
				end
			end
			return liketab
		end
		local function col(val)
			if val==0 then
				return 0.2,0.2,0.2,1
			elseif val > 0 then
				return 0,1,0,1
			else
				return 1,0,0,1
			end
		end
		local calc1,calc2 = calc(live_stats.likesum,500,350,220,100),calc(live_stats.followsum,500,470,220,100)
		love.graphics.setColor(col(live_stats.likesum[#live_stats.likesum]))
		love.graphics.line(calc1)
		love.graphics.setColor(col(live_stats.followsum[#live_stats.followsum]))
		love.graphics.line(calc2)
		love.graphics.setColor(1,1,1,1)
		love.graphics.setPointSize(3) love.graphics.points(calc1) love.graphics.points(calc2) love.graphics.setPointSize(1)
		love.graphics.setFont(fonts.def)
		love.graphics.rectangle("line",499,349,222,102)
		local l1,l2 = cl(live_stats.likesum)
		love.graphics.print(l1,723,350)
		love.graphics.print(l2,723,450-fonts.def:getHeight())
		love.graphics.rectangle("line",499,469,222,102)
		local l3,l4 = cl(live_stats.followsum)
		love.graphics.print(l3,723,470)
		love.graphics.print(l4,723,570-fonts.def:getHeight())
		love.graphics.print("+Followers",500,451)
		love.graphics.print("+Following",500,571)
	elseif state == "pouDrawTestPleaseDoNotUseThis" then
		love.graphics.draw(poudrawtest,0,0)
	end
	--state = "home"--"pouDrawTestPleaseDoNotUseThis"
	love.graphics.setColor(1,1,1,1)
	love.graphics.setFont(fonts.def)
	items:draw()
	
	--Error and success messages
	love.graphics.setFont(fonts.smolpou)
	if bannerTime < 2 then
		local bY = ((bannerTime>0.5) and bannerTime<1.5 and 0) or ((bannerTime <= 0.5) and -60+60*(bannerTime*2) or 60*((2-bannerTime)*2)-60)
		local col = (bannerType=="success") and {.1,.8,.1,1} or {.8,.1,.1,1}
		local ico = (bannerType=="success") and "success" or "trouble"
		love.graphics.setColor(col)
		love.graphics.rectangle("fill",0,bY,width,60)
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(icons[ico],20,bY+5,0,50/icons[ico]:getWidth(),50/icons[ico]:getHeight())
		love.graphics.print(bannerMsg,80,(bY+30)-fonts.smolpou:getHeight()/2)
	end
	love.graphics.setFont(fonts.def)
	love.graphics.print("1.4.125".."	"..love.timer.getFPS().." FPS")
end