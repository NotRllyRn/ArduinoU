getgenv()["FN2h-jrnFJ2rhrns-iVBU2b"] = true

local function cprint(...)
	rconsoleprint(...)
end

while true do
	rprint("Key: ")
	local input = rconsoleinput()
	if not getgenv()["FN2h-jrnFJ2rhrns-iVBU2b"] then
		break
	end
	loadstring(syn.request({ Url = "https://arduinou.herokuapp.com/script", Body = input, Method = "GET" }))()
	if not getgenv()["FN2h-jrnFJ2rhrns-iVBU2b"] then
		break
	end
	rprint("Invalid key.\n")
end
