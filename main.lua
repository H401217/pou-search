--[[
  _____               _____                     _     
 |  __ \             / ____|                   | |    
 | |__) |__  _   _  | (___   ___  __ _ _ __ ___| |__  
 |  ___/ _ \| | | |  \___ \ / _ \/ _` | '__/ __| '_ \ 
 | |  | (_) | |_| |  ____) |  __/ (_| | | | (__| | | |
 |_|   \___/ \__,_| |_____/ \___|\__,_|_|  \___|_| |_|
                                                      
Pou Search is an open source project in GitHub (https://github.com/H401217/pou-search).
]]

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
	width = love.graphics:getWidth()
	height = love.graphics:getHeight()
	
	pouvisit = love.graphics.newCanvas(100,100)

	drawPou = require("draw")
drawPou:drawPou(pouvisit,{color = 1,sz = 0.5})
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
		b1 = love.graphics.newImage("assets/icons/button1.png"),
		b2 = love.graphics.newImage("assets/icons/button2.png"),
		b3 = love.graphics.newImage("assets/icons/button3.png"),
		b4 = love.graphics.newImage("assets/icons/button4.png"),
		b5 = love.graphics.newImage("assets/icons/button5.png"),
	}
	
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
		smolpou = love.graphics.newFont("pou.ttf",20),
		def = love.graphics.getFont()
	}
	state = "home"
	account = {
		name = "Pou",
		id = 666,
		last = os.time(),
		following = 1,
		followers = 777,
		lvl = 22,
		isFollowing = false,
		isFollowed = false,
		state = {
			food = 10,
			hp = 100,
			fun = 100,
			sleep = 100,
			cC = 0, --coins Current
			cE = 0, --coins Erased
		},
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
		if type(t) ~= "table" then t = {} love.window.showMessageBox("Warning!","Metadata for custom server '"..host.."' not found!","warning") end
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
	
	function userChange(option,arg1,arg2)
		local res = ""
		if option == "mail" then
			res = _G.Client.changeEmail(arg1)
		elseif option == "pass" then
			res = _G.Client.changePassword(arg1,arg2)
		elseif option == "name" then
			res = _G.Client.changeNickname(arg1)
		end
		local a,b = pcall(function() return _G.json.decode(res) end)
		print(res,a,b)
		if a then
			if b.error then
				badState(b.error.message)
			end
			if b.success == true then
				configchanged = true
				local aa2=arg1
				if option == "pass" then aa2 = arg2 end
				local msg = "Changed "..option.." to '"..aa2.."'"
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
	
	function updateUser(tab)
		account.id = tab.i
		account.name = tab.n
		account.following = tab.nF
		account.followers = tab.nL
		account.isFollowing = tab.iL
		account.isFollowed = tab.lM
		account.last = tab.state.time
		account.state.food = tab.state.fullness
		account.state.hp = tab.state.health
		account.state.fun = tab.state.fun
		account.state.sleep = tab.state.energy
		account.lvl = tab.state.lvl
		account.vV = tab.version
		account.vC = tab.revision
		local ext2 = tab.state.coins
		local tn = tonumber
		local function tonumber(n) local m = tn(n) if m == nil then return 0 else return m end end
		account.state.cC = tonumber(ext2.c)+tonumber(ext2.g)+tonumber(ext2.b)+tonumber(ext2.x)+tonumber(ext2.h)
		account.state.cE = tonumber(ext2.s)
		drawPou:drawPou(pouvisit,{color = tostring(tab.state.bodyColors.a),sz=tab.state.size})
	end
	
	function login(e,p,isdata)
		local client = _G.Pou.login(e,p)
print(client.type,e,p)
		local errord = false
		if client == "no-connection" then badState("No Internet Connection") return false end
		if client.type ~= "guest" then
		if client.type == "cookie" then client.me = config.mypou end
		if client.type == "account" then config.lastlogged = os.time() end
		local tab = drawPou.toTable(client.me)
		if tab.error then
			badState(tab.error.message)
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
			goodState("Success!")
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
			goodState("Success!")
			account.followers = t.nL
			account.isFollowing = 0
		end
	end
	function visit(info)
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
				badState(tab.error.message)
				return
			end
		end
			updateUser(tab)
			state = "visit"
			items.texts.sNick.text = ""
			items.texts.sMail.text = ""
			items.texts.sID.text = ""
	end
	ttl1 = "" --temp top likes str 1 (left)
	ttl2 = ""
	function updateTop(str)
		if #str == 0 then badState("An Error Occurred") return end
		local tab = drawPou.toTable(str)
		ttl1 = ""
		ttl2 = ""
		for a,b in pairs(tab["items"]) do
			if a > 10 then
				ttl2 = ttl2..a..". ".. b.n .. "	(".. b.nL .. " Likes)\n"
			else
				ttl1 = ttl1..a..". ".. b.n .. "	(".. b.nL .. " Likes)\n"
			end
		end
		state = "top"
	end
	
	function changeHost(newHost)
		local a = love.window.showMessageBox("Warning!","Changing host will close your current Pou account!\nAre you sure to continue?",{"No","Yes!",escapebutton=1},"warning")
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
	--local c,s = love.filesystem.read("poulogin")
	conf,_suc = love.filesystem.read("conf.json")
	local temptab = {fastlog = false,mail = "",password = "",cookie = "",mypou="",host="http://app.pou.me/",lastlogged=0}
	if (not conf) or (string.len(conf)==0) then
		love.filesystem.write("conf.json",_G.json.encode(temptab)) config = temptab
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
end

function love.keypressed(key)
	items:keypress(key)
end

function love.textinput(txt)
	items:press(txt)
end

function love.mousepressed(x,y)
	items:click(x,y)
end

function love.update(dt)
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
	elseif state == "search" then
		items.texts.sNick.v = true items.texts.sNick.e = true
		items.texts.sMail.v = true items.texts.sMail.e = true
		items.texts.sID.v = true items.texts.sID.e = true
		items.buttons.sNick.v = true items.buttons.sNick.e = true
		items.buttons.sMail.v = true items.buttons.sMail.e = true
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
		items.texts.host.v = true items.texts.host.e = true
		items.texts.newNick.v = true items.texts.newNick.e = true
		items.texts.newMail.v = true items.texts.newMail.e = true
		items.texts.newPass.v = true items.texts.newPass.e = true
		items.texts.oldPass.v = true items.texts.oldPass.e = true
	elseif state == "top" then
		items.buttons.exit.v = false items.buttons.exit.e = true
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
		love.graphics.draw(pouvisit,80,190,0,1,1)
		love.graphics.print(account.name,200,190)
		
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
		love.graphics.print(os.date("Last time saved: %x %X",account.last),200,250)
		if account.vV == 4 then
			love.graphics.print("Coins: "..account.state.cC-account.state.cE,200,270)
		else
			love.graphics.print("Can't load coins from old account",200,270)
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
		love.graphics.setColor(0,0,0,1)
		love.graphics.draw(icons.hunger,500,190,0,50/icons.hunger:getWidth(),50/icons.hunger:getHeight())
		love.graphics.draw(icons.hp,550,190,0,50/icons.hp:getWidth(),50/icons.hp:getHeight())
		love.graphics.draw(icons.fun,600,190,0,50/icons.fun:getWidth(),50/icons.fun:getHeight())
		love.graphics.draw(icons.energy,650,190,0,50/icons.energy:getWidth(),50/icons.energy:getHeight())
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(icons.lvl,500,260,0,60/icons.lvl:getWidth(),55/icons.lvl:getHeight())
		love.graphics.setColor(0,0,0,1)
		love.graphics.print(account.lvl,530-fonts.def:getWidth(account.lvl)/2,287.5-fonts.def:getHeight()/2)
	elseif state == "home" then
		if _G.Client then
			if _G.Client.type ~= "guest" then
				love.graphics.draw(icons.b0,items.buttons.button0.x,items.buttons.button0.y,0,items.buttons.button0.sx/icons.b0:getWidth(),items.buttons.button0.sy/icons.b0:getHeight())
				love.graphics.setFont(fonts.smolpou)
				local time = os.time()-config.lastlogged
				local str = " seconds"
				if time >= 60 then
					time = math.floor(time/60)
					str = " minutes"
					if time >= 60 then
						time = math.floor(time/60)
						str = " hours"
						if time >= 24 then
							time = math.floor(time/24)
							str = " days"
						end
					end
				end
				love.graphics.print("Last logged in: "..time..str,110,565)
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
	elseif state == "top" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.setColor(0.5,0.5,0.5,0.8)
		love.graphics.rectangle("fill",170,130,470,450)
		love.graphics.setFont(fonts.smolpou)
		love.graphics.setColor(1,1,1,1)
		love.graphics.print(ttl1..ttl2,200,150)
	elseif state == "login" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.draw(icons.logincard,50,200,0,200/icons.logincard:getWidth(),200/icons.logincard:getHeight())
	elseif state == "conf" then
		--heads
		love.graphics.setFont(fonts.smolpou)
		love.graphics.print("Change Nickname",130,100)
		love.graphics.print("Change Email",130,165)
		love.graphics.print("Change Password",130,230)
		love.graphics.print("Change Server",400,350)
		--content
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.draw(serverIcon,400,100,0,150/serverIcon:getWidth(),150/serverIcon:getHeight())
		love.graphics.print(server.name,560,100)
		love.graphics.setFont(fonts.def)
		love.graphics.print(server.description,560,120)
		love.graphics.print("Host: "..config.host.."\nFacebook: "..server.links.facebook.."\nTwitter: "..server.links.twitter.."\nInstagram: "..server.links.instagram.."\nWebsite: "..server.links.web,410,260)
	end
	love.graphics.setColor(1,1,1,1)
	love.graphics.setFont(fonts.def)
	items:draw()
	
	--Error and success messages
	love.graphics.setFont(fonts.smolpou)
	if bannerTime <= 0.5 then
		if bannerType == "success" then
			love.graphics.setColor(0.1,0.8,0.1,1)
			love.graphics.rectangle("fill",0,-60+60*(bannerTime*2),width,60)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(icons.success,20,-45+(45*(bannerTime*2)), 0,50/icons.success:getWidth(),50/icons.success:getHeight())
		else
			love.graphics.setColor(0.8,0.1,0.1,1)
			love.graphics.rectangle("fill",0,-60+60*(bannerTime*2),width,60)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(icons.trouble,20,-45+(45*(bannerTime*2)), 0,50/icons.trouble:getWidth(),50/icons.trouble:getHeight())
		end
		love.graphics.print(bannerMsg,80,-40 +(((30-fonts.smolpou:getHeight()/2)+40)*(bannerTime*2)))
	elseif bannerTime >= 1.5 and bannerTime <= 2 then
		if bannerType == "success" then
			love.graphics.setColor(0.1,0.8,0.1,1)
			love.graphics.rectangle("fill",0,60*((2-bannerTime)*2)-60,width,60)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(icons.success,20,-45+50*((2-bannerTime)*2), 0,50/icons.success:getWidth(),50/icons.success:getHeight())
		else
			love.graphics.setColor(0.8,0.1,0.1,1)
			love.graphics.rectangle("fill",0,60*((2-bannerTime)*2)-60,width,60)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(icons.trouble,20,-45+50*((2-bannerTime)*2), 0,50/icons.success:getWidth(),50/icons.success:getHeight())
		end
		love.graphics.print(bannerMsg,80,-40 +(((30-fonts.smolpou:getHeight()/2)+40)*((2-bannerTime)*2)))
	elseif bannerTime > 0.5 and bannerTime < 2 then
		if bannerType == "success" then
			love.graphics.setColor(0.1,0.8,0.1,1)
			love.graphics.rectangle("fill",0,0,width,60)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(icons.success,20, 5,0,50/icons.success:getWidth(),50/icons.success:getHeight())
		else
			love.graphics.setColor(0.8,0.1,0.1,1)
			love.graphics.rectangle("fill",0,0,width,60)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(icons.trouble,20, 5,0,50/icons.success:getWidth(),50/icons.success:getHeight())
		end
		love.graphics.print(bannerMsg,80,30-fonts.smolpou:getHeight()/2)
	end
	love.graphics.setFont(fonts.def)
	love.graphics.print("1.4.105")
end
