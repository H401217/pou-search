local module = {}

module.imgs = {}

setmetatable(module.imgs,{__index = function(t,i)
	t[i] = love.graphics.newImage(i)
	return t[i],true
end})

module.status_calc = function(h,he,f,s)
	return (h or 0)+(he or 0)+(f or 0)*2+(s or 0)
end

module.fixNum = function(num,min,max)
	if num < min then num = min elseif num > max then num = max end return num
end

module.options = {
	gtopday = "today",
}

module.games = {
	[1] = "Food Drop",
	[2] = "Sky Jump",
	[3] = "Free Fall",
	[4] = "Color Match",
	[5] = "Sad Tap",
	[6] = "Pou Sounds",
	[7] = "Pou Popper",
	[8] = "Tic Tac Pou",
	[9] = "Four Pous",
	[10] = "Find Pou",
	[11] = "Match Tap",
	[12] = "Color Tap",
	[13] = "Memory",
	[14] = "Connect",
	[15] = "Goal",
	[16] = "Cloud Pass",
	[17] = "Cliff Jump",
	[18] = "Pool",
	[19] = "Water Hop",
	[20] = "Sky Hop",
	[21] = "Hill Drive",
	[22] = "Cliff Dash",
	[23] = "Word Find",
	[24] = "Pet Walk",
	[25] = "Jet Pou",
	[26] = "Hoops",
	[27] = "Tumble",
	[28] = "Sudoku",
	[29] = "Star Popper",
	[30] = "Food Swap",
	[31] = "Beach Volley",
	[32] = "Connect 2",
}

module.versions = { --unaccurate, probably will be used later
	[256] = "1.4.107",
	[255] = "1.4.106",
	[254] = "1.4.105",
	[253] = "1.4.104",
	[252] = "1.4.103",
	[251] = "1.4.101",
	[250] = "1.4.100",
	[249] = "1.4.99",
	[248] = "1.4.97",
	[247] = "1.4.96",
	[246] = "1.4.95",
	[245] = "1.4.93",
	[244] = "1.4.92",
	[243] = "1.4.91",
	[242] = "1.4.90",
	[241] = "1.4.89",
	[240] = "1.4.87",
	[239] = "1.4.86",
	[238] = "1.4.84",
	[237] = "1.4.83",
	[236] = "1.4.81",
	[235] = "1.4.79",
	[234] = "1.4.78",
	[233] = "1.4.75",
	[232] = "1.4.74",
	[231] = "1.4.73",
	[230] = "1.4.72",
	[229] = "1.4.69",
	[228] = "1.4.68",
	[227] = "1.4.67",
	[226] = "1.4.66",
	[225] = "1.4.65",
	[224] = "1.4.64", --209
	[223] = "1.4.61",
	[222] = "1.4.59",
	[221] = "1.4.57",
	[220] = "1.4.56",
	[219] = "1.4.55",
	[218] = "1.4.54",
	[217] = "1.4.53", --198
}

return module