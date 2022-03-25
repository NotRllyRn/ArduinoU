loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/UniversalLoader.lua"))(true)
local library, utility = getVenyx()

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
	["5993942214"] = {
		name = 'Rush Point',
		Detected = false,
		check = function()
			return (workspace:FindFirstChild('MapFolder') and workspace.MapFolder:FindFirstChild('Players') and localPlayer:FindFirstChild('PermanentTeam'))
		end,
		main = function(window, settings)
			local MapFolder = workspace.MapFolder
			local GameFolder = MapFolder.GameStats
			local PlayersFolder = MapFolder.Players
			local local_table = {
				inGame = false,
				team = localPlayer.PermanentTeam.Value,
				character = nil
			}

			local gameTable_Checks = {
				Recoil = function(v)
					return pcall(function()
						return v.RecoilIndex and v.TotalSpread and v.TotalSpreadX and v.TotalSpreadY
					end)
				end,
				Camera = function(v)
					local s = true
					for _, d in ipairs({
						'TotalCameraX',
						'TotalCameraY',
						'CurrentCameraX',
						'CurrentCameraY',
						'TotalCameraBounceX',
						'TotalCameraBounceY',
						'CurrentCameraBounceX',
						'CurrentCameraBounceY',
						'LastCameraSpringBounceX',
						'LastCameraSpringBounceY',
						'LastCameraSpringBounceZ',
						'LastAimPunchSpringX',
						'LastAimPunchSpringY',
						'LastAimPunchSpringZ',
						'LastCameraShakeTick',
					}) do
						local b,r = pcall(function()
							return( not (v[d] == nil))
						end)
						if not b or not r then
							s = false
							break
						end
					end
					return table.unpack({true, s})
				end,
				Network = function(v)
					return pcall(function()
						return v.CachedFunctions
					end)
				end,
				Weapon = function(v)
					return pcall(function()
						return v.Salvo and v.Salvo.FireRate and v.Crimson and v.Crimson.FireRate
					end)
				end
			}

			local gameTables = {}
			for _, v in ipairs(getgc(true)) do
				if v and type(v) == 'table' then
					for name, check in pairs(gameTable_Checks) do
						local s, r = check(v)
						if s and r then
							gameTables[name] = {
								Raw = v,
								Copy = {table.unpack(v)}
							}
						end
					end
				end
			end

			wait(0.1)

			local checkGame = function()
				local found = false
				for _, plr in ipairs(PlayersFolder:GetChildren()) do
					if plr.Name == localPlayer.Name then
						local_table.character = plr
						found = true
						break
					end
				end
				local_table.inGame = found
				return local_table.inGame
			end
			checkGame()

			local Settings = {
				ESP_SETTINGS = {
					tracers = false,
					box = true,
					aim = "humanoid",
					on = true,
					colors = {
						sameTeam = { 0, 255, 0 },
						otherTeam = { 255, 0, 0 },
						aimed = {255, 255, 255}
					},
					keybind = 'E',
					overide = false,
				},
				AIMBOT_SETTINGS = {
					smooth = 10,
					on = false,
					distance = 250,
					aim = "head",
					keybind = 'T',
					showaim = true,
					visible = false,
					aim_setting = 'closest to player',
				},
				CAMERA_SETTINGS = {
					no_recoil = true,
					no_shake = true,
					no_spread = true,
				},
				MISC_SETTINGS = {
					firerateOveride = false,
					firerate = 0.1,
				}
			}
			compare_save(Settings, settings.GAMES["5993942214"].SETTINGS)
			settings.GAMES["5993942214"].SETTINGS = Settings
			Settings = settings.GAMES["5993942214"].SETTINGS

			local game_table = {}
			local esp_run = function()
				checkGame()
				for NAME, v in pairs(game_table) do
					if not (players:FindFirstChild(NAME)) then
						game_table[NAME].line:Remove()
						game_table[NAME].box:Remove()
						game_table[NAME] = nil
					elseif not (PlayersFolder:FindFirstChild(NAME)) then
						game_table[NAME].inGame = false
						game_table[NAME].line.Visible = false
						game_table[NAME].box.Visible = false
					elseif v.targets.humanoid.Parent.Parent == workspace then
						game_table[NAME].line.Visible = false
						game_table[NAME].box.Visible = false
					end
				end
				for _, plr in ipairs(PlayersFolder:GetChildren()) do
					local plr_Char = plr
					local plr = players:FindFirstChild(plr.Name)
					if
						plr
						and plr_Char
						and plr_Char:FindFirstChild("HumanoidRootPart")
						and plr_Char:FindFirstChild("Head")
						and not (plr.Name == localPlayer.Name)
					then
						if not game_table[plr.Name] then
							game_table[plr.Name] = {
								line = Drawing.new("Line"),
								box = Drawing.new("Quad"),
								targets = {
									humanoid = plr_Char.HumanoidRootPart,
									head = plr_Char.Head,
								},
								team = plr.PermanentTeam.Value,
								inGame = true,
								aiming = false,
							}
						else
							game_table[plr.Name].targets = {
								humanoid = plr_Char.HumanoidRootPart,
								head = plr_Char.Head,
							}
							game_table[plr.Name].team = plr.PermanentTeam.Value
							game_table[plr.Name].inGame = true
						end

						local line = game_table[plr.Name].line
						local box = game_table[plr.Name].box
						local target = game_table[plr.Name].targets[Settings.ESP_SETTINGS.aim]
						local torso = game_table[plr.Name].targets.humanoid

						if (not (GameFolder.GameMode.Value == 'Deathmatch')) and game_table[plr.Name].team == local_table.team then
							line.Color = Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.sameTeam))
							box.Color = Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.sameTeam))
						else
							line.Color = Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.otherTeam))
							box.Color = Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.otherTeam))
						end
						if (Settings.AIMBOT_SETTINGS.on and Settings.AIMBOT_SETTINGS.showaim and game_table[plr.Name].aiming) then
							line.Color = Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.aimed))
							box.Color = Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.aimed))
						end

						line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
						line.Thickness = 2
						box.Thickness = 2
						box.Filled = false

						local point = getPoint(target)
						if point then
							line.To = point
						end

						if getPoint(torso) then
							local TL = getPoint(torso.CFrame * CFrame.new(-3, 3, 0).p, true)
							local TR = getPoint(torso.CFrame * CFrame.new(3, 3, 0).p, true)
							local BL = getPoint(torso.CFrame * CFrame.new(-3, -3, 0).p, true)
							local BR = getPoint(torso.CFrame * CFrame.new(3, -3, 0).p, true)

							box.PointA = TL
							box.PointB = TR
							box.PointC = BR
							box.PointD = BL
						end

						if (local_table.inGame or Settings.ESP_SETTINGS.overide) and game_table[plr.Name].inGame and Settings.ESP_SETTINGS.on then
							if point and Settings.ESP_SETTINGS.tracers then
								line.Visible = true
							else
								line.Visible = false
							end
							if getPoint(torso) and Settings.ESP_SETTINGS.box then
								box.Visible = true
							else
								box.Visible = false
							end
						else
							line.Visible = false
							box.Visible = false
						end
					elseif game_table[plr_Char.Name] then
						game_table[plr_Char.Name].inGame = false
						game_table[plr_Char.Name].line.Visible = false
						game_table[plr_Char.Name].box.Visible = false
					end
				end
			end

			local aimbot_run = function()
				local distance = Settings.AIMBOT_SETTINGS.distance
				if Settings.AIMBOT_SETTINGS.aim_setting == 'closest to player' then
					distance = 1e9
				end

				local aimAT;

				for _, stuff in pairs(game_table) do
					local target = stuff.targets[Settings.AIMBOT_SETTINGS.aim]
					if ((not (GameFolder.GameMode.Value == 'Deathmatch') and (not (local_table.team == stuff.team))) or (GameFolder.GameMode.Value == 'Deathmatch')) and (stuff.inGame) and target then

						local point = getPoint(target)

						if point then
							local dis = (Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2) - point).Magnitude
							if Settings.AIMBOT_SETTINGS.aim_setting == 'closest to player' and local_table.inGame then
								local dis = (target.Position - humanoidRP.Position).Magnitude
							end
							if dis < distance then
								aimAT = target
								distance = dis
							end
						end
					end
				end

				if aimAT and Settings.AIMBOT_SETTINGS.on then
					for name, stuff in pairs(game_table) do
						stuff.aiming = false
						if name == aimAT.Parent.Name then
							stuff.aiming = true
						end
					end

					local target = aimAT
					local character = local_table.character

					--local check1 = castRay(character.Head.Position, (character.Head.Position - target.Position).Unit, (character.Head.Position - target.Position).Magnitude, character, 'BlackList')
					--local on = castRay(character.Head.Position, (character.Head.Position - target.Position).Unit, (character.Head.Position - target.Position).Magnitude * 1.1, {character, workspace.CurrentCamera, workspace.RaycastIgnore, workspace.DroppedWeapons, MapFolder.Map.Ramps, MapFolder.Map.Walls}, 'Blacklist')
					local on
					--print(on and on.Instance.Parent.Parent, target.Parent)

					if local_table.inGame and ((Settings.AIMBOT_SETTINGS.visible and on and on.Instance:IsDescendantOf(target.Parent)) or (not Settings.AIMBOT_SETTINGS.visible)) then
						tweenService:Create(camera, TweenInfo.new(Settings.AIMBOT_SETTINGS.smooth / 100), {
							CFrame = CFrame.new(camera.CFrame.Position, aimAT.Position),
						}):Play()
					end
				end
			end

			function noRecoil()
				local addRecoil = gameTables.Recoil.Raw.AddRecoil
				function gameTables.Recoil.Raw.AddRecoil(...)
					if Settings.CAMERA_SETTINGS.no_recoil then
						return nil
					end
					return addRecoil(...)
				end
			end
			function noShake()
				local AddCameraShake = gameTables.Camera.Raw.AddCameraShake
				function gameTables.Camera.Raw.AddCameraShake(...)
					if Settings.CAMERA_SETTINGS.no_shake then
						return nil
					end
					return AddCameraShake(...)
				end
				local AddCameraBounce = gameTables.Camera.Raw.AddCameraBounce
				function gameTables.Camera.Raw.AddCameraBounce(...)
					if Settings.CAMERA_SETTINGS.no_shake then
						return nil
					end
					return AddCameraBounce(...)
				end
				local Damaged = gameTables.Network.Raw.CachedFunctions.Damaged
				function gameTables.Network.Raw.CachedFunctions.Damaged(...)
					if Settings.CAMERA_SETTINGS.no_shake then
						return nil
					end
					return Damaged(...)
				end
				local Fall = gameTables.Network.Raw.CachedFunctions['Fall Damage']
				gameTables.Network.Raw.CachedFunctions['Fall Damage'] = function(...)
					if Settings.CAMERA_SETTINGS.no_shake then
						return nil
					end
					return Fall(...)
				end
			end
			function noSpread()
				if Settings.CAMERA_SETTINGS.no_spread then
					for i, v in pairs(gameTables.Weapon.Raw) do
						for _, index in ipairs({
							'Spread',
							'MovementSpreadPenalty',
							'FirstShotSpread',
							'MovementSpreadTime',
						}) do
							if v[index] then
								v[index] = 0
							end
						end
					end
				else
					gameTables.Weapon.Raw = {table.unpack(gameTables.Weapon.Copy)}
				end
			end
			function updateFireRate()
				if Settings.MISC_SETTINGS.firerateOveride then
					for i, v in pairs(gameTables.Weapon.Raw) do
						if v and v.FireRate then
							v.FireRate = Settings.MISC_SETTINGS.firerate
						end
					end
				else
					gameTables.Weapon.Raw = {table.unpack(gameTables.Weapon.Copy)}
				end
			end

			local page = window:addPage(games_scripts["5993942214"].name, 5012544693) do
				local ESP = page:addSection('ESP') do
					local tog = ESP:addToggle('Esp toggle', Settings.ESP_SETTINGS.on, function(v)
						Settings.ESP_SETTINGS.on = v
					end)
					ESP:addKeybind('Esp toggle keybind', Enum.KeyCode[Settings.ESP_SETTINGS.keybind], function()
						Settings.ESP_SETTINGS.on = not Settings.ESP_SETTINGS.on
						ESP:updateToggle(tog, 'Esp toggle', Settings.ESP_SETTINGS.on)
					end, function(key)
						Settings.ESP_SETTINGS.keybind = tostring(key.KeyCode):split(".")[3]
					end)
					ESP:addToggle('Esp Overide', Settings.ESP_SETTINGS.overide, function(v)
						Settings.ESP_SETTINGS.overide = v
					end)
					ESP:addToggle('Tracers', Settings.ESP_SETTINGS.tracers, function(v)
						Settings.ESP_SETTINGS.tracers = v
					end)
					ESP:addToggle('Boxes', Settings.ESP_SETTINGS.box, function(v)
						Settings.ESP_SETTINGS.box = v
					end)
					--ESP:addDropdown('Aim at', {'head', 'humanoid'}, function(v)
						--Settings.ESP_SETTINGS.aim = v
					--end)
					cWrap(function()
						wait(1)
						ESP:Resize()
					end)
				end
				local COLORS = page:addSection('ESP Colors') do
					COLORS:addColorPicker('Same team', Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.sameTeam)), function(c)
						Settings.ESP_SETTINGS.colors.sameTeam = {c.R, c.G, c.B}
					end)
					COLORS:addColorPicker('Opponent team', Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.otherTeam)), function(c)
						Settings.ESP_SETTINGS.colors.otherTeam = {c.R, c.G, c.B}
					end)
					COLORS:addColorPicker('Aimbot target color', Color3.new(table.unpack(Settings.ESP_SETTINGS.colors.aimed)), function(c)
						Settings.ESP_SETTINGS.colors.aimed = {c.R, c.G, c.B}
					end)
				end
				local AIMBOT = page:addSection('AIMBOT') do
					local tog = AIMBOT:addToggle('Aimbot toggle', Settings.AIMBOT_SETTINGS.on, function(v)
						Settings.AIMBOT_SETTINGS.on = v
					end)
					AIMBOT:addKeybind('Aimbot toggle keybind', Enum.KeyCode[Settings.AIMBOT_SETTINGS.keybind], function()
						Settings.AIMBOT_SETTINGS.on = not Settings.AIMBOT_SETTINGS.on
						AIMBOT:updateToggle(tog, 'Aimbot toggle', Settings.AIMBOT_SETTINGS.on)
					end, function(key)
						Settings.AIMBOT_SETTINGS.keybind = tostring(key.KeyCode):split(".")[3]
					end)
					AIMBOT:addToggle('Show aiming at', Settings.AIMBOT_SETTINGS.showaim, function(v)
						Settings.AIMBOT_SETTINGS.showaim = v
					end)
					--AIMBOT:addToggle('Player has to be Visible', Settings.AIMBOT_SETTINGS.visible, function(v)
						--Settings.AIMBOT_SETTINGS.visible = v
					--end)
					--AIMBOT:addDropdown('Aim at', {'head', 'humanoid'}, function(v)
						--Settings.AIMBOT_SETTINGS.aim = v
					--end)
					--AIMBOT:addDropdown('Aim method', {'closest to player', 'closest to mouse'}, function(v)
						--Settings.AIMBOT_SETTINGS.aim_setting = v
						--print(Settings.AIMBOT_SETTINGS.aim_setting)
					--end)
					AIMBOT:addSlider('Smoothness', Settings.AIMBOT_SETTINGS.smooth, 1, 100, function(v)
						Settings.AIMBOT_SETTINGS.smooth = v
					end)
					AIMBOT:addSlider('Distance', Settings.AIMBOT_SETTINGS.distance, 1, 1000, function(v)
						Settings.AIMBOT_SETTINGS.distance = v
					end)
				end
				local CAMERA = page:addSection('CAMERA') do
					CAMERA:addToggle('No recoil', Settings.CAMERA_SETTINGS.no_recoil, function(v)
						Settings.CAMERA_SETTINGS.no_recoil = v
					end)
					CAMERA:addToggle('No shake', Settings.CAMERA_SETTINGS.no_shake, function(v)
						Settings.CAMERA_SETTINGS.no_shake = v
					end)
					CAMERA:addToggle('No spread', Settings.CAMERA_SETTINGS.no_spread, function(v)
						Settings.CAMERA_SETTINGS.no_spread = v
						noSpread()
					end)
				end
				local MISC = page:addSection('OTHER') do
					MISC:addToggle('Firerate Overide', Settings.MISC_SETTINGS.firerateOveride, function(v)
						Settings.MISC_SETTINGS.firerateOveride = v
						updateFireRate()
					end)
					MISC:addSlider('Firerate', Settings.MISC_SETTINGS.firerate * 1000, 1, 1000, function(v)
						Settings.MISC_SETTINGS.firerate = v / 1000
						updateFireRate()
					end)
				end
				window:SelectPage(window.pages[1], true)
			end
			
			renderS:Connect(function()
				cWrap(function()
					esp_run()
				end)
				cWrap(function()
					aimbot_run()
				end)
			end)
			noRecoil()
			noShake()
			noSpread()
			updateFireRate()
		end,
	},
}

