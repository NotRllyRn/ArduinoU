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
	["GPO"] = {
		name = "Grand Piece Online",
		Detected = false,
		check = function()
			return (game.PlaceId == 1730877806) or (game.PlaceId == 3978370137) or (game.PlaceId == 6360478118)
		end,
		autofarm = function(data)
			if data.DATA and data.DATA.type then
				if (not (_G.FARM == nil) and (_G.FARM == false)) then
					data.DATA = nil
					data.AUTOFARM = false
					return
				end
				local autofarmTypes = {
					DragonFruit = function(data)
						if (game.PlaceId == 1730877806) then
							while true do
								wait(1)
								replicatedS.Events.playgame:FireServer()
							end
						elseif (game.PlaceId == 3978370137) then
							wait(5)
							local game_G = getrenv()._G
							local function tweento(pos)
								local dis = (humanoidRP.Position - pos).Magnitude
								local time = dis / 130
								local tween = tweenService:Create(humanoidRP, TweenInfo.new(time, Enum.EasingStyle.Linear), {
									CFrame = CFrame.new(pos),
								})
								tween:Play()
								return tween
							end

							local function checkDF()
								local found
								for i,v in ipairs(workspace:GetChildren()) do
									if v and v:IsA("Tool") and v:FindFirstChild("FruitEater") and v:FindFirstChild("Owner") and (v.Owner.Value == nil) and (v.preHandle.Position.Y > game_G.SeaLevel) then
										found = v
										break
									end
								end
								return found
							end
				
							local function CheckandGotoDF()
								local fruit = checkDF()
								if fruit then
									tweento(Vector3.new(humanoidRP.Position.X, game_G.SeaLevel, humanoidRP.Position.Z)).Completed:Wait()
									tweento(Vector3.new(fruit.preHandle.Position.X, game_G.SeaLevel, fruit.preHandle.Position.Z)).Completed:Wait()
									tweento(fruit.preHandle.Position).Completed:Wait()
								end
								return fruit
							end

							if checkDF() then
								local fruit = checkDF()
								if data.DATA.webhook:len() > 10 then
									discordWebSend(data.DATA.webhook, {
										username = 'Fruit Finder',
										avatar_url = 'https://cdn.discordapp.com/attachments/900983183145840652/959907982441857054/unknown.png?size=4096',
										content = '@everyone',
										embeds = {
											{
												type = 'rich',
												title = 'GPO fruit farm',
												color = 16767232,
												fields = {
													{
														name = 'Player',
														value = '||'.. localPlayer.Name ..' ||'
													},
													{
														name = 'Fruit',
														value = fruit.Name
													}
												}
											}
										}
									})
								end
								if data.DATA.gotof then
									CheckandGotoDF()
								end
							else
								join(1730877806)
							end
						else
							join(1730877806)
						end
					end
				}

				if autofarmTypes[data.DATA.type] then
					autofarmTypes[data.DATA.type](data)
				end
			end
		end,
		main = function(window, settings, notif)
			UpdateStatus('game settings')
			local Settings = {
				esp = {
					on = false,
					dragonfruit = true,
					npcs = false,
					players = false,
					hostile = true,
					colors = {
						dragonfruit = {0, 0, 0},
						npcs = {0, 255, 0},
						players = {0, 0, 255},
						hostile = {255, 0, 0},
					},
				},
				autofarm = {
					dragonfruit = {
						ingame = {
							on = false,
							rejoin = false,
						},
						checker = {
							gotof = true,
							autopickup = true,
							gobacksafe = true,
						},
						hopper = {
							gotof = true,
							autopickup = true,
							gobacksafe = true,
							autostore = true,
						},
						webhook = '',
					},
					on = false,
					auto_skill = false,
					auto_skill_info = {
						Strength = 50,
						Stamina = 0,
						Defense = 50,
						df = 0,
						Gun = 0,
						Sword = 0,
					},
				},
				character = {
					no_stamina_dash = true,
					walkspeedOveride = false,
					walkspeed = 40,
				},
			}
			compare_save(Settings, settings.GAMES["GPO"].SETTINGS)
			settings.GAMES["GPO"].SETTINGS = Settings
			Settings = settings.GAMES["GPO"].SETTINGS

			idleAfk(true)

			local walkspeed
			walkspeed = hookfunction(getrawmetatable(game).__index, function(...)
				local self, data = ...
				if (self == humanoid and data == 'WalkSpeed') and Settings.character.walkspeedOveride then
					return 16
				end

				return walkspeed(...)
			end)
			local walkspeed2
			walkspeed2 = hookfunction(getrawmetatable(game).__newindex, function(...)
				local self, data = ...
				if self == humanoid and data == 'WalkSpeed' and Settings.character.walkspeedOveride then
					return walkspeed2(self, data, Settings.character.walkspeed)
				end

				return walkspeed2(...)
			end)

			local staminaRemote = replicatedS.Events:FindFirstChild('takestam')
			local namecall
			namecall = hookfunction(getrawmetatable(game).__namecall, function(...)
				for i,v in pairs({...}) do
					if not i or not v then
						return namecall(...)
					end
				end

				local self = select(1, ...)
				if (staminaRemote and self == staminaRemote) and Settings.character.no_stamina_dash then
					return namecall(self, 0.0001)
				end

				return namecall(...)
			end)

			local game_G = getrenv()._G

			local function tweento(pos)
				local dis = (humanoidRP.Position - pos).Magnitude
				local time = dis / 130
				local tween = tweenService:Create(humanoidRP, TweenInfo.new(time, Enum.EasingStyle.Linear), {
					CFrame = CFrame.new(pos),
				})
				tween:Play()
				return tween
			end

			local function checkDF()
				local found
				for i,v in ipairs(workspace:GetChildren()) do
					if v and v:IsA("Tool") and v:FindFirstChild("FruitEater") and v:FindFirstChild("Owner") and (v.Owner.Value == nil) and (v.preHandle.Position.Y > game_G.SeaLevel) then
						found = v
						break
					end
				end
				return found
			end

			local function CheckandGotoDF(df)
				local fruit = df or checkDF()
				if fruit then
					tweento(Vector3.new(humanoidRP.Position.X, game_G.SeaLevel, humanoidRP.Position.Z)).Completed:Wait()
					tweento(Vector3.new(fruit.preHandle.Position.X, game_G.SeaLevel, fruit.preHandle.Position.Z)).Completed:Wait()
					tweento(fruit.preHandle.Position).Completed:Wait()
				end
				return fruit
			end

			local function updateWalkSpeed()
				if Settings.character.walkspeedOveride then
					humanoid.WalkSpeed = Settings.character.walkspeed
				else
					humanoid.WalkSpeed = 16
				end
			end

			local ingamerunning = false
			local function ingameFruitFarm(toggle)
				if Settings.autofarm.dragonfruit.ingame then
					local button = playerGUI.storefruit.TextButton
					cWrap(function()
						while Settings.autofarm.dragonfruit.ingame do
							ingamerunning = true
							local df = checkDF()
							if df and Settings.autofarm.dragonfruit.ingame then
								discordWebSend(data.DATA.webhook, {
									username = 'Fruit Finder',
									avatar_url = 'https://cdn.discordapp.com/attachments/900983183145840652/959907982441857054/unknown.png?size=4096',
									content = '@everyone',
									embeds = {
										{
											type = 'rich',
											title = 'GPO fruit farm',
											color = 16767232,
											fields = {
												{
													name = 'Player',
													value = '||'.. localPlayer.Name ..' ||'
												},
												{
													name = 'Fruit',
													value = df.Name
												}
											}
										}
									}
								})
								local return_vec = humanoidRP.Position
								CheckandGotoDF(df)
								humanoidRP.Anchored = true

								camera.CFrame = CFrame.new(camera.Position, df.preHandle.Position) wait(0.1)
								virtualIM:SendKeyEvent(true, Enum.KeyCode.LeftAlt, false, game) wait(5) virtualIM:SendKeyEvent(false, Enum.KeyCode.LeftAlt, true, game) wait(1)

								if button.Visible then
									cButton(button)
									wait(5)
								end

								humanoidRP.Anchored = false

								tweento(Vector3.new(humanoidRP.Position.X, game_G.SeaLevel, humanoidRP.Position.Z)).Completed:Wait()
								tweento(Vector3.new(return_vec.X, game_G.SeaLevel, return_vec.Y)).Completed:Wait()
								tweento(return_vec).Completed:Wait()

								discordWebSend(data.DATA.webhook, {
									username = 'Fruit Finder',
									avatar_url = 'https://cdn.discordapp.com/attachments/900983183145840652/959907982441857054/unknown.png?size=4096',
									content = '@everyone',
									embeds = {
										{
											type = 'rich',
											title = 'GPO fruit farm',
											color = 16767232,
											fields = {
												{
													name = 'Player',
													value = '||'.. localPlayer.Name ..' ||'
												},
												{
													name = 'Status',
													value = 'No more bags'
												}
											}
										}
									}
								})
								toggle:UpdateToggle(nil, false)
								break
							end
							wait(60)
						end
					end)
				end
			end

			local espTable = {
				dragonfruit = {},
				npcs = {},
				players = {},
				hostile = {},
			}
			local esp_run = function()
				for i,v in ipairs(espTable.dragonfruit) do
					if not v.target then
						v.line.Visible = false
						v.line:Remove()
					end
				end
				for i,v in ipairs(espTable.players) do
					if not v.target then
						v.line.Visible = false
						v.line:Remove()
					end
				end
				for i,v in ipairs(espTable.hostile) do
					if not v.target then
						v.line.Visible = false
						v.line:Remove()
					end
				end
				for i,v in ipairs(workspace:GetChildren()) do
					if v and v:IsA("Tool") and v:FindFirstChild("FruitEater") and v:FindFirstChild("Owner") then
						local insert = {
							target = v.preHandle,
							line = Drawing.new('Line')
						}
						table.insert(espTable.dragonfruit, insert)
					end
				end
				for i,v in ipairs(workspace.npcs:GetChildren()) do
					if v and v:FindFirstChild('Info') and not v.Info.Hostile.Value then
						local insert = {
							target = v.target,
							line = Drawing.new('Line')
						}
						table.insert(espTable.npcs, insert)
					end
				end
			end

			local autofarm_page = window:NewTab('Auto Farm') do
				local dragonfruit = autofarm_page:NewSection('Dragonfruit (ingame)') do
					dragonfruit:NewLabel('dragon fruit farm for ingame (no hop)')
					local tog
					tog = dragonfruit:NewToggle('autofarm', 'goes to dragon fruit, picks it up, and tries to store it.',Settings.autofarm.dragonfruit.ingame, function(v)
						Settings.autofarm.dragonfruit.ingame = v
						if not ingamerunning then
							ingameFruitFarm(tog)
						end
					end)
				end
			end
			local dragonfruit_page = window:NewTab('Dragonfruit') do
				local dragonfruit = dragonfruit_page:NewSection('Dragonfruit Check') do
					local found = dragonfruit:NewLabel('Status: nil')
					dragonfruit:NewButton('Check for dragonfruit', 'checks for dragonfruit', function()
						local fruit = checkDF()
						if fruit then
							found:UpdateLabel('Status: found ' .. fruit.Name)
							if Settings.autofarm.dragonfruit.gotof then
								local return_vec = humanoidRP.Position
								CheckandGotoDF()

								if Settings.autofarm.dragonfruit.autopickup then
									humanoidRP.Anchored = true

									camera.CFrame = CFrame.new(camera.Position, fruit.preHandle.Position)
									wait(0.1)
									virtualIM:SendKeyEvent(true, Enum.KeyCode.LeftAlt, false, game)
									wait(5)
									virtualIM:SendKeyEvent(false, Enum.KeyCode.LeftAlt, true, game)

									humanoidRP.Anchored = false

									if Settings.autofarm.dragonfruit.gobacksafe then
										wait(0.1)
	
										tweento(Vector3.new(humanoidRP.Position.X, game_G.SeaLevel, humanoidRP.Position.Z)).Completed:Wait()
										tweento(Vector3.new(return_vec.X, game_G.SeaLevel, return_vec.Y)).Completed:Wait()
										tweento(return_vec).Completed:Wait()
									end
								end
							end
						else
							found:UpdateLabel('Status: not found')
							wait(3)
							found:UpdateLabel('Status: nil')
						end
					end)
					dragonfruit:NewToggle('Go to dragonfruit', 'tweens to dragonfruit if it finds one',Settings.dragonfruit.gotof, function(v)
						Settings.dragonfruit.gotof = v
					end)
					dragonfruit:NewToggle('Auto pickup', 'automatically picks up dragonfruit if found', Settings.dragonfruit.autopickup, function(v)
						Settings.dragonfruit.autopickup = v
					end)
					dragonfruit:NewToggle('Go back to spawn', 'tweens back to spawn after picking up dragon fruit', Settings.dragonfruit.gobacksafe, function(v)
						Settings.dragonfruit.gobacksafe = v
					end)
				end
				local dragonfruit = dragonfruit_page:NewSection('Dragonfruit Farm') do
					dragonfruit:NewLabel('to stop the autofarm, set _G.FARM to false')
					dragonfruit:NewLabel('put loader with key into your autoexec')
					dragonfruit:NewLabel('RECOMMENDED NOT TO USE RN (rblx having issues)')
					dragonfruit:NewButton('Copy farm stop', 'copies script to stop farm', function()
						setclipboard('_G.FARM = false')
					end)
					dragonfruit:NewToggle('Dragon fruit autofarm', 'autofarm for dragon fruit', false, function(v)
						settings.AUTOFARM.ON = v
						_G.FARM = v
						if v then
							local autofarmData = {
								type = '',
								webhook = Settings.autofarm.dragonfruit.webhook,
								gotof = Settings.autofarm.dragonfruit.hopper.gotof,
								autopickup = Settings.autofarm.dragonfruit.hopper.autopickup,
								gobacksafe = Settings.autofarm.dragonfruit.hopper.gobacksafe,
							}
							notif:notify({
								Title = 'You are about to start dragonfruit autofarm,',
								Description = 'start autofarm? remember, _G.FARM = false to stop',
								Accept = {
									Text = 'Start',
									Callback = function()
										autofarmData.type = 'DragonFruit'
										settings.AUTOFARM.DATA = autofarmData
										settings.AUTOFARM.INDEX = 'GPO'
										join(1730877806)
									end,
								},
								Dismiss = {
									Text = 'Cancel',
									Callback = function()
										_G.FARM = false
										settings.AUTOFARM.ON = false
									end,
								}
							})
						end
					end)
					dragonfruit:NewTextBox('Webhook (discord)', 'pings @everyone and tells you what fruit it found',Settings.autofarm.dragonfruit.webhook, function(v)
						Settings.autofarm.dragonfruit.webhook = v
					end)
					dragonfruit:NewToggle('Goto fruit when found', 'goes to the fruit when it finds one', Settings.autofarm.dragonfruit.gotof, function(v)
						Settings.autofarm.dragonfruit.gotof = v
					end)
					dragonfruit:NewButton('Test webhook', 'test webhook for discord', function()
						if not (autofarmData.webhook == '') then
							discordWebSend(autofarmData.webhook, {
								username = 'Fruit Finder',
								avatar_url = 'https://cdn.discordapp.com/attachments/900983183145840652/959907982441857054/unknown.png?size=4096',
								embeds = {
									{
										type = 'rich',
										title = 'GPO test message',
										description = 'this is a test message',
										color = 16767232,
										fields = {
											{
												name = 'Test',
												value = 'field test'
											}
										}
									}
								}
							})
						end
					end)
				end
			end
			local esp_page = window:NewTab('ESP') do
				local espSection = esp_page:NewSection('Main') do
					espSection:NewToggle('Enabled','enable and disables all esp', Settings.esp.on, function(v)
						Settings.esp.on = v
					end)
					espSection:NewToggle('Dragonfruit','enable and disables the esp for dragonfruit', Settings.esp.dragonfruit, function(v)
						Settings.esp.dragonfruit = v
					end)
					espSection:NewToggle('NPCs','enable and disables the esp for npcs', Settings.esp.npcs, function(v)
						Settings.esp.npcs = v
					end)
					espSection:NewToggle('Players','enable and disables the esp for players', Settings.esp.players, function(v)
						Settings.esp.players = v
					end)
					espSection:NewToggle('Hostile','enable and disables the esp for hostile', Settings.esp.hostile, function(v)
						Settings.esp.hostile = v
					end)
				end
				local colorsection = esp_page:NewSection('Colors') do
					colorsection:NewColorPicker('Dragonfruit', 'esp color for dragonfruit', Color3.fromRGB(table.unpack(Settings.esp.colors.dragonfruit)), function(c)
						Settings.esp.colors.dragonfruit = {math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)}
					end)
					colorsection:NewColorPicker('NPCs', 'esp color for npcs', Color3.fromRGB(table.unpack(Settings.esp.colors.npcs)), function(c)
						Settings.esp.colors.npcs = {math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)}
					end)
					colorsection:NewColorPicker('Players', 'esp color for players', Color3.fromRGB(table.unpack(Settings.esp.colors.players)), function(c)
						Settings.esp.colors.players = {math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)}
					end)
					colorsection:NewColorPicker('Hostile', 'esp color for hostile', Color3.fromRGB(table.unpack(Settings.esp.colors.hostile)), function(c)
						Settings.esp.colors.hostile = {math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)}
					end)
				end
			end
			local character_page = window:NewTab('Character') do
				local characterSection = character_page:NewSection('CHARACTER', true) do
					characterSection:NewToggle('Walkspeed Overide', 'Turns on walkspeed', Settings.character.walkspeedOveride, function(value)
						Settings.character.walkspeedOveride = value
						updateWalkSpeed()
					end)
					characterSection:NewSlider('Walkspeed','changes walk speed', Settings.character.walkspeed, 16, 150, function(value)
						Settings.character.walkspeed = value
						updateWalkSpeed()
					end)
					characterSection:NewToggle('No Stamina Dash','takes away very little stamina', Settings.character.no_stamina_dash, function(value)
						Settings.character.no_stamina_dash = value
					end)
				end
			end
		end,
	},
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