function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

local text = love.filesystem.read("Translator.csv")

local mod = {}

local split1 = mysplit(text,"\n")
local __ = mysplit(split1[1],";")

local mainlang = {}
local temp = {}

for k,v in pairs(split1) do
	if k ~= 1 then
		local split3 = mysplit(v,";")
		for l,o in pairs(split3) do mainlang[temp[l]][k-1]=o end
	else
		local last = 0
		for l,o in pairs(__) do last = l mainlang[o] = {} temp[l]=o end
		for n,m in pairs(mainlang) do print(n,m) end
	end
end

mod.lang = "en"

function mod:Get(key)
	local v1
	for a,b in pairs(mainlang["Key"]) do
		if key == b then
			v1 = a
			break
		end
	end
	if v1 then
		local a = mainlang[self.lang][v1]
		if a then 
			return a
		else
			return "%NULL%"
		end
	end
end

return mod