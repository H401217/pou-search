local mod = {}
utf8 = require("utf8")

cursors = {
	hand = love.mouse.getSystemCursor("hand")
}

mod.texts = {
	--test = {v=true,e=true,x=0,y=0,sx=200,sy=50,text="",hold="holder"}
	mail = {v=true,e=true,x=300,y=200,sx=200,sy=50,text="",hold="E-mail",tags={["password"]=1}},
	pass = {v=true,e=true,x=300,y=300,sx=200,sy=50,text="",hold="Password",tags={["password"]=1}},
	sNick = {v=true,e=true,x=130,y=170,sx=200,sy=50,text="",hold="Nickname"},
	sMail = {v=true,e=true,x=130,y=270,sx=200,sy=50,text="",hold="E-Mail"},
	sID = {v=true,e=true,x=130,y=370,sx=200,sy=50,text="",hold="ID"},
}

mod.buttons = {
	--test = {v=true,e=true,x=300,y=20,sx=200,sy=50,func=function(self) print("hay") end}
	login = {v=true,e=true,x=300,y=400,sx=200,sy=50,func=function(self) login(self.texts.mail.text,self.texts.pass.text) end},
	exit = {v=true,e=true,x=30,y=100,sx=40,sy=40,func=function(self) state = "home" end},
	button0 = {v=true,e=true,x=0,y=550,sx=100,sy=50,func=function(self) logout() end},
	button1 = {v=false,e=true,x=110,y=150,sx=100,sy=100,func=function(self) visit() end},
	button2 = {v=false,e=true,x=270,y=150,sx=100,sy=100,func=function(self) visit(_G.Client.randomUser()) end},
	button3 = {v=false,e=true,x=430,y=150,sx=100,sy=100,func=function(self) state = "search" end},
	button4 = {v=false,e=true,x=580,y=150,sx=100,sy=100,func=function(self) updateTop(_G.Client.topLikes()) end},
	like = {v=true,e=true,x=80,y=320,sx=100,sy=100,func=function(self) if account.isFollowing==1 then unlike() else like() end end},
	sNick = {v=true,e=true,x=330,y=170,sx=50,sy=50,func=function(self) visit(_G.Client.getUserByNickname(self.texts.sNick.text)) end},
	sMail = {v=true,e=true,x=330,y=270,sx=50,sy=50,func=function(self) visit(_G.Client.getUserByEmail(self.texts.sMail.text)) end},
	sID = {v=true,e=true,x=330,y=370,sx=50,sy=50,func=function(self) visit(_G.Client.getUserById(self.texts.sID.text)) end},
}

mod.current = "test"

function mod:click(x,y)
	mod.current = ""
	for a,b in pairs(self.texts) do
		if x >= b.x and x <= b.x+b.sx and y >= b.y and y <= b.y+b.sy and b.e == true then
			mod.current = tostring(a)
			love.keyboard.setKeyRepeat(true)
			love.keyboard.setTextInput(true,b.x,b.y,b.sx,b.sy)
			break
		else love.keyboard.setKeyRepeat(false) love.keyboard.setTextInput(false)
		end
	end
	for a,b in pairs(self.buttons) do
		if x >= b.x and x <= b.x+b.sx and y >= b.y and y <= b.y+b.sy and b.e == true then
			sounds.touch:play()
			b.func(self)
		end
	end
end

function mod:press(key)
	if self.texts[self.current] then
		self.texts[self.current].text = self.texts[mod.current].text .. key
	end
end

function mod:keypress(key)
	if love.keyboard.isDown("rctrl","lctrl") and love.keyboard.isDown("v") then
		local text = love.system.getClipboardText()
		print(type(text))
		if type(text) == "string" then
			if self.texts[self.current] then
				self.texts[self.current].text = self.texts[mod.current].text .. text
			end
		end
	end
	if key=="backspace" then
		if self.texts[self.current] then
			-- get the byte offset to the last UTF-8 character in the string.
			local byteoffset = utf8.offset(self.texts[self.current].text, -1)

			if byteoffset then
				-- remove the last UTF-8 character.
				-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
				self.texts[self.current].text = string.sub(self.texts[self.current].text, 1, byteoffset - 1)
			end
		end
	end
end

function mod:update(dt)
	local x,y = love.mouse.getPosition()
	for a,b in pairs(self.buttons) do
		if x >= b.x and x <= b.x+b.sx and y >= b.y and y <= b.y+b.sy and b.e == true then
			love.mouse.setCursor(cursors.hand)
			break
		end
		love.mouse.setCursor()
	end
end

function mod:draw()
	for a,b in pairs(mod.texts) do
		if b.v == true then
			local oldfont = love.graphics.getFont()
			local cFont = love.graphics.newFont(10)
			love.graphics.setFont(cFont)
			love.graphics.rectangle("line",b.x,b.y,b.sx,b.sy)
			local rText = b.text
			if b.tags then if b.tags["password"] == 1 then rText = string.rep("*",utf8.len(rText)) end end
			if string.len(b.text) <= 0 then
				rText = b.hold
			end
			love.graphics.print(rText,b.x+b.sx/2-cFont:getWidth(rText)/2,b.y+b.sy/2-cFont:getHeight()/2)
			love.graphics.setFont(oldfont)
		end
	end
	for a,b in pairs(self.buttons) do
		if b.v == true then
			love.graphics.rectangle("fill",b.x,b.y,b.sx,b.sy)
		end
	end
end

return mod
