local UpdateStatus
local unload = (function()
	local function ExploitCheck(name, ...) --// checks if the executor has a function
		local found
		for _, v in pairs({ ... }) do --// go's trhough list of functions
			if v then --// checks if function is valid
				found = v --// if it is valid, sets it to found
				break
			end
		end
		if found then --// if found is valid
			getgenv()[name] = found --// set the name as the global enviorment for the function
		else
			error("Unsupported exploit: " .. name, 1) --// throw an error
		end
	end

	ExploitCheck("protectgui", gethui and function(v) --// for protecting screenguis from being detected 
		v.Parent = gethui() --// sets the gui to the hui so that no other scripts can access it
	end, syn and syn.protect_gui and function(v, parent)
		syn.protect_gui(v) --// protects gui with Synapse's method
		v.Parent = parent --// sets the parent.
	end)

	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local status = Instance.new("TextLabel")
	protectgui(ScreenGui, game.CoreGui)
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Frame.BackgroundTransparency = 1.000
	Frame.Position = UDim2.new(0.451550394, 0, 0.415692836, 0)
	Frame.Size = UDim2.new(0.0968992263, 0, 0.166944906, 0)
	Title.Parent = Frame
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.Position = UDim2.new(-0.5, 0, 0.25, 0)
	Title.Size = UDim2.new(2, 0, 0.5, 0)
	Title.Font = Enum.Font.SourceSansLight
	Title.Text = "Arduino"
	Title.TextColor3 = Color3.fromRGB(0, 0, 0)
	Title.TextScaled = true
	Title.TextWrapped = true

	status.Name = "status"
	status.Parent = Frame
	status.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	status.BackgroundTransparency = 1.000
	status.Position = UDim2.new(-0.5, 0, 0.620000005, 0)
	status.Size = UDim2.new(2, 0, 0.239999995, 0)
	status.Font = Enum.Font.SourceSansLight
	status.Text = "Loading..."
	status.TextColor3 = Color3.fromRGB(0, 0, 0)
	status.TextScaled = true
	status.TextWrapped = true

	UpdateStatus = function(st)
		status.Text = 'Loading ' .. st
	end

	return function()
		pcall(function()
			ScreenGui:Destroy()
		end)
	end
end)()

if _G.ArduinoCheck then
	unload()
	return error('Arduino is already running!', 0)
end

UpdateStatus('universal loader')

loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/UniversalLoader.lua"))(true) --// get universal loader with useful functions
local library
local notification

cWrap(function()
	while true do
		heartS:Wait()
		_G.ArduinoCheck = true
	end
end)

UpdateStatus('loader functions')
local compare_save
compare_save = function(t1, t2) 
    for i, v in pairs(t1) do
        if v and not t2[i] then
            if type(v) == 'table' then
                t2[i] = {}
                compare_save(v, t2[i])
            else
                t2[i] = v
            end
        elseif v and type(v) == 'table' and type(t2[i]) == 'table' then
            compare_save(v, t2[i])
        end
    end
end

local loadSettings = function(settings) --// loads the settings from the workspace folder
	if isfolder("Arduino") then --// checks if folder exist
		local inputt
		local s = pcall(function() --// tries to load the file
			inputt = JSONDecode(readfile("Arduino/saved.json")) --// loads the file
		end)
		if s then --// if file loaded successfully
			UpdateStatus('input settings')
			compare_save(settings, inputt) --// compare and save it
			settings = inputt --// set the settings to the loaded settings
		else --// if not
			local inpu  MWK02tt = JSONEncode(settings) --// encode the settings
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
		local inputt = JSONEncode(settings) --// encode the settings
		if inputt then --// if file loaded successfully
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

UpdateStatus('game table')
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
			TextColor = { 255, 255, 255 },
			ElementColor = { 20, 20, 20 },
		},
		OPEN_CLOSE = "RightShift", --// stores the open/close key
	},
	GAMES = { --// stores the available games
		["5993942214"] = {
			NAME = "Rush Point",
			SETTINGS = {},
		},
		['GPO'] = {
			NAME = 'Grand Piece  Online',
			SETTINGS = {},
		}
	},
	AUTOFARM = { --// stores the auto farm settings
		ON = false,
		INDEX = nil,
		DATA = nil, --// data for autofarm
	},
}

UpdateStatus('settings')
loadSettings(Settings) --// loads the settings

local load_ui = function(settings, name) --// loads the ui
	heartS:Wait()
	UpdateStatus('ui')
	local window = library.CreateLib("Arduino - " .. name, "DarkTheme") --// creates the window
	UpdateStatus('colors')
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
		UpdateStatus(theme)
		colors:NewColorPicker(
			theme,
			"change color for " .. theme,
			color,
			function(color3) --// creates a new color picker for each color
				libary:ChangeColor(theme, color3)
				settings.UI_SETTINGS.COLORS[theme] = {
					math.floor(color3.R * 255),
					math.floor(color3.G * 255),
					math.floor(color3.B * 255),
				} --// changes the color in the settings
			end
		)
	end
	UpdateStatus('open/close')
	local ui_s = set:NewSection("Miscellaneous") --// creates a new section
	ui_s:NewKeybind(
		"Toggle UI",
		"Toggles ui?",
		Enum.KeyCode[settings.UI_SETTINGS.OPEN_CLOSE],
		function() --// creates a new keybind for toggling the ui
			library:ToggleUI()
		end,
		function(key)
			settings.UI_SETTINGS.OPEN_CLOSE = tostring(key.KeyCode):split(".")[3] --// changes the keybind in the settings
		end
	)
	ui_s:NewButton("Save Settings", "saves settings", function() --// creates a new button for saving the settings
		settings.UI_SETTINGS.UI_POS = { --// stores the ui position
			0,
			window.container.Position.X.Offset,
			0,
			window.container.Position.Y.Offset,
		}
		saveSettings(settings) --// saves the settings
	end)
	UpdateStatus('ui position')
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
	UpdateStatus('done!')
end

local foundGame = false

for index, ta in pairs(games_scripts) do --// loops through the games table
	if ta.check() and not ta.Detected then --// checks if the game is detected and checks if its the valid game
		cWrap(function() --// encases the code in a coroutine
			foundGame = true
			if Settings.AUTOFARM.ON and Settings.AUTOFARM.INDEX == index and ta.autofarm and Settings.AUTOFARM.DATA then --// checks if autofarm is on
				ta.autofarm(Settings.AUTOFARM) --// runs the autofarm
			end

			UpdateStatus('ui libaries')
			library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/GUILibs/Kavo.lua"))(true) --// get kavo ui library
			notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/GUILibs/Notification.lua"))(true) --// get notification library

			local Arduino = load_ui(Settings, ta.name) heartS:Wait() --// load ui
			UpdateStatus('main script')
			ta.main(Arduino, Settings, notification) heartS:Wait() --// run main for the main part of the script
			UpdateStatus('ui settings')
			finalize_ui(Arduino, Settings) heartS:Wait() --// finalize ui
			wait(0.5) unload() --// unloads the progress screen
		end)
		break
	end
end

if not foundGame then
	unload()
	notification:notify({
		Title = "Unsupported Game",
		Description = "The game you are playing is not supported by this script",
		Accept = {
			Text = "Okay",
			Callback = function()
			end,
		},
		Length = 10
	})
end