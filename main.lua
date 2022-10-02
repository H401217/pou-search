_G.Pou = require("pou")
_G.json = require("json")

function love.load()
	
	icons = {
		lvl = love.graphics.newImage("lvl.png"),
		followers = love.graphics.newImage("followers.png"),
		following = love.graphics.newImage("following.png"),
	}
	
	items = require("items")
	fonts = {
		pou = love.graphics.newFont("pou.ttf",80),
		medpou = love.graphics.newFont("pou.ttf",40),
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
		state = {
			food = 10,
			hp = 100,
			fun = 100,
			sleep = 100,
		},
	}
	function login(e,p)
		local client = _G.Pou.login(e,p)
		local tab = _G.json.decode(client.me)
		if tab.error then
		else
			_G.Client = client
			state = "home"
			account.id = tab.i
			account.name = tab.n
			account.following = tab.nF
			account.followers = tab.nL
			local ext = json.decode(string.sub(tab.state,1,string.len(tab.state)))
			account.last = ext.time
			account.state.food = ext.fullness
			account.state.hp = ext.health
			account.state.fun = ext.fun
			account.state.sleep = ext.energy
			account.lvl = ext.lvl
		end
	end
	
	function like() print(_G.Client.like(account.id)) end
	function unlike() print(_G.Client.unLike(account.id)) end
	function visit(info)
		local tab
		if not info then
			tab = _G.json.decode(_G.Client.me)
		else
			tab = _G.json.decode(info)
			if tab.error then return end
		end
			account.id = tab.i
			account.name = tab.n
			account.following = tab.nF
			account.followers = tab.nL
			local ext = json.decode(string.sub(tab.state,1,string.len(tab.state)))
			account.last = ext.time
			account.state.food = ext.fullness
			account.state.hp = ext.health
			account.state.fun = ext.fun
			account.state.sleep = ext.energy
			account.lvl = ext.lvl
			state = "visit"
	end
end

function love.textinput(txt)
	items:press(txt)
end

function love.mousepressed(x,y)
	items:click(x,y)
end

function love.update(dt)
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
				b.v = true b.e = true
			end
		end
	elseif state == "visit" then
		items.buttons.like.v = true items.buttons.like.e = true
		items.buttons.unlike.v = true items.buttons.unlike.e = true
		items.buttons.exit.v = true items.buttons.exit.e = true
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.3,0.6,1)
	love.graphics.setFont(fonts.pou)
	love.graphics.print("Pou",love.graphics:getWidth()/2-fonts.pou:getWidth("Pou")/2,10)
	if state == "visit" then
		love.graphics.setFont(fonts.medpou)
		love.graphics.rectangle("fill",80,190,100,100) --pou icon
		love.graphics.print(account.name,200,190)
		
		love.graphics.draw(icons.following,100,400,0,100/icons.following:getWidth(),100/icons.following:getHeight())
		love.graphics.print(account.following,220,450-fonts.medpou:getHeight()/2)
		
		love.graphics.draw(icons.followers,450,400,0,100/icons.followers:getWidth(),100/icons.followers:getHeight())
		love.graphics.print(account.followers,570,450-fonts.medpou:getHeight()/2)
		
		love.graphics.setFont(fonts.def)
		love.graphics.print("ID: "..account.id,200,230)
		love.graphics.print(os.date("Last time saved: %x %X",account.last),200,250)
		love.graphics.setColor(0,1,0,1)
		love.graphics.rectangle("fill",500,240-account.state.food/2,50,account.state.food/2)
		love.graphics.rectangle("fill",550,240-account.state.hp/2,50,account.state.hp/2)
		love.graphics.rectangle("fill",600,240-account.state.fun/2,50,account.state.fun/2)
		love.graphics.rectangle("fill",650,240-account.state.sleep/2,50,account.state.sleep/2)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("line",500,190,50,50)
		love.graphics.rectangle("line",550,190,50,50)
		love.graphics.rectangle("line",600,190,50,50)
		love.graphics.rectangle("line",650,190,50,50)
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(icons.lvl,500,260,0,60/icons.lvl:getWidth(),55/icons.lvl:getHeight())
		love.graphics.setColor(0,0,0,1)
		love.graphics.print(account.lvl,530-fonts.def:getWidth(account.lvl)/2,287.5-fonts.def:getHeight()/2)
	end
	love.graphics.setColor(1,1,1,1)
	items:draw()
	love.graphics.setFont(fonts.def)
end