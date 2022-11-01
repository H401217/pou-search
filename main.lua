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
	
	icons = {
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
		b0 = love.graphics.newImage("assets/icons/button0.png"),
		b1 = love.graphics.newImage("assets/icons/button1.png"),
		b2 = love.graphics.newImage("assets/icons/button2.png"),
		b3 = love.graphics.newImage("assets/icons/button3.png"),
		b4 = love.graphics.newImage("assets/icons/button4.png"),
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
	state = "login"
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
		if client == "no-connection" then badState("No Internet Connection") return false end
		local tab = drawPou.toTable(client.me)
		if tab.error then
			badState(tab.error.message)
			return false
		else
			if not isdata then
				love.filesystem.write("poulogin",e.."¬"..p)
			end
			_G.Client = client
			state = "home"
			updateUser(tab)
			return true
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
	function logout()
		local s = _G.Client.logOut()
		if s then
			goodState("Success!")
			love.filesystem.write("poulogin","")
			_G.Client = nil
			items.texts.mail.text = ""
			items.texts.pass.text = ""
			state = "login"
		end
	end
	local c,s = love.filesystem.read("poulogin")
	if c then
		local find = string.find(c,"¬") or 0
		local mail = string.sub(c,0,find-1)
		local pass = string.sub(c,find+2,1000)
		local sus = login(mail,pass,true)
	end
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
	elseif state == "home" then
		for a,b in pairs(items.buttons) do
			if string.match(a,"button") then
				b.e = true
			end
		end
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
	elseif state == "top" then
		items.buttons.exit.v = false items.buttons.exit.e = true
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.3,0.6,1)
	love.graphics.setFont(fonts.pou)
	love.graphics.print("Pou",love.graphics:getWidth()/2-fonts.pou:getWidth("Pou")/2,10)
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
		love.graphics.draw(icons.b0,items.buttons.button0.x,items.buttons.button0.y,0,items.buttons.button0.sx/icons.b0:getWidth(),items.buttons.button0.sy/icons.b0:getHeight())
		love.graphics.draw(icons.b1,items.buttons.button1.x,items.buttons.button1.y,0,items.buttons.button1.sx/icons.b1:getWidth(),items.buttons.button1.sy/icons.b1:getHeight())
		love.graphics.draw(icons.b2,items.buttons.button2.x,items.buttons.button2.y,0,items.buttons.button2.sx/icons.b2:getWidth(),items.buttons.button2.sy/icons.b2:getHeight())
		love.graphics.draw(icons.b3,items.buttons.button3.x,items.buttons.button3.y,0,items.buttons.button2.sx/icons.b3:getWidth(),items.buttons.button3.sy/icons.b3:getHeight())
		love.graphics.draw(icons.b4,items.buttons.button4.x,items.buttons.button4.y,0,items.buttons.button2.sx/icons.b4:getWidth(),items.buttons.button4.sy/icons.b4:getHeight())
	elseif state == "search" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
	elseif state == "top" then
		love.graphics.draw(icons.home,items.buttons.exit.x,items.buttons.exit.y,0,items.buttons.exit.sx/icons.home:getWidth(),items.buttons.exit.sy/icons.home:getHeight())
		love.graphics.setFont(fonts.smolpou)
		love.graphics.print(ttl1..ttl2,200,150)
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
