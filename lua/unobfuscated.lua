--// local key = "3b1a2bc078d8d8355844a7ce"

--// obfuscate past here

local init;
init = function()
	local val0 = false
	local val1 = true
	local val2 = true
	local val3 = false
	local val4 = false
	local val5 = true
	function gsplit(s, delimiter, func)
		local count = 1
		local s = assert(s and tostring(s))
		local func = (func and (type(func) == "function") and func) or function(s)
			return s
		end
		result = {}
		for match in (s):gmatch(delimiter) do
			table.insert(result, func(match, count))
			count = count + 1
		end
		return result
	end
	function DecToBin(dec)
		local dec = assert(dec and tonumber(dec))
		local bin = ""
		while not (dec == 0) do
			local div = dec / 2
			local int, frac = math.modf(div)
			dec = int
			bin = math.ceil(frac) .. bin
		end
		return tostring(string.rep("0", 8 - string.len(bin)) .. bin)
	end
	local mainScript = function()
		if (val0 == false) or (val1 == false) or (val2 == true) or (val3 == false) or (val4 == true) or (val5 == false) then
			warn('Detected.')
			return LPH_CRASH()
		end
		
	end
	local request = (syn and syn.request)
	if request and (key and tostring(key)) then
		local keyhere = tostring(key)
		local jobid = game.JobId
		local Url = LPH_ENCSTR('https://arduinou.herokuapp.com/execute/')
		for _ = 1, math.random(10, 50), 1 do
			jobid = string.char(math.random(25,125)) .. jobid .. string.char(math.random(25,125))
		end
		local bitsORIGINAL = #gsplit(
			table.concat(gsplit(jobid, ".", function(s)
				return DecToBin(string.byte(s))
			end), ""), ".", function(s)
				if s == "0" then
					return "_"
				end
			return nil
		end)
		local bits = bitsORIGINAL
		repeat
			if not ((bits % 2) == 0) then
				bits = bits + math.random(1,25)
			end
		until (bits % 2) == 0
		for _ = 1,math.random(1,3),1 do
			local a,b,c = pcall(function()
				local FAKEparse = game:GetService('HttpService'):JSONEncode({
					['key'] = key,
					['object'] = bits
				})
				if not (Url == LPH_ENCSTR('https://arduinou.herokuapp.com/execute/')) then
					return true
				end
				local back = game:GetService('HttpService'):JSONDecode(request({
					Url = Url,
					Method = 'POST',
					Headers = {
						["Content-Type"] = "application/json",
					},
					Body = FAKEparse
				}).Body)
				bits = bits - 21
				repeat
					if not ((bits % 2) == 0) then
						bits = bits + math.random(1,25)
					end
				until (bits % 2) == 0
				return back.Whitelisted, back.object
			end)
			if (a == false) or (b == true) or (b == nil) or (c == true) or (c == nil) then
				warn('Detected.')
				return LPH_CRASH()
			end
		end
		local check;
		do
			local stringed = gsplit(tostring(bitsORIGINAL),'.')
			if ((bitsORIGINAL % 2) == 0) then
				bitsORIGINAL = bitsORIGINAL + 1
			end
			if (tonumber(stringed[2]) % 2) == 0 then
				check = true
			else
				check = false
			end
		end
		local parse = game:GetService('HttpService'):JSONEncode({
			['key'] = key,
			['object'] = bitsORIGINAL
		})
		if not (Url == LPH_ENCSTR('https://arduinou.herokuapp.com/execute/')) then
			warn('Detected Url Change.')
			return LPH_CRASH()
		end
		local bodyback = game:GetService('HttpService'):JSONDecode(request({
			Url = Url,
			Method = 'POST',
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = parse
		}).Body)
		if (bodyback.Whitelisted == true) and (bodyback.object == check) then
			val0 = true
			val3 = true
			val2 = false
		else
			warn('You are not whitelisted.')
			return LPH_CRASH()
		end
		for _ = 1,math.random(1,3),1 do
			local a,b,c = pcall(function()
				local FAKEparse = game:GetService('HttpService'):JSONEncode({
					['key'] = key,
					['object'] = bits
				})
				if not (Url == LPH_ENCSTR('https://arduinou.herokuapp.com/execute/')) then
					return true
				end
				local back = game:GetService('HttpService'):JSONDecode(request({
					Url = Url,
					Method = 'POST',
					Headers = {
						["Content-Type"] = "application/json",
					},
					Body = FAKEparse
				}).Body)
				bits = bits - 21
				repeat
					if not ((bits % 2) == 0) then
						bits = bits + math.random(1,25)
					end
				until (bits % 2) == 0
				return back.Whitelisted, back.object
			end)
			if (a == false) or (b == true) or (b == nil) or (c == true) or (c == nil) then
				warn('Detected.')
				return LPH_CRASH()
			end
		end
		if (val0 == false) or (val1 == false) or (val2 == true) or (val3 == false) or (val4 == true) or (val5 == false) then
			warn('Detected.')
			return LPH_CRASH()
		end
		mainScript()
	elseif not request then
		warn("Executor not supported.")
		return LPH_CRASH()
	else
		warn("Invalid key.")
		return LPH_CRASH()
	end
end
init()