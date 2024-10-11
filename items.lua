local mod = {}
utf8 = require("utf8")

cursors = {
	hand = love.mouse.getSystemCursor("hand")
}

mod.texts = {
	--test = {v=true,e=true,x=0,y=0,sx=200,sy=50,text="",hold="holder"}
	mail = {v=true,e=true,x=300,y=200,sx=200,sy=50,text="",hold="E-mail",tags={["mail"]=1}},
	pass = {v=true,e=true,x=300,y=300,sx=200,sy=50,text="",hold="Password",tags={["password"]=1}},
	sNick = {v=true,e=true,x=130,y=170,sx=200,sy=50,text="",hold="Nickname"},
	sMail = {v=true,e=true,x=130,y=270,sx=200,sy=50,text="",hold="E-Mail",tags={["mail"]=1}},
	sID = {v=true,e=true,x=130,y=370,sx=200,sy=50,text="",hold="ID",tags={["num"]=1}},
	host = {v=true,e=true,x=400,y=370,sx=250,sy=30,text="http://app.pou.me/",hold="New Host URL"},
	newNick = {v=true,e=true,x=130,y=120,sx=200,sy=30,text="",hold="New Nickname"},
	newMail = {v=true,e=true,x=130,y=185,sx=200,sy=30,text="",hold="New Email",tags={["mail"]=1}},
	oldPass = {v=true,e=true,x=130,y=250,sx=200,sy=30,text="",hold="Old Password",tags={["password"]=1}},
	newPass = {v=true,e=true,x=130,y=280,sx=200,sy=30,text="",hold="New Password"},
}

