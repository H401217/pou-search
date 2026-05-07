-- Draw Pou Items v0
--[[
	data = {
		size = 0 (0 to 1)
		color = {r=0,g=0,b=0}
	}
]]
local json = require("json")
local draw = {}

function draw.threetoquad(x1,y1, x0,y0, x4,y4)
	print(x1,y1,x0,y0,x4,y4)
	--0 is control middle
	x2 = x1+(x0-x1)*(2/3)
	y2 = y1+(y0-y1)*(2/3)

	x3 = x4-(x4-x0)*(2/3)
	y3 = y4-(y4-y0)*(2/3)

	return {x1,y1,x2,y2,x3,y3,x4,y4}
end

function draw.fixJSON(nw)
	local _t1 = 0
	while 1 do
		local a = math.min( (string.find(nw,":",_t1) or 1234567890), (string.find(nw,'%[',_t1) or 1234567890), (string.find(nw,"{",_t1) or 1234567890))
		if a then
			if a ==1234567890 then return nw end
			_t1=a+1
			local b = string.sub(nw,a+1,a+1)
			if (b == [[\]]) or (b == '{') or (b == '[') or (b == '"') then
			else
				local a1 = string.sub(nw,0,a)
				local a2 = string.sub(nw,a+1,#nw)
				local c1 = string.find(a2,",") or 1234567890
				local c2 = string.find(a2,"}") or 1234567890
				local c3 = string.find(a2,"]") or 1234567890
				local c = math.min(c1,c2,c3)
				local a3 = string.sub(a2,c,#nw)
				a2 = string.sub(a2,0,c-1)
				if a2 == "true" or a2 == "false" or a2 == "null" or tonumber(a2) then
				else
					nw = a1..'"'..a2..'"'..a3
				end
			end
		else break
		end
	end
	return nw
end

function draw.toTable(ft)
	
	local s,tab1 = pcall(function() return json.decode(ft) end)
	if not s then tab1 = json.decode(draw.fixJSON(ft)) end
	local function dec(t)
		for a,b in pairs(t) do
			if type(b) == "string" then
				if string.sub(b,1,1) == "{" or string.sub(b,1,1) == "[" then
					local _as,_22 = pcall(function() return json.decode(b) end)
					if not _as then _22 = json.decode(draw.fixJSON(b)) end
					--t[a] = json.decode(t[a]) --string.sub(b,1,string.len(b))
					--t[a] = dec(t[a])
					t[a]=dec(_22)
				end
			end
		end
		return t
	end
	return dec(tab1)
end

local colors = {
	bodycolors = {["1"]={r=214,g=162,b=89}, ["2"]={r=65,g=125,b=255}, ["3"]={r=255,g=89,b=89}, ["4"]={r=255,g=154,b=47}, ["5"]={r=255,g=255,b=65}, ["6"]={r=65,g=255,b=65}, ["7"]={r=255,g=89,b=147}, ["8"]={r=255,g=255,b=255}, ["12"]={r=58,g=255,b=189}, ["10"]={r=255,g=129,b=81}, ["11"]={r=181,g=206,b=25}, ["9"]={r=148,g=89,b=255}, ["13"]={r=229,g=190,b=25}, ["14"]={r=182,g=182,b=182}, ["15"]={r=30,g=30,b=30}, ["16"]={r=255,g=89,b=197}, ["17"]={r=241,g=89,b=255}, ["18"]={r=197,g=87,b=255}, ["19"]={r=57,g=255,b=255}, ["20"]={r=65,g=190,b=255}, ["21"]={r=255,g=130,b=148}, ["22"]={r=182,g=255,b=23},},
	eyecolors = {["1"]={r=0,g=0,b=0},["2"]={r=145,g=112,b=67},["3"]={r=54,g=180,b=44},["4"]={r=200,g=160,b=0},["5"]={r=145,g=145,b=145},["6"]={r=88,g=191,b=219},["7"]={r=228,g=145,b=29},["8"]={r=156,g=98,b=215},["9"]={r=255,g=101,b=255},["10"]={r=224,g=0,b=0},["11"]={r=15,g=210,b=170}},
}


function draw.toCol(tn,c)
	local t = colors[tn][tostring(c)]
	if t then return t else return colors[tn]["1"] end
end
--450 = excited
function draw:toDrawer(tab)
	local ret = {color=1,sz=0.5,emote="happy"}
	if tab.energy then
		local emo = extra.status_calc(tab.fullness or 0,tab.health or 0,tab.fun or 0,tab.energy or 0)
		if emo < 200 then
			ret.emote = "sad"
		elseif emo < 300 then
			ret.emote = "neutral"
		elseif emo < 450 then
			ret.emote = "happy"
		else
			ret.emote = "veryhappy"
		end
	end
	if tab.sz then
		ret.color = tab.bCo or 1
		ret.ecolor = tab.eCo or 1
		ret.sz = tab.sz or 0.5
	elseif tab.size then
		ret.color = tab.bodyColors.a or 1
		ret.ecolor = ((tab["eyeColors"] or {})["a"]) or 1
		ret.sz = tab.size or 0.5
	else
		return ret
	end
	
	--fixing
	ret.sz = extra.fixNum(ret.sz,0.5,1)
	
	return ret
end

function draw:floodfill(canvas,x,y,col)
	--if true then return false end
	love.graphics.setCanvas()
	local imgdata = canvas:newImageData()
	love.graphics.setCanvas(canvas)
	local oR,oG,oB,oA = imgdata:getPixel(x,y)
	local remainingPixels = {}

	local function paint(xx,yy)
		--print(xx,yy)
		if xx<0 or xx>1000 or yy<0 or yy>1000 then return end
		local r,g,b,a = imgdata:getPixel(xx,yy)
		if r==col.r and g == col.g and b == col.b then
			return
		else
			local rr = r-oR
			local gg = g-oG
			local bb = b-oB
			local aa = a-oA
			local color = (rr+gg+bb+aa)/4
			local fcol = (-0.5+(rr+gg+bb))*(color*5)
			if (color < 0.15 and color > -0.15) or (r==oR and g==oG and b == oB and a == oA) then
				imgdata:setPixel(xx,yy,col.r+fcol,col.g+fcol,col.b+fcol,1)
				--[[paint(xx+1,yy)
				paint(xx-1,yy)
				paint(xx,yy+1)
				paint(xx,yy-1)]]
				table.insert(remainingPixels,{x=xx,y=yy})
			end
		end
	end
	paint(x,y)
	while #remainingPixels>0 do
		local v = remainingPixels[1]
		paint(v.x+1,v.y)
		paint(v.x+-1,v.y)
		paint(v.x,v.y+1)
		paint(v.x,v.y-1)
		table.remove(remainingPixels,1)
	end
	local img = love.graphics.newImage(imgdata)
	love.graphics.clear()
	canvas:renderTo(function() love.graphics.draw(img) end)
	imgdata:release()
	img:release()
	imgdata:release()
end

function draw.emotion(emotion,size,pouSize,value1)
	local c = size/480
	local pouSize = pouSize
	--local g,h, i,j, m,n, k,l
	local o,p, q,r, u,v, s,t
	if emotion == "veryhappy" then
		o=-45*c
		p=-10*c
		q,r,s=0,-10*c,0
		t=45*c
		u=45*c
		v=-10*c
		--x=5
	elseif emotion == "happy" then
		o=-75*pouSize*c
		p=-30*pouSize*c
		q=-90*pouSize*c
		r=22.5*pouSize*c
		s=-90*pouSize*c
		t=22.5*pouSize*c
		u=-45*pouSize*c
		v=7.5*pouSize*c
	elseif emotion == "neutral" then
		o = -15*c
		p,q,r,s,t = 0,0,0,0,0
		u,v = 15*c,15*c
		--x = 5
	elseif emotion == "sad" then
		o=-15*c
		p,q=0,0
		r=-22.5*c
		s=0
		t=-22.5*c
		u=15*c
		v=0
	elseif emotion == "talking" then
		o=c*-(value1*40+20)
		p,q=0,0
		r=-(20*value1+15)*c
		s=0
		t=(55*value1+40)*c
		u=-(o)
		v=0
	--elseif emotion == "veryhappy" then

	elseif emotion == "yawn" then
		o=-45*c
		p=45*c
		q=0
		r=-90*c
		s=0
		t=90*c
		u=45*c
		v=45*c
	elseif emotion == "wannaeat" then
		o=-67.5*pouSize*c
		p=40*c
		q=0
		r=-75*c
		s=0
		t=120*pouSize*c
		u=67.5*pouSize*c
		v=30*c
		--x=5
	elseif emotion == "no" then
		o=-15*c
		p,q=0,0
		r=-22.5*c
		s=0
		t=-22.5*c
		u=15*c
		v=0
		--x=5
	elseif emotion == "eating" then
		o=-30*c
		p=0
		q=0
		r=-15*c
		s=0
		t=90*c
		u=30*c
		v=0
		--x=5
	elseif emotion == "excited" then --rie o sed
		o=c*-(30*pouSize+30)
		p=0
		q=0
		r=-(15*pouSize+30)*c
		s=0
		t=(pouSize*35+70)*c
		u=-o
		v=0
		--x=10
	end
	return o,p,q,r,u,v,s,t
end

function draw:drawPou(c,data)
	local datos = {
		relative = c:getWidth()+100,
		breath = 0,
		fat = 0,
		scale = data.sz or 1,
		lookX = 0,
		lookY = 0,
	}

	local centerX = c:getWidth()/2
	local centerY = c:getHeight()/2

	print("drawingpou")
	love.graphics.setCanvas(c)
	local success,_r = pcall(function()
		local cl = self.toCol("bodycolors",data.color)
		local ecl = self.toCol("eyecolors",data.ecolor)
		local Pousize = datos.scale
		
		love.graphics.clear()
		love.graphics.rectangle("line",0,0,centerX*2,centerY*2)
		--	body color
		love.graphics.push()
		--love.graphics.scale(Pousize)
		love.graphics.setColor(0,0,0,1)
		love.graphics.setLineWidth(3)
		love.graphics.translate(centerX,centerY)
		local p1,p2,p3,p4,p5,p6 = 0,(datos.relative/480)*150*datos.scale, (-(datos.relative/480)*225*datos.scale-datos.breath)-datos.fat*(datos.relative/480),(datos.relative/480)*150*datos.scale  ,-(datos.relative/480)*150*datos.scale,0
		local b1 = love.math.newBezierCurve(self.threetoquad(p1,p2,p3,p4,p5,p6))
		love.graphics.line(b1:render())
		local p1,p2,p3,p4,p5,p6 = -(datos.relative/480)*150*datos.scale,0, datos.lookX,-300*datos.scale*datos.relative/480+datos.lookY, (datos.relative/480)*150*datos.scale,0
		local b2 = love.math.newBezierCurve(self.threetoquad(p1,p2,p3,p4,p5,p6))
		local p1,p2,p3,p4,p5,p6 = (datos.relative/480)*150*datos.scale,0, (datos.relative/480)*225*datos.scale+datos.breath+datos.fat,(datos.relative/480)*150*datos.scale, 0,(datos.relative/480)*150*datos.scale
		local b3 = love.math.newBezierCurve(self.threetoquad(p1,p2,p3,p4,p5,p6))
		love.graphics.line(b2:render())
		love.graphics.line(b3:render())
		print(cl.r)
		love.graphics.pop()
		love.graphics.setColor(1,1,1,1)
		--love.graphics.translate(-62.5,-62.5)
		love.graphics.origin()
		self:floodfill(c,centerX,centerY,{r=cl.r/255,g=cl.g/255,b=cl.b/255,a=1})

		love.graphics.push()
		love.graphics.translate(centerX,centerY)
		local talkfactor = data.talk or 0
		local p1,p2,p3,p4,p5,p6,p7,p8 = self.emotion(data.emote or "happy",datos.relative,datos.scale,talkfactor)
		local b1 = love.math.newBezierCurve(self.threetoquad(p1,p2,p3,p4,p5,p6))
		local b2 = love.math.newBezierCurve(self.threetoquad(p5,p6,p7,p8,p1,p2))
		love.graphics.setColor(0,0,0,1)
		love.graphics.setLineWidth(1)
		love.graphics.line(b1:render())
		love.graphics.line(b2:render())
		love.graphics.pop()
		love.graphics.origin()
		local bez1x,bez1y = b1:evaluate(0.5)
		local bez2x,bez2y = b2:evaluate(0.5)
		local bez3x,bez3y = (bez1x+bez2x)/2,(bez1y+bez2y)/2
		--print("caca",bez3x+centerX/Pousize,bez3y)
		love.graphics.setColor(1,1,1,1)
		self:floodfill(c,bez3x+centerX,bez3y+centerY,{r=123/255,g=36/255,b=24/255,a=1})
		love.graphics.push()
		love.graphics.translate(centerX,centerY)
		love.graphics.setLineWidth(3)
		love.graphics.setColor(0,0,0,1)
		love.graphics.line(b1:render())
		love.graphics.line(b2:render())
		love.graphics.pop()
		love.graphics.setColor(1,1,1,1)
		
		--[[
		local m = 0.3+0.7*((data.sz-0.5)*2)
		local b1 = love.math.newBezierCurve({20+105-105*m,180-60+60*m, 120,0+110-110*m, 180,0+110-110*m, 280-105+105*m,180-60+60*m})
		love.graphics.line(b1:render())

		local b2 = love.math.newBezierCurve({280-105+105*m,180-60+60*m, 295-105+105*m,240-90+90*m, 295-105+105*m,290-90+90*m, 150,295-105+105*m})
		love.graphics.line(b2:render())

		local b3 = love.math.newBezierCurve({20+105-105*m,180-60+60*m, 5+105-105*m,240-90+90*m, 5+105-105*m,290-90+90*m, 150,295-105+105*m})
		love.graphics.line(b3:render())
		local l1=240-90+90*m
		love.graphics.setColor(1,1,1,1)
		--self:floodfill(c,150,l1,{r=cl.r/255,g=cl.g/255,b=cl.b/255,a=1})
		love.graphics.ellipse("fill",173,108,23,27)
		love.graphics.ellipse("fill",127,108,23,27)
		love.graphics.setColor(0,0,0,1)
		love.graphics.ellipse("line",173,108,23,27)
		love.graphics.ellipse("line",127,108,23,27)
		love.graphics.setColor(ecl.r/255,ecl.g/255,ecl.b/255,1)
		love.graphics.ellipse("fill",173,108,8.4,8.5)
		love.graphics.ellipse("fill",127,108,8.4,8.5)
		love.graphics.setColor(0,0,0,1)
		local mo
		if data.emote == "happy" then
			mo = love.math.newBezierCurve({105+21-21*m,150, 90+21-21*m,180-15+15*m, 111+21-21*m,189-18+18*m, 126+9-9*m,174-6+6*m})
		elseif data.emote == "neutral" then
			mo = love.math.newBezierCurve({132,165, 142,165, 160,165, 168,165})
		else
			mo = love.math.newBezierCurve({138,180, 145,159, 154,159, 162,180})
		end
		love.graphics.line(mo:render())]]
	end)
	love.graphics.setColor(1,1,1,1)
	if not success then
		print(_r)
		love.graphics.clear()
		love.graphics.draw(icons.missingpou,0,0,0,100/icons.missingpou:getWidth(),100/icons.missingpou:getHeight())
	end
	love.graphics.setCanvas()
	love.graphics.setLineWidth(1)
end

function draw:drawGame(c,data,myID)
	--500x500
	if type(data) ~= "table" then data = {} end
	love.graphics.setCanvas(c)
	love.graphics.clear()
	myID = tostring(myID)
	data.nC = tonumber(data.nC) or 1
	data.nR = tonumber(data.nR) or 1
	local divx = 500/data.nC
	local divy = 500/data.nR
	local board = {}
	local _temp = data.pI or "0"
	repeat
		table.insert(board,string.sub(_temp,0,data.nC))
		_temp = string.sub(_temp,data.nC+1,999)
	until #_temp < data.nC
	for i,v in pairs(board) do
		board[i] = {}
		for h = 1, #v do
			local ss = string.sub(v,h,h)
			table.insert(board[i],ss)
		end
	end
	--i realize i am making the script too big
	love.graphics.setLineWidth(10)
	for c= 1,data.nR do
		for d = 1,data.nC do
			local sqr = board[c][d]
			if sqr == "0" then
				love.graphics.setColor(1,1,1,1) --no one
			elseif sqr == myID then
				love.graphics.setColor(0.3,0.7,1,1) --you
			else
				love.graphics.setColor(1,0.32,0.3,1) --opponent
			end
			love.graphics.rectangle("fill",divx*(d-1),divy*(c-1),divx,divy)
			love.graphics.setColor(0,0,0,1)
			love.graphics.rectangle("line",divx*(d-1),divy*(c-1),divx,divy)
		end
	end
	love.graphics.setLineWidth(1)
	love.graphics.setColor(1,1,1,1)
	love.graphics.setCanvas()
end
return draw