loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/UniversalLoader.lua"))(true)
library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/GUILibs/Kavo.lua"))()

local compare_save
compare_save = function(s1, s2)
	for name, v in pairs(s1) do
		if not s2[name] then
			s2[name] = v
		elseif s2[name] and type(s2[name]) == "table" and v and type(v) == "table" then
			compare_save(v, s2[name])
		end
		s1[name] = s2[name]
	end
	for name, v in pairs(s2) do
		if not s1[name] then
			s1[name] = v
		elseif s1[name] and type(s1[name]) == "table" and v and type(v) == "table" then
			compare_save(v, s1[name])
		end
	end
end

local loadSettings = function(settings)
	if isfolder("Arduino") then
		local inputt
		local s = pcall(function()
			inputt = JSONDecode(readfile("Arduino/saved.json"))
		end)
		if s then
			compare_save(settings, inputt)
		else
			local inputt = JSONEncode(settings)
			writefile("Arduino/saved.json", inputt)
		end
	else
		makefolder("Arduino")
		local inputt = JSONEncode(settings)
		writefile("Arduino/saved.json", inputt)
	end
end

local saveSettings = function(settings)
	if isfolder("Arduino") and isfile("Arduino/saved.json") then
		local inputt
		local s = pcall(function()
			inputt = JSONEncode(settings)
		end)
		if s then
			writefile("Arduino/saved.json", inputt)
		else
			return false
		end
	else
		makefolder("Arduino")
		local inputt = JSONEncode(settings)
		writefile("Arduino/saved.json", inputt)
	end
end

local games_scripts
games_scripts = {
	
}

local Settings = {
	UI_SETTINGS = {
		UI_POS = { 0, camera.ViewportSize.X / 2, 0, camera.ViewportSize.Y / 2 },
		COLORS = {
			SchemeColor = { 64, 64, 64 },
			Background = { 0, 0, 0 },
			Header = { 0, 0, 0 },
			TextColor = { 255,255,255 },
			ElementColor = { 20, 20, 20 },
		},
		OPEN_CLOSE = "RightShift",
	},
	GAMES = {
		["5993942214"] = {
			NAME = "Rush Point",
			SETTINGS = {},
		},
	},
	AUTOFARM = {
		ON = false,
		DATA = nil,
	},
}

loadSettings(Settings)

local load_ui = function(settings, name)
	local window = library.CreateLib("Arduino - " .. name, 'DarkTheme')
	do
		for theme, color3 in pairs(settings.UI_SETTINGS.COLORS) do
			library:ChangeColor(theme, Color3.fromRGB(table.unpack(color3)))
		end
	end

	return window
end

local finalize_ui = function(window, settings)
	local set = window:NewTab("Ui Settings")
	local colors = set:NewSection("Colors")

	for theme, color in pairs(settings.UI_SETTINGS.COLORS) do
		local color = Color3.fromRGB(table.unpack(color))

		colors:NewColorPicker(theme,'change color for ' .. theme, color, function(color3)
			libary:ChangeColor(theme, color3)
			settings.UI_SETTINGS.COLORS[theme] = { math.floor(color3.R*255), math.floor(color3.G*255), math.floor(color3.B*255) }
		end)
	end

	local ui_s = set:NewSection("Miscellaneous") 
	ui_s:NewKeybind("Toggle UI", 'Toggles ui?',Enum.KeyCode[settings.UI_SETTINGS.OPEN_CLOSE], function() 
		library:ToggleUI() 
	end, function(key)
		settings.UI_SETTINGS.OPEN_CLOSE = tostring(key.KeyCode):split(".")[3] 
	end)
	ui_s:NewButton("Save Settings", 'saves settings',function()
		settings.UI_SETTINGS.UI_POS = {
			0,
			window.container.Position.X.Offset,
			0,
			window.container.Position.Y.Offset,
		}
		saveSettings(settings) 
	end)

	window.container.Position = UDim2.new(table.unpack(settings.UI_SETTINGS.UI_POS)) 

	onLeave(function() 
		settings.UI_SETTINGS.UI_POS = { 
			0, 
			window.container.Position.X.Offset,
			0,
			window.container.Position.Y.Offset,
		}
		saveSettings(settings) 
	end)
end

for _, ta in pairs(games_scripts) do
	if ta.check() and (not ta.Detected) then
		cWrap(function()
			local Arduino = load_ui(Settings, ta.name) -- load ui
			ta.main(Arduino, Settings) -- run main
			finalize_ui(Arduino, Settings) -- finalize ui
		end)
		break
	end
end