mod.buttons = {
	--test = {v=true,e=true,x=300,y=20,sx=200,sy=50,func=function(self) print("hay") end}
	login = {v=true,e=true,x=300,y=400,sx=200,sy=50,func=function(self) login(self.texts.mail.text,self.texts.pass.text) end},
	exit = {v=true,e=true,x=30,y=100,sx=40,sy=40,func=function(self) if configchanged==true then relogin() configchanged=false end if state == "guestbook" or state == "usermenu" or state == "guestsend" or state == "usermenu" then state = "visit" elseif state == "userlist" then state = "usermenu" elseif state == "topscores" then state="topgame" elseif state == "livestats" then love.thread.getChannel("tolikeupdate"):push("close") state="usermenu" else state = "home" substate = "" end end, img="assets/icons/home.png"},
	button = {v=true,e=true,x=515,y=555,sx=40,sy=40,func=function(self) relogin() end, img="assets/icons/refresh.png"}, --refresh
	button0 = {v=true,e=true,x=0,y=550,sx=100,sy=50,func=function(self) if _G.Client.type == "guest" then state = "login" else logout() end end},
	button1 = {v=false,e=true,x=110,y=150,sx=100,sy=100,func=function(self) visit() end, img="assets/icons/button1.png",hint="Bmypou"},
	button2 = {v=false,e=true,x=270,y=150,sx=100,sy=100,func=function(self) if _G.Client.type == "guest" then state = "login" else visit(_G.Client.randomUser()) end end, img="assets/icons/button2.png",hint="Brandompou"},
	button3 = {v=false,e=true,x=430,y=150,sx=100,sy=100,func=function(self) if _G.Client.type == "guest" then state = "login" else state = "search" end end, img="assets/icons/button3.png",hint="Bsearch"},
	button4 = {v=false,e=true,x=580,y=150,sx=100,sy=100,func=function(self) substate = "page1" updateTop(_G.Client.topLikes()) end, img="assets/icons/button4.png",hint="Btoplikes"},
	button5 = {v=false,e=true,x=580,y=310,sx=100,sy=100,func=function(self) state = "conf" end, img="assets/icons/button5.png",hint="Bsettings"},
	button6 = {v=false,e=true,x=110,y=310,sx=100,sy=100,func=function(self) state = "topgame" end, img="assets/icons/button6.png",hint="Btopgames"},
	button7 = {v=false,e=true,x=270,y=310,sx=100,sy=100,func=function(self) if _G.Client.type == "guest" then state = "login" else state = "tictaclobby" substate="page1" updateGame(_G.Client.getGameSessions(drawPou.toTable(_G.Client.me).i,8,1,100)) end end, img="assets/icons/button7.png",hint="Btictac"},
	button8 = {v=false,e=true,x=430,y=310,sx=100,sy=100,func=function(self) if _G.Client.type == "guest" then state = "login" else state = "tictaclobby" substate="page1" updateGame(_G.Client.getGameSessions(drawPou.toTable(_G.Client.me).i,9,1,100)) end end, img="assets/icons/button8.png",hint="Bfourpous"},
	zakehweb = {v=false,e=true,x=750,y=550,sx=50,sy=50,func=function(self) love.system.openURL(server.links.web) end, img="assets/icons/zakeh.png",hint="Bweb"},
	instagram = {v=false,e=true,x=690,y=550,sx=50,sy=50,func=function(self) love.system.openURL("https://www.instagram.com/"..server.links.instagram) end, img="assets/icons/insta.png",hint="Binsta"},
	facebook = {v=false,e=true,x=630,y=550,sx=50,sy=50,func=function(self) love.system.openURL("https://www.facebook.com/"..server.links.facebook) end, img="assets/icons/fb.png",hint="Bfaceb"},
	twitter = {v=false,e=true,x=570,y=550,sx=50,sy=50,func=function(self) love.system.openURL("https://www.twitter.com/"..server.links.twitter) end, img="assets/icons/twitter.png",hint="Btwit"},
	like = {v=true,e=true,x=80,y=320,sx=100,sy=100,func=function(self) if account.isFollowing==1 then unlike() else like() end end},
	usermenu = {v=true,e=true,x=575,y=262.5,sx=50,sy=50,func=function(self) state = "usermenu" end, img="assets/icons/menu.png"},
	likes = {v=true,e=true,x=270,y=150,sx=100,sy=100,func=function(self) updateTop(_G.Client.getLikers(account.id,0),"userlist") end, img="assets/icons/likes_button.png",hint="Bfollowers"},
	follows = {v=true,e=true,x=110,y=150,sx=100,sy=100,func=function(self) updateTop(_G.Client.getFavorites(account.id,0),"userlist") end, img="assets/icons/follows_button.png",hint="Bfollowing"},
	visitors = {v=true,e=true,x=430,y=150,sx=100,sy=100,func=function(self) updateTop(_G.Client.getVisitors(account.id,0),"userlist") end, img="assets/icons/visits_button.png",hint="Bvisits"},
	states = {v=true,e=true,x=580,y=150,sx=100,sy=100,func=function(self) love.window.showMessageBox("",string.format(translate:Get("stats"),(account.stats.nEF or 0),(account.stats.cS or 0)+(account.stats.cW or 0),(account.stats.hFP or 0),(account.stats.eFS or 0),(account.stats.eFP or 0),(account.stats.wF or 0),(account.stats.wFF or 0)),"info") end,img="assets/icons/stats_button.png",hint="userstatus"},
	livestats = {v=true,e=true,x=110,y=310,sx=100,sy=100,func=function(self) state = "livestats" _G.Pou.startLive(account.name) end,img="assets/icons/live_button.png",hint="Blivestats"},
	guestbook = {v=true,e=true,x=650,y=262.5,sx=50,sy=50,func=function(self) getMsgs(account.id) end, img="assets/icons/guestbook.png"},
	gbmenu = {v=false,e=true,x=90,y=83,sx=620,sy=42,func=function(self) state = "guestsend" substate="page1" end},
	sNick = {v=true,e=true,x=330,y=170,sx=50,sy=50,func=function(self) visit(_G.Client.getUserByNickname(self.texts.sNick.text)) end,img="assets/icons/search.png"},
	miniNick = {v=true,e=true,x=380,y=170,sx=50,sy=50,func=function(self) visit(_G.Client.getAvatarByNickname(self.texts.sNick.text),true) end,hint="searchmini",img="assets/icons/search_fast.png"},
	sMail = {v=true,e=true,x=330,y=270,sx=50,sy=50,func=function(self) visit(_G.Client.getUserByEmail(self.texts.sMail.text)) end,img="assets/icons/search.png"},
	miniMail = {v=true,e=true,x=380,y=270,sx=50,sy=50,func=function(self) visit(_G.Client.getAvatarByEmail(self.texts.sMail.text),true) end,hint="searchmini",img="assets/icons/search_fast.png"},
	sID = {v=true,e=true,x=330,y=370,sx=50,sy=50,func=function(self) visit(_G.Client.getUserById(self.texts.sID.text)) end,img="assets/icons/search.png"},
	right = {v=true,e=true,x=730,y=290,sx=40,sy=40,func=function(self) local _,__ = string.gsub(substate,"page","") substate="page".. (tonumber(_) or 1)+1 drawPous() end, img="assets/icons/next.png"},
	left = {v=true,e=true,x=30,y=290,sx=40,sy=40,func=function(self) local _,__ = string.gsub(substate,"page","") substate="page".. (tonumber(_) or 1)-1 drawPous() end, img="assets/icons/prev.png"},
	conf1 = {v=true,e=true,x=650,y=370,sx=30,sy=30,func=function(self) changeHost(self.texts.host.text) end}, --change host
	conf2 = {v=true,e=true,x=330,y=120,sx=30,sy=30,func=function(self) userChange("name",self.texts.newNick.text) end}, --change name
	conf4 = {v=true,e=true,x=330,y=185,sx=30,sy=30,func=function(self) userChange("mail",self.texts.newMail.text) end}, --change mail
	conf5 = {v=true,e=true,x=330,y=280,sx=30,sy=30,func=function(self) userChange("pass",self.texts.oldPass.text,self.texts.newPass.text) end}, --change pass
	conf6 = {v=true,e=true,x=330,y=490,sx=30,sy=30,func=function(self) translate:Next() end}, --next lang
	conf7 = {v=true,e=true,x=130,y=490,sx=30,sy=30,func=function(self) translate:Prev() end}, --prev lang
	about = {v=false,e=true,x=450,y=475,sx=180,sy=60,func=function(self) state = "about" end, img="assets/icons/about.png"}, --about
	git = {v=true,e=true,x=610,y=150,sx=50,sy=50,func=function(self) love.system.openURL("https://www.github.com/h401217/pou-search") end, img="assets/icons/github.png",hint="Bgit"}, --git
	gday1 = {v=false,e=true,x=124,y=90,sx=138,sy=30,func=function(self) extra.options.gtopday = "today" end},
	gday2 = {v=false,e=true,x=262,y=90,sx=138,sy=30,func=function(self) extra.options.gtopday = "week" end},
	gday3 = {v=false,e=true,x=400,y=90,sx=138,sy=30,func=function(self) extra.options.gtopday = "month" end},
	gday4 = {v=false,e=true,x=538,y=90,sx=138,sy=30,func=function(self) extra.options.gtopday = "alltime" end},
}

