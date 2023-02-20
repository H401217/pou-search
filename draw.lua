-- Draw Pou Items v0
--[[
	data = {
		size = 0 (0 to 1)
		color = {r=0,g=0,b=0}
	}
]]
local json = require("json")
local draw = {}

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

function draw:toDrawer(tab)
	local ret = {color=1,sz=0.5,emote="happy"}
	if tab.energy then
		local emo = extra.status_calc(tab.fullness or 0,tab.health or 0,tab.fun or 0,tab.energy or 0)
		if emo < 200 then
			ret.emote = "sad"
		elseif emo < 300 then
			ret.emote = "neutral"
		else
			ret.emote = "happy"
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
	love.graphics.setCanvas()
	local imgdata = canvas:newImageData()
	love.graphics.setCanvas(canvas)
	local oR,oG,oB,oA = imgdata:getPixel(x,y)
	local function paint(xx,yy)
		local r,g,b,a = imgdata:getPixel(xx,yy)
		if r==col.r and g == col.g and b == col.b then
			
		else
			local rr = r-oR
			local gg = g-oG
			local bb = b-oB
			local aa = a-oA
			local color = (rr+gg+bb+aa)/4
			local fcol = (-0.5+(rr+gg+bb))*(color*5)
			if (color < 0.15 and color > -0.15) or (r==oR and g==oG and b == oB and a == oA) then
				imgdata:setPixel(xx,yy,col.r+fcol,col.g+fcol,col.b+fcol,1)
				paint(xx+1,yy)
				paint(xx-1,yy)
				paint(xx,yy+1)
				paint(xx,yy-1)
			end
		end
	end
	paint(x,y)
	local img = love.graphics.newImage(imgdata)
	love.graphics.clear()
	canvas:renderTo(function() love.graphics.draw(img) end)
	imgdata:release()
	img:release()
	imgdata:release()
end

function draw:drawPou(c,data)
	love.graphics.setCanvas(c)
	local success,_r = pcall(function()
	local cl = self.toCol("bodycolors",data.color)
	local ecl = self.toCol("eyecolors",data.ecolor)
	love.graphics.clear()
	love.graphics.setColor(0,0,0,1)
	
	local m = 0.3+0.7*((data.sz-0.5)*2)
	local b1 = love.math.newBezierCurve({10+35-35*m,60-20+20*m, 40,0+40-40*m, 60,0+40-40*m, 90-35+35*m,60-20+20*m})
	love.graphics.line(b1:render())

	local b2 = love.math.newBezierCurve({90-35+35*m,60-20+20*m, 95-35+35*m,80-30+30*m, 95-35+35*m,90-30+30*m, 50,95-35+35*m})
	love.graphics.line(b2:render())

	local b3 = love.math.newBezierCurve({10+35-35*m,60-20+20*m, 5+35-35*m,80-30+30*m, 5+35-35*m,90-30+30*m, 50,95-35+35*m})
	love.graphics.line(b3:render())
	local l1=80-30+30*m
	love.graphics.setColor(1,1,1,1)
	self:floodfill(c,50,l1,{r=cl.r/255,g=cl.g/255,b=cl.b/255,a=1})
	love.graphics.ellipse("fill",57,36,7,9)
	love.graphics.ellipse("fill",43,36,7,9)
	love.graphics.setColor(0,0,0,1)
	love.graphics.ellipse("line",57,36,7,9)
	love.graphics.ellipse("line",43,36,7,9)
	love.graphics.setColor(ecl.r/255,ecl.g/255,ecl.b/255,1)
	love.graphics.ellipse("fill",57,36,3,4)
	love.graphics.ellipse("fill",43,36,3,4)
	love.graphics.setColor(0,0,0,1)
	local mo
	if data.emote == "happy" then
		mo = love.math.newBezierCurve({35+7-7*m,50, 30+7-7*m,60-5+5*m, 37+7-7*m,63-6+6*m, 42+3-3*m,58-2+2*m})
	elseif data.emote == "neutral" then
		mo = love.math.newBezierCurve({44,55, 47.6,55, 53.3,55, 56,55})
	else
		mo = love.math.newBezierCurve({46,60, 48.6,53, 51.3,53, 54,60})
	end
	love.graphics.line(mo:render())
	end)
	love.graphics.setColor(1,1,1,1)
	if not success then
		print(_r)
		love.graphics.clear()
		love.graphics.draw(icons.missingpou,0,0,0,100/icons.missingpou:getWidth(),100/icons.missingpou:getHeight())
	end
	love.graphics.setCanvas()
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