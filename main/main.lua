loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/UniversalLoader.lua"))(true) --// get universal loader with useful functions
library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/GUILibs/Kavo.lua"))(true) --// get kavo ui library

local compare_save
compare_save = function(s1, s2) --// compares and save settings
	heartS:Wait()
	for name, v in pairs(s1) do --// loops through first table
		if not s2[name] then --// checks if table has the name already
			s2[name] = v --// if not, add it
		elseif s2[name] and type(s2[name]) == "table" and v and type(v) == "table" then --// if it does, check if it's a table
			compare_save(v, s2[name]) --// if it is, compare and save
		end
		s1[name] = s2[name] --// set the value to the saved value so they equal
	end
	heartS:Wait()
	for name, v in pairs(s2) do --// do the same thing above with the 2nd set
		if not s1[name] then
			s1[name] = v
		elseif s1[name] and type(s1[name]) == "table" and v and type(v) == "table" then
			compare_save(v, s1[name])
		end
	end
	heartS:Wait()
end

local loadSettings = function(settings) --// loads the settings from the workspace folder
	if isfolder("Arduino") then --// checks if folder exist
		local inputt
		local s = pcall(function() --// tries to load the file
			inputt = JSONDecode(readfile("Arduino/saved.json")) --// loads the file
		end)
		if s then --// if file loaded successfully
			compare_save(settings, inputt) --// compare and save it
		else --// if not
			local inputt = JSONEncode(settings) --// encode the settings
			writefile("Arduino/saved.json", inputt) --// write the file with the encoded settings
		end
	else
		makefolder("Arduino") --// if not, make the folder
		local inputt = JSONEncode(settings) --// encode the settings
		writefile("Arduino/saved.json", inputt) --// write the file with the encoded settings
	end
end

local saveSettings = function(settings) --// saves the settings to the workspace folder
	if isfolder("Arduino") and isfile("Arduino/saved.json") then --// checks if folder exist and file exist
		local inputt --// creates a variable to store the settings
		local s = pcall(function() --// tries to load the file
			inputt = JSONEncode(settings) --// loads the file
		end)
		if s then --// if file loaded successfully
			writefile("Arduino/saved.json", inputt) --// write the file with the encoded settings
		else
			return false
		end
	else
		makefolder("Arduino") --// if not, make the folder
		local inputt = JSONEncode(settings) --// encode the settings
		writefile("Arduino/saved.json", inputt) --// write the file with the encoded settings
	end
end

local games_scripts --// stores the games scripts
games_scripts = {
	
}

local Settings = { --// stores the default settings
	UI_SETTINGS = { --// stores the ui settings
		UI_POS = { 0, camera.ViewportSize.X / 2, 0, camera.ViewportSize.Y / 2 }, --// stores the ui position
		COLORS = { --// stores the colors
			SchemeColor = { 64, 64, 64 },
			Background = { 0, 0, 0 },
			Header = { 0, 0, 0 },
			TextColor = { 255,255,255 },
			ElementColor = { 20, 20, 20 },
		},
		OPEN_CLOSE = "RightShift", --// stores the open/close key
	},
	GAMES = { --// stores the available games
		["5993942214"] = {
			NAME = "Rush Point",
			SETTINGS = {},
		},
	},
	AUTOFARM = { --// stores the auto farm settings
		ON = false,
		DATA = nil, --// data for autofarm
	},
}

loadSettings(Settings) --// loads the settings

local load_ui = function(settings, name) --// loads the ui
	heartS:Wait() 
	local window = library.CreateLib("Arduino - " .. name, 'DarkTheme') --// creates the window
	do
		for theme, color3 in pairs(settings.UI_SETTINGS.COLORS) do --// loops through the colors
			heartS:Wait()
			library:ChangeColor(theme, Color3.fromRGB(table.unpack(color3))) --// changes the color
		end
	end

	return window
end

local finalize_ui = function(window, settings) --// finalizes the ui
	local set = window:NewTab("Ui Settings") --// creates a new tab
	local colors = set:NewSection("Colors") --// creates a new section

	for theme, color in pairs(settings.UI_SETTINGS.COLORS) do --// loops through the colors
		local color = Color3.fromRGB(table.unpack(color)) --// converts the color to a color3

		colors:NewColorPicker(theme,'change color for ' .. theme, color, function(color3) --// creates a new color picker for each color
			libary:ChangeColor(theme, color3)
			settings.UI_SETTINGS.COLORS[theme] = { math.floor(color3.R*255), math.floor(color3.G*255), math.floor(color3.B*255) } --// changes the color in the settings
		end)
	end

	local ui_s = set:NewSection("Miscellaneous") --// creates a new section
	ui_s:NewKeybind("Toggle UI", 'Toggles ui?',Enum.KeyCode[settings.UI_SETTINGS.OPEN_CLOSE], function() --// creates a new keybind for toggling the ui
		library:ToggleUI() 
	end, function(key)
		settings.UI_SETTINGS.OPEN_CLOSE = tostring(key.KeyCode):split(".")[3]  --// changes the keybind in the settings
	end)
	ui_s:NewButton("Save Settings", 'saves settings',function() --// creates a new button for saving the settings
		settings.UI_SETTINGS.UI_POS = { --// stores the ui position
			0,
			window.container.Position.X.Offset,
			0,
			window.container.Position.Y.Offset,
		}
		saveSettings(settings) --// saves the settings
	end)

	window.container.Position = UDim2.new(table.unpack(settings.UI_SETTINGS.UI_POS)) --// sets the ui position

	onLeave(function() --// on leave function that fires when player leaves the game
		settings.UI_SETTINGS.UI_POS = { --// stores the ui position
			0, 
			window.container.Position.X.Offset,
			0,
			window.container.Position.Y.Offset,
		}
		saveSettings(settings) --// saves the settings
	end)
	window.container.Parent.Enabled = true --// enables the ui
end

for _, ta in pairs(games_scripts) do --// loops through the games table 
	if ta.check() and (not ta.Detected) then --// checks if the game is detected and checks if its the valid game
		cWrap(function() --// encases the code in a coroutine
			local Arduino = load_ui(Settings, ta.name) --// load ui
			heartS:Wait()
			ta.main(Arduino, Settings) --// run main for the main part of the script
			heartS:Wait()
			finalize_ui(Arduino, Settings) --// finalize ui
		end)
		break
	end
end