local Settings = {
	UI_SETTINGS = {
		UI_POS = { 0, camera.ViewportSize.X / 2, 0, camera.ViewportSize.Y / 2 },
		COLORS = {
			Background = { 0.0941176, 0.0941176, 0.0941176 },
			Glow = { 0, 0, 0 },
			Accent = { 0.0392157, 0.0392157, 0.0392157 },
			LightContrast = { 0.0784314, 0.0784314, 0.0784314 },
			DarkContrast = { 0.054902, 0.054902, 0.054902 },
			TextColor = { 1, 1, 1 },
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

local load_ui = function(settings)
	local window = library.new("Arduino")
	do
		for theme, color3 in pairs(settings.UI_SETTINGS.COLORS) do
			window:setTheme(theme, Color3.new(table.unpack(color3)))
		end
	end

	utility:DraggingEnded(function()
		settings.UI_SETTINGS.UI_POS = {
			0,
			window.container.Main.Position.X.Offset,
			0,
			window.container.Main.Position.Y.Offset,
		}
	end)

	return window
end

local finalize_ui = function(window, settings)
	local set = window:addPage("Ui Settings", 5012544693)
	local colors = set:addSection("Colors")

	for theme, color in pairs(settings.UI_SETTINGS.COLORS) do
		local color = Color3.new(table.unpack(color))

		colors:addColorPicker(theme, color, function(color3)
			window:setTheme(theme, color3)
			settings.UI_SETTINGS.COLORS[theme] = { color3.R, color3.G, color3.B }
		end)
	end

	local ui_s = set:addSection("Miscellaneous")
	ui_s:addKeybind("Toggle UI", Enum.KeyCode[settings.UI_SETTINGS.OPEN_CLOSE], function()
		if window.position then
			settings.UI_SETTINGS.UI_POS = {
				0,
				window.container.Main.Position.X.Offset,
				0,
				window.container.Main.Position.Y.Offset,
			}
		end
		window:toggle()
	end, function(key)
		settings.UI_SETTINGS.OPEN_CLOSE = tostring(key.KeyCode):split(".")[3]
	end)
	ui_s:addButton("Save Settings", function()
		saveSettings(settings)
	end)

	window.container.Main.Position = UDim2.new(table.unpack(settings.UI_SETTINGS.UI_POS))

	onLeave(function()
		saveSettings(settings)
	end)
end

local Arduino = load_ui(Settings) do
	for _, ta in pairs(games_scripts) do
		if ta.check() and (not ta.Detected) then
			cWrap(function()
				ta.main(Arduino, Settings)
				finalize_ui(Arduino, Settings)
			end)
			break
		end
	end
end