--
	for c=0,4 do
		for d=0,1 do
			local position = ((d+1)+(2*c))
			mod.buttons["pou_user"..position] = {v=false,e=true,x=90+330*d,y=130+90*c,sx=290,sy=80,func=function(self) clickuser(position) end}
		end
	end
	for d=0,4 do
		for c=0,6 do
			local position = (c+1)+(7*d)
			mod.buttons["pou_game"..position] = {v=false,e=true,x=85+90*c,y=130+90*d,sx=90,sy=90,func=function(self) clickgame(position) end, hint=extra.games[position]}
		end
	end
--

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
	local mX,mY = love.mouse.getPosition()
	local oldfont = love.graphics.getFont()
	local cFont = love.graphics.newFont(10)
	local dFont = love.graphics.newFont(12)
	for a,b in pairs(mod.texts) do
		if b.v == true then
			love.graphics.setFont(cFont)
			local rText = b.text
			if b.tags then if b.tags["password"] == 1 then rText = string.rep("*",utf8.len(rText)) end end
			if string.len(b.text) <= 0 then
				rText = b.hold
			end
			love.graphics.print(rText,b.x+b.sx/2-cFont:getWidth(rText)/2,b.y+b.sy/2-cFont:getHeight()/2)
			local err = ""
			if b.tags and a == self.current and #b.text >0 then
				if b.tags["num"] then
					if not tonumber(b.text) then
						err = "Invalid number!"
					end
				elseif b.tags["mail"] then
					if not b.text:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") then
						err = "Invalid email!"
					end
				end
			end
			
			if #err>0 then love.graphics.setColor(1,0.5,0,1) end
			love.graphics.print(err,b.x,b.y+b.sy+2)
			love.graphics.rectangle("line",b.x,b.y,b.sx,b.sy)
			
			love.graphics.setColor(1,1,1,1)
		end
	end
	for a,b in pairs(self.buttons) do
		if b.v == true then
			if b.img then
				local img,_ = extra.imgs[b.img]
				love.graphics.draw(img,b.x,b.y,0,b.sx/img:getWidth(),b.sy/img:getHeight())
				if _ then img:release() end
			else
				love.graphics.rectangle("fill",b.x,b.y,b.sx,b.sy)
			end
		end
		if b.e == true then
			if b.hint then
				if mX >= b.x and mX <= b.x+b.sx and mY >= b.y and mY <= b.y+b.sy and b.e == true then
					love.graphics.setFont(dFont)
					local txt = translate:Get(b.hint)
					local lines = (select(2,string.gsub(txt,"\n","")) or 0)+1
					local off = 5
					local w = dFont:getWidth(txt)+(off*2)
					local h = dFont:getHeight(txt)+(off*2)
					local offx = (mX+w > 800) and (mX+w-800) or 0
					
					love.graphics.setColor(0.92,0.85,0.3,1) love.graphics.rectangle("fill",mX-offx,mY-h,w,h)
					love.graphics.setColor(0.9,0.6,0.07,1) love.graphics.rectangle("line",mX-offx,mY-h,w,h)
					love.graphics.setColor(0,0,0,1) love.graphics.print(txt,(mX+((w/2))-dFont:getWidth(txt)/2)-offx,(mY-(h/2))-dFont:getHeight(txt)/2)
					love.graphics.setColor(1,1,1,1)
				end
			end
		end
	end
	love.graphics.setColor(1,1,1,1)
	love.graphics.setFont(oldfont)
end

return mod