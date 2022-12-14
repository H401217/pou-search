-- Draw Pou Items v0
--[[
	data = {
		size = 0 (0 to 1)
		color = {r=0,g=0,b=0}
	}
]]
local json = require("json")
local draw = {}

function draw.toTable(ft)
	local tab1 = json.decode(ft)
	local function dec(t)
		for a,b in pairs(t) do
			if type(b) == "string" then
				if string.sub(b,1,1) == "{" or string.sub(b,1,1) == "[" then
					t[a] = json.decode(t[a]) --string.sub(b,1,string.len(b))
					t[a] = dec(t[a])
				end
			end
		end
		return t
	end
	return dec(tab1)
end

local bodycolors = {["1"]={r=214,g=154,b=88}, ["2"]={r=100,g=166,b=237}, ["3"]={r=255,g=100,b=100}, ["4"]={r=255,g=98,b=41}, ["5"]={r=255,g=255,b=0}, ["6"]={r=10,g=255,b=10}, ["7"]={r=255,g=75,b=124}, ["8"]={r=255,g=255,b=255}, ["9"]={r=0,g=245,b=139}, ["10"]={r=255,g=139,b=43}, ["11"]={r=112,g=163,b=8}, ["12"]={r=176,g=0,b=240}, ["13"]={r=196,g=177,b=2}, ["14"]={r=163,g=163,b=163}, ["15"]={r=30,g=30,b=30}, ["16"]={r=255,g=0,b=166}, ["17"]={r=208,g=0,b=255}, ["18"]={r=176,g=0,b=240}, ["19"]={r=0,g=241,b=245}, ["20"]={r=73,g=41,b=255}, ["21"]={r=255,g=94,b=140}, ["22"]={r=147,g=245,b=0},}

function draw.toBodyColor(c)
	local t = bodycolors[tostring(c)]
	if t then return t else return bodycolors["1"] end
end

function draw:toDrawer(tab)
	local ret = {color=1,sz=0.5}
	if tab.sz then
		ret.color = tab.bCo or 1
		ret.sz = tab.sz or 0.5
	elseif tab.size then
		ret.color = tab.bodyColors.a or 1
		ret.sz = tab.size or 0.5
	else
		return ret
	end
	return ret
end

function draw:drawPou(c,data)
	love.graphics.setCanvas(c)
	local cl = self.toBodyColor(data.color)
	love.graphics.clear()
	love.graphics.setColor(cl.r/255,cl.g/255,cl.b/255,1)
	love.graphics.rectangle("fill",0,0,100,100)
	love.graphics.setColor(0,0,0,1)
	local m = 0.3+0.7*((data.sz-0.5)*2)
	local b1 = love.math.newBezierCurve({10+35-35*m,60-20+20*m, 40,0+40-40*m, 60,0+40-40*m, 90-35+35*m,60-20+20*m})
	love.graphics.line(b1:render())

	local b2 = love.math.newBezierCurve({90-35+35*m,60-20+20*m, 95-35+35*m,80-30+30*m, 95-35+35*m,90-30+30*m, 50,95-35+35*m})
	love.graphics.line(b2:render())

	local b3 = love.math.newBezierCurve({10+35-35*m,60-20+20*m, 5+35-35*m,80-30+30*m, 5+35-35*m,90-30+30*m, 50,95-35+35*m})
	love.graphics.line(b3:render())
	love.graphics.setColor(1,1,1,1)
	love.graphics.ellipse("fill",57,36,7,9)
	love.graphics.ellipse("fill",43,36,7,9)
	love.graphics.setColor(0,0,0,1)
	love.graphics.ellipse("line",57,36,7,9)
	love.graphics.ellipse("line",43,36,7,9)
	love.graphics.ellipse("fill",57,36,3,4)
	love.graphics.ellipse("fill",43,36,3,4)
	local mo = love.math.newBezierCurve({35+7-7*m,50, 30+7-7*m,60-5+5*m, 37+7-7*m,63-6+6*m, 42+3-3*m,58-2+2*m})
	love.graphics.line(mo:render())
	love.graphics.setColor(1,1,1,1)
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
