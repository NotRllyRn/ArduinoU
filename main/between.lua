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

local uni = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/UniversalLoader.lua"))(true) --// get universal loader with useful functions
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
			UpdateStatus('json file')
			compare_save(settings, inputt) --// compare and save it
			settings = inputt --// set the settings to the loaded settings
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
	["RP"] = {
		name = 'Rush Point',
		Detected = false,
		check = function()
			return (workspace:FindFirstChild('MapFolder') and workspace.MapFolder:FindFirstChild('Players') and localPlayer:FindFirstChild('PermanentTeam'))
		end,
		main = function(window, settings)
			while uni.charLoading do
				heartS:Wait()
			end
			UpdateStatus('game settings')
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
					smooth = 4,
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
					movement_speed = 1.4,
				}
			}
			compare_save(Settings, settings.GAMES["RP"].SETTINGS)
			settings.GAMES["RP"].SETTINGS = Settings
			Settings = settings.GAMES["RP"].SETTINGS

			UpdateStatus('game files')
			local MapFolder = workspace.MapFolder
			local GameFolder = MapFolder.GameStats
			local PlayersFolder = MapFolder.Players
			local local_table = {
				inGame = false,
				team = localPlayer.PermanentTeam.Value,
				character = nil
			}
			local esp_table = {}
			local insert_esp = function(esp)
				table.insert(esp_table, esp)
			end
			local remove_esp = function(...)
				for _, esp in ipairs({...}) do
					for i, v in pairs(esp_table) do
						if v == esp then
							table.remove(esp_table, i)
							break
						end
					end
				end
			end

			local gameTable_Checks = {
				Recoil = function(v)
					return pcall(function()
						return v.RecoilIndex and v.TotalSpread and v.TotalSpreadX and v.TotalSpreadY and v.AddRecoil
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
				end,
				WeaponHandler = function(v)
					return pcall(function()
						return v.Bullets and v.Grenades and v.ReloadingValue and v.WeaponValue and v.AimOffset and v.LastSpringRecoilX and v.LastSpringRecoilY and v.PlayAnimation
					end)
				end,
				CrosshairManager = function(v)
					return pcall(function()
						return v.TotalRecoilSpread and v.SpreadOffset and v.CurrentHitmarkerSpread and v.CurrentMovementSpread and v.CurrentRecoilSpread
					end)
				end
			}

			UpdateStatus('game scripts')
			local gameTables = {}
			local found = 0
			local find = 0
			for _,_ in pairs(gameTable_Checks) do
				find = find + 1
			end
			for _, v in ipairs(getgc(true)) do
				if found == find then
					break
				end
				if v and type(v) == 'table' then
					for name, check in pairs(gameTable_Checks) do
						local s, r = check(v)
						if s and r then
							heartS:Wait()
							gameTables[name] = {
								Raw = v,
								Copy = {}
							}
							copyOver(v, gameTables[name].Copy)
							found = found + 1
						end
					end
				end
			end
			local crash = false
			for name, check in pairs(gameTable_Checks) do
				print(gameTables[name])
				if not gameTables[name] then
					crash = true
					warn('ERROR: could not find game script: ' .. name)
				end
			end
			if crash then
				error('Crashing script.')
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

			UpdateStatus('esp')

			local game_table = {}
			local esp_run = function()
				checkGame()
				for NAME, v in pairs(game_table) do
					if not (players:FindFirstChild(NAME)) then
						local r1 = game_table[NAME].line
						local r2 = game_table[NAME].box
						game_table[NAME] = nil
						cWrap(function()
							wait(1)
							r1.Visible = false
							r2.Visible = false
							remove_esp(r1, r2)
							r1:Remove()
							r2:Remove()
						end)
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
							insert_esp(game_table[plr.Name].line)
							insert_esp(game_table[plr.Name].box)
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
							line.Color = Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.sameTeam))
							box.Color = Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.sameTeam))
						else
							line.Color = Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.otherTeam))
							box.Color = Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.otherTeam))
						end
						if (Settings.AIMBOT_SETTINGS.on and Settings.AIMBOT_SETTINGS.showaim and game_table[plr.Name].aiming) then
							line.Color = Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.aimed))
							box.Color = Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.aimed))
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

			UpdateStatus('aimbot')

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
							local dis
							if Settings.AIMBOT_SETTINGS.aim_setting == 'closest to player' and local_table.inGame then
								dis = (target.Position - local_table.character.HumanoidRootPart.Position).Magnitude
							else
								dis = (Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2) - point).Magnitude
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

					local on

					if local_table.inGame and ((Settings.AIMBOT_SETTINGS.visible and on and on.Instance:IsDescendantOf(target.Parent)) or (not Settings.AIMBOT_SETTINGS.visible)) then
						tweenService:Create(camera, TweenInfo.new(Settings.AIMBOT_SETTINGS.smooth / 100), {
							CFrame = CFrame.new(camera.CFrame.Position, aimAT.Position),
						}):Play()
					end
				end
			end

			UpdateStatus('mods')

			local function noMods()
				local addRecoil = gameTables.Camera.Raw.AddRecoil
				gameTables.Camera.Raw.AddRecoil = function(...)
					if Settings.CAMERA_SETTINGS.no_recoil then
						return nil
					end
					return addRecoil(...)
				end
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
				local AimOffset = gameTables.WeaponHandler.Raw.UpdateAimOffset
				function gameTables.WeaponHandler.Raw.UpdateAimOffset(...)
					if Settings.CAMERA_SETTINGS.no_spread then
						gameTables.WeaponHandler.Raw.Offset = CFrame.new()
						return nil
					end
					return AimOffset(...)
				end
				local CrosshairSpread = gameTables.CrosshairManager.Raw.UpdateCrosshair
				function gameTables.CrosshairManager.Raw.UpdateCrosshair(...)
					if Settings.CAMERA_SETTINGS.no_spread then
						return nil
					end
					return CrosshairSpread(...)
				end
				if Settings.CAMERA_SETTINGS.no_spread then
					gameTables.WeaponHandler.Raw.Offset = CFrame.new()
					gameTables.CrosshairManager.Raw.SpreadOffset = 0
					gameTables.CrosshairManager.Raw.TotalRecoilSpread = 0
					gameTables.CrosshairManager.Raw.CurrentRecoilSpread = 0
					gameTables.CrosshairManager.Raw.TotalMovementSpread = 0
					gameTables.CrosshairManager.Raw.CurrentMovementSpread = 0
					gameTables.CrosshairManager.Raw.TotalHitmarkerSpread = 0
					gameTables.CrosshairManager.Raw.CurrentHitmarkerSpread = 0
				end
				if Settings.CAMERA_SETTINGS.no_recoil then
					gameTables.WeaponHandler.Raw.LastSpringRecoilX = 0
					gameTables.WeaponHandler.Raw.LastSpringRecoilY = 0
				end
			end
			local function noSpread()
				if Settings.CAMERA_SETTINGS.no_spread then
					for i, v in pairs(gameTables.Weapon.Raw) do
						for _, index in ipairs({
							'Spread',
							'MovementSpreadPenalty',
							'FirstShotSpread',
							'MovementSpreadTime',
							'ScopeSpread',
						}) do
							if v[index] then
								v[index] = 0
							end
						end
						if v.Offset then
							v.Offset = CFrame.new()
						end
					end
					gameTables.WeaponHandler.Raw.Offset = CFrame.new()
				else
					for i, v in pairs(gameTables.Weapon.Copy) do
						for _, index in ipairs({
							'Spread',
							'MovementSpreadPenalty',
							'FirstShotSpread',
							'MovementSpreadTime',
							'ScopeSpread',
						}) do
							if v[index] then
								pcall(function()
									gameTables.Weapon.Raw[i][index] = v[index]
								end)
							end
						end
						if v.Offset then
							pcall(function()
								gameTables.Weapon.Raw[i].Offset = v.Offset
							end)
						end
					end
				end
			end
			local function updateFireRate()
				if Settings.MISC_SETTINGS.firerateOveride then
					for i, v in pairs(gameTables.Weapon.Raw) do
						if v and v.FireRate then
							v.FireRate = Settings.MISC_SETTINGS.firerate
						end
					end
				else
					for i, v in pairs(gameTables.Weapon.Copy) do
						if v and v.FireRate then
							local s,r = pcall(function()
								gameTables.Weapon.Raw[i].FireRate = v.FireRate
							end)
							if not s then
								print(r)
							end
						end
					end
				end
			end
			local function updateSpeed()
				for i,v in pairs(gameTables.Weapon.Raw) do
					if v and v.MovementSpeedMultiplier then
						v.MovementSpeedMultiplier = Settings.MISC_SETTINGS.movement_speed
					end
				end
			end

			UpdateStatus('esp page')

			local page_esp = window:NewTab('Esp') do
				local ESP = page_esp:NewSection('Main') do
					local tog = ESP:NewToggle('Esp toggle', 'toggles esp on and off',Settings.ESP_SETTINGS.on, function(v)
						Settings.ESP_SETTINGS.on = v
					end)
					ESP:NewKeybind('Esp toggle keybind', 'toggles esp on and off',Enum.KeyCode[Settings.ESP_SETTINGS.keybind], function()
						Settings.ESP_SETTINGS.on = not Settings.ESP_SETTINGS.on
						tog:UpdateToggle('Esp toggle', Settings.ESP_SETTINGS.on)
					end, function(key)
						Settings.ESP_SETTINGS.keybind = tostring(key.KeyCode):split(".")[3]
					end)
					ESP:NewToggle('Esp Overide', "when you're spectating, it will still show you the esp",Settings.ESP_SETTINGS.overide, function(v)
						Settings.ESP_SETTINGS.overide = v
					end)
					ESP:NewToggle('Tracers', 'toggle tracer esp',Settings.ESP_SETTINGS.tracers, function(v)
						Settings.ESP_SETTINGS.tracers = v
					end)
					ESP:NewToggle('Boxes', 'toggle box esp',Settings.ESP_SETTINGS.box, function(v)
						Settings.ESP_SETTINGS.box = v
					end)
					ESP:NewDropdown('Aim at', 'for what the esp tracers will aim at',{'head', 'humanoid'}, function(v)
						Settings.ESP_SETTINGS.aim = v
					end)
				end
				local COLORS = page_esp:NewSection('ESP Colors') do
					COLORS:NewColorPicker('Same team','esp color for same team', Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.sameTeam)), function(c)
						Settings.ESP_SETTINGS.colors.sameTeam = {math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)}
					end)
					COLORS:NewColorPicker('Opponent team', 'esp color for opponent team',Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.otherTeam)), function(c)
						Settings.ESP_SETTINGS.colors.otherTeam = {math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)}
					end)
					COLORS:NewColorPicker('Aimbot target color', 'esp color for aimbot target',Color3.fromRGB(table.unpack(Settings.ESP_SETTINGS.colors.aimed)), function(c)
						Settings.ESP_SETTINGS.colors.aimed = {math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)}
					end)
				end
			end

			UpdateStatus('aimbot page')
			local page_aimbot = window:NewTab('Aimbot') do
				local AIMBOT = page_aimbot:NewSection('AIMBOT', true) do
					local tog = AIMBOT:NewToggle('Aimbot toggle', 'toggles aimbot on and off',Settings.AIMBOT_SETTINGS.on, function(v)
						Settings.AIMBOT_SETTINGS.on = v
					end)
					AIMBOT:NewKeybind('Aimbot toggle keybind', 'toggles aimbot on and off',Enum.KeyCode[Settings.AIMBOT_SETTINGS.keybind], function()
						Settings.AIMBOT_SETTINGS.on = not Settings.AIMBOT_SETTINGS.on
						tog:UpdateToggle('Aimbot toggle', Settings.AIMBOT_SETTINGS.on)
					end, function(key)
						Settings.AIMBOT_SETTINGS.keybind = tostring(key.KeyCode):split(".")[3]
					end)
					AIMBOT:NewToggle('Show aiming at', "shows what player you're aiming at by changing esp",Settings.AIMBOT_SETTINGS.showaim, function(v)
						Settings.AIMBOT_SETTINGS.showaim = v
					end)
					--AIMBOT:NewToggle('Player has to be Visible','checks if player is visible before aiming',Settings.AIMBOT_SETTINGS.visible, function(v)
						--Settings.AIMBOT_SETTINGS.visible = v
					--end)
					AIMBOT:NewDropdown('Aimbot aim at', 'change what the aimbot will aim at',{'head', 'humanoid'}, function(v)
						Settings.AIMBOT_SETTINGS.aim = v
					end)
					AIMBOT:NewDropdown('Aimbot aim method', 'aim method of aimbot', {'closest to player', 'closest to mouse'}, function(v)
						Settings.AIMBOT_SETTINGS.aim_setting = v
					end)
					AIMBOT:NewSlider('Smoothness', 'changes the smoothness of aimbot',Settings.AIMBOT_SETTINGS.smooth, 1, 100, function(v)
						Settings.AIMBOT_SETTINGS.smooth = v
					end)
					AIMBOT:NewSlider('Distance', 'distance for aimbot to start aiming', Settings.AIMBOT_SETTINGS.distance, 1, 1000, function(v)
						Settings.AIMBOT_SETTINGS.distance = v
					end)
				end
			end
			UpdateStatus('misc page')
			local page_char = window:NewTab('Character') do
				local CHAR = page_char:NewSection('CHARACTER', true) do
					CHAR:NewSlider('Movement Speed', 'changes the movement speed of the character',Settings.MISC_SETTINGS.movement_speed*10,10,14, function(v)
						Settings.MISC_SETTINGS.movement_speed = v/10
						updateSpeed()
					end)
				end
			end
			local page_camera = window:NewTab('Camera') do
				local CAMERA = page_camera:NewSection('CAMERA', true) do
					CAMERA:NewToggle('No recoil',  'removes recoil from all weapons',Settings.CAMERA_SETTINGS.no_recoil, function(v)
						Settings.CAMERA_SETTINGS.no_recoil = v
					end)
					CAMERA:NewToggle('No shake', 'removes shake when firing a weapon',Settings.CAMERA_SETTINGS.no_shake, function(v)
						Settings.CAMERA_SETTINGS.no_shake = v
					end)
					CAMERA:NewToggle('No spread', 'removes spread from all weapons',Settings.CAMERA_SETTINGS.no_spread, function(v)
						Settings.CAMERA_SETTINGS.no_spread = v
						noSpread()
					end)
				end
			end
			local page_misc = window:NewTab('Weapon Mods') do
				local MISC = page_misc:NewSection('OTHER', true) do
					MISC:NewToggle('Firerate Overide', 'turns on firerate',Settings.MISC_SETTINGS.firerateOveride, function(v)
						Settings.MISC_SETTINGS.firerateOveride = v
						updateFireRate()
					end)
					MISC:NewSlider('Firerate [RPM]', 'firerate for guns in RPM',(1000/(Settings.MISC_SETTINGS.firerate * 10000))*60, 1, 6000, function(v)
						Settings.MISC_SETTINGS.firerate = (1000/(v/60))/10000 --// calculated rpm for the game
						updateFireRate()
					end)
				end
			end
			renderS:Connect(function()
				local s,e = pcall(function()
					esp_run()
				end)
				if not s then
					print(e)
				end
				local s,e = pcall(function()
					aimbot_run()
				end)
				if not s then
					print(e)
				end
			end)
			noMods()
			noSpread()
			updateFireRate()
			updateSpeed()
			cWrap(function()
				while true do
					wait(5)
					for i,v in ipairs(esp_table) do
						if v then
							v.Visible = false
						end
					end
				end
			end)

			UpdateStatus('game script finished')
		end,
	},
	["WB"] = {
		name = 'Word Bomb',
		Detected = false,
		check = function()
			return replicatedS:FindFirstChild("Postie") and replicatedS:FindFirstChild("Network") and replicatedS:FindFirstChild("Products") and replicatedS:FindFirstChild("GameAssets")
		end,
		main = function(window, settings)
            local self = settings.GAMES["WB"].SETTINGS
            local Settings = {
                speed = {
                    wpm = 140,
                    speed = 60 / (140*5),
                    instant_type = false,
                },
                autotype = false,
                longest = false,
                autotype_delay = true,
                word_length = 10,
                auto_mistakes = true,
                human_like = true,
                type_speed_variation = true,
                autojoin = false,
                mod_detection = true,
            }

            compare_save(Settings, self)
            self = Settings
            
            local comms = replicatedS.Network.Games.GameEvent

            local labels = {
                Found = nil,
                Id = nil,
                gameType = nil,
                ingame = nil,
                word = nil,
            }

            local playerStats = {
                ingame = false,
                currentgame = nil,
                index = nil,
            }
            local typing = false

            local WORD_LIST = {}
            LPH_JIT_ULTRA(function()
                local worddoc = httpRequest({
                    Url = 'https://raw.githubusercontent.com/YoungsterGlenn/bpDictionaryStatistics/master/dictionary.txt'
                }).Body
                for i,v in ipairs(worddoc:split('\n')) do
                    table.insert(WORD_LIST, v:lower())
                end
                table.sort(WORD_LIST, function(a,b)
                    return a:len() > b:len()
                end)
            end)()
            local WORD_LIST = copyOver(WORD_LIST)

            local function updateLabels(found, word)
				if labels.word == nil then return end

                if playerStats.ingame then
                    labels.ingame:UpdateLabel('In Game: true')
                else
                    labels.ingame:UpdateLabel('In Game: false')
                end
                if word then
                    labels.word:UpdateLabel('Word: '..word:upper())
				else
                    labels.word:UpdateLabel('Word: ')
                end

                if found == true then
                    labels.Found:UpdateLabel('Found game!')
                    labels.Id:UpdateLabel('ID: '.. playerStats.currentgame.gamef.GameID)
                    labels.gameType:UpdateLabel('Game Type: '.. playerStats.currentgame.gametype)
                elseif found == false then
                    labels.Found:UpdateLabel('No game found')
                    labels.Id:UpdateLabel('ID: ')
                    labels.gameType:UpdateLabel('Game Type: ')
                else
                    if playerStats.currentgame then
                        labels.Found:UpdateLabel('Found game!')
                        labels.Id:UpdateLabel('ID: '.. playerStats.currentgame.gamef.GameID)
                        labels.gameType:UpdateLabel('Game Type: '.. playerStats.currentgame.gametype)
                    else
                        labels.Found:UpdateLabel('No game found')
                        labels.Id:UpdateLabel('ID: ')
                        labels.gameType:UpdateLabel('Game Type: ')
                    end
                end
            end

            local function getGame(v)
                local main
                local gamef

                if not v then
                    for i,v in ipairs(localPlayer.PlayerScripts.ClientGameScript.Games:GetChildren()) do
                        if #v:GetChildren() > 0 then
                            main = require(v)
                            gamef = getrawmetatable(main).__index
                            break
                        end
                    end
                else
                    main = require(v)
                    gamef = getrawmetatable(main).__index
                end

                if gamef and main then
                    local returnee = {
                        gametype = gamef.Game,
                        gamef = gamef,
                        main = main,
                    }
                    if main.GetArena then
                        returnee.arena = main:GetArena()
                        returnee.words_available = copyOver(WORD_LIST)
                    end
                    updateLabels(true)
                    return returnee
                end
                
                return nil
            end

            local function joinGame(gamef)
                if gamef and gamef.GameID then
                    comms:FireServer(gamef.GameID, 'JoinGame')
                end
            end

            local function getWord(word_list, prompt)
                local word
                if self.longest then
                    for i,v in pairs(word_list) do
                        if v:len() <= self.word_length and v:lower():match(prompt:lower()) then
                            word = v
                            break
                        end
                    end
                else
                    local valid = {}
                    for i,v in pairs(word_list) do
                        if #valid == 100 then
                            break
                        end
                        if v:len() <= self.word_length and v:lower():match(prompt:lower()) then
                            table.insert(valid, v)
                        end
                    end
                    word = valid[math.random(1,#valid)]
                end
                updateLabels(nil, word)
                return word
            end

            local function typeMistake(avoid, speed, box)
                local original = box.Text:split('')

                local times = math.random(1,3)
                for _ = 1,times do
                    if not typing then return end

                    local char = string.char(math.random(65,90))
                    while char == avoid:upper() do
                        char = string.char(math.random(65,90))
                    end

                    box.Text = box.Text .. char
                    table.insert(original, char)
                    if self.type_speed_variation and math.random(1,5) == 3 then
                        wait(60/((self.speed.wpm + math.random(-10, 10)) * 5))
                    else
                        wait(speed)
                    end
                end

                for _ = 1,times do
                    if not typing then return end

                    original[#original] = nil
                    box.Text = table.concat(original):upper()
                    if self.type_speed_variation and math.random(1,5) == 3 then
                        wait(60/((self.speed.wpm + math.random(-10, 10)) * 5))
                    else
                        wait(speed)
                    end
                end
            end

            local function typeSequence(sequence, speed, box, overide)
                local sequence = (sequence and (type(sequence) == 'table') and sequence) or (sequence and (type(sequence) == 'string') and sequence:split(''))

                for _,v in pairs(sequence) do
                    if not typing then return end
                    if not overide and self.auto_mistakes and math.random(1,25) == 8 then
                        typeMistake(v, speed, box)
					end

					box.Text = box.Text .. v:upper()
					if not overide and self.type_speed_variation and math.random(1,5) == 3 then
						wait(60/((self.speed.wpm + math.random(-10, 10)) * 5))
					else
						wait(speed)
					end
                end
            end

            local function typeWord(word, gamef) 
                if gamef and gamef.UI and word then
                    local speed = self.speed.speed
                    local typebox = gamef.UI.GameContainer.DesktopContainer.Typebar.Typebox
                    
                    if self.autotype_delay then
                        wait(math.random(5,13)/10)
                    end

                    if not typing then return end

                    if self.speed.instant_type then
                        typeSequence(word:split(''), 0, typebox, true)
                        return
                    end

                    if self.human_like then
                        local graph = {}
                        local length = word:len()

                        local list = word:split('')

                        repeat 
                            local amount = math.random(1, length)
                            local sequence = {}
                            for i = 1, amount do
                                table.insert(sequence, table.remove(list, 1))
                            end
                            table.insert(graph, {
                                amount = amount,
                                wait = 60 / ((self.speed.wpm + math.random(-20,5)) * 5),
                                sequence = sequence,
                            })

                            length = length - amount
                        until length == 0

                        if not typing then return end

                        for i,v in ipairs(graph) do
                            if not typing then return end
                            typeSequence(v.sequence, speed, typebox)
                            wait(v.wait)
                        end
                    else
                        if not typing then return end
                        typeSequence(word:split(''), speed, typebox)
                    end
                end
            end

            local function enter(gamef, word)
                comms:FireServer(gamef.GameID, 'TypingEvent', word:upper(), true)
            end

            local function gameTypeWord(currentgame, bypass, prompt)
                local arena = currentgame.arena
                local index = arena.PossessorIndex
                if bypass or (index == playerStats.index) then
                    local word = getWord(currentgame.words_available, prompt or arena.Prompt)
                    if word and not typing then
                        typing = true; typeWord(word, currentgame.gamef) heartS:Wait()
                        enter(currentgame.gamef, word) typing = false

                        if table.find(currentgame.words_available, word) then
                            table.remove(currentgame.words_available, table.find(currentgame.words_available, word))
                        end
                    end
                end
            end

            local function checkInGame(arena)
                updateLabels()
                if not arena or not arena.Players then return false end
                for i,v in pairs(arena.Players) do
                    if tostring(v) == tostring(localPlayer.UserId) then
                        playerStats.index = i
                        return true
                    end
                end
                return false
            end

            local function setupGame()
                if playerStats.currentgame.gamef and playerStats.currentgame.gametype == 'WordBomb' and playerStats.ingame then
                    playerStats.currentgame.gamef.Events.ChangePossessor.Event:Connect(function(_, index, prompt)
                        if tostring(index) == tostring(playerStats.index) and self.autotype then
                            gameTypeWord(playerStats.currentgame, true, prompt)
                        else
                            typing = false
                        end
                    end)
    
                    playerStats.currentgame.gamef.Events.MistakeEvent.Event:Connect(function()
                        if self.autotype then
                            playerStats.currentgame.gamef.UI.GameContainer.DesktopContainer.Typebar.Typebox.Text = ''
                            gameTypeWord(playerStats.currentgame)
                        end
                    end)

                    playerStats.currentgame.gamef.Events.TypingEvent.Event:Connect(function(_, word, enter)
                        local word = word:lower()
                        if enter and table.find(playerStats.currentgame.words_available, word) then
                            table.remove(playerStats.currentgame.words_available, table.find(playerStats.currentgame.words_available, word))
                        end
                    end)
                end
                updateLabels()
            end

            localPlayer.PlayerScripts.ClientGameScript.Games.ChildAdded:Connect(function(v)
                wait(0.1)
                playerStats.currentgame = getGame(v)
                if playerStats.currentgame and playerStats.currentgame.gametype == 'WordBomb' then
                    playerStats.ingame = checkInGame(playerStats.currentgame.arena)
                    setupGame()
					gameTypeWord(playerStats.currentgame)
                elseif self.autojoin then
                    joinGame(playerStats.currentgame.gamef)
					updateLabels()
                end
            end)

            playerStats.currentgame = getGame()
            playerStats.ingame = checkInGame(playerStats.currentgame.arena)
			if playerStats.currentgame and not playerStats.currentgame.arena then
				joinGame(playerStats.currentgame.gamef)
			end
			
			setupGame()

            local stats_tab = window:NewTab('Ingame Stats') do
                local stats_section = stats_tab:NewSection('Ingame Stats', true) do
                    labels.Found = stats_section:NewLabel('No game found')
                    labels.Id = stats_section:NewLabel('Id: ')
                    labels.gameType = stats_section:NewLabel('Game Type: ')
                    labels.ingame = stats_section:NewLabel('In Game: ')
                    labels.word = stats_section:NewLabel('Word: ')

                    updateLabels()

					stats_section:NewButton('Type Word', 'types out a word for you', function()
						gameTypeWord(playerStats.currentgame)
					end)
                end
            end
            local auto_tab = window:NewTab('Auto-Stuff') do
                local auto_section = auto_tab:NewSection('Auto-Stuff', true) do
                    auto_section:NewToggle('AutoType', 'Automatically types a word for you', self.autotype, function(v)
                        self.autotype = v
                    end)
                    auto_section:NewToggle('AutoMistakes', 'Automatically makes mistakes when automatically typing out a word', self.auto_mistakes, function(v)
                        self.auto_mistakes = v
                    end)
                    auto_section:NewToggle('AutoJoin', 'Automatically joins a game when a new game is made', self.autojoin, function(v)
                        self.autojoin = v
                    end)
                end
                local autoSettings_section = auto_tab:NewSection('Auto Settings') do
                    autoSettings_section:NewToggle('Human Like', 'Automatically types words in a human like manner', self.human_like, function(v)
                        self.human_like = v
                    end)
                    autoSettings_section:NewToggle('Speed Variation', 'Automatically makes the speed of typing vary', self.type_speed_variation, function(v)
                        self.type_speed_variation = v
                    end)
                    autoSettings_section:NewToggle('AutoType delay', 'Waits a random amount of time before autotyping', self.autotype_delay, function(v)
                        self.autotype_delay = v
                    end)
                end
            end
            local word_tab = window:NewTab('Speed') do
                local word_section = word_tab:NewSection('Word-Stuff', true) do
                    word_section:NewSlider('WPM', 'Words per minute', self.speed.wpm, 20, 300, function(speed)
                        self.speed.wpm = speed
                    end)
                    word_section:NewSlider('Word length', 'change the word length you want it to find and type', self.word_length, 5, 50, function(length)
                        self.word_length = length
                    end)
                    word_section:NewToggle('Longest word', 'Decides if it types a longest word or a random one', self.longest_word, function(v)
                        self.longest_word = v
                    end)
                    word_section:NewToggle('Instant Type', 'Types words instantly', self.speed.instant_type, function(v)
                        self.speed.instant_type = v
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
		["RP"] = {
			NAME = "Rush Point",
			SETTINGS = {},
		},
		['GPO'] = {
			NAME = 'Grand Piece  Online',
			SETTINGS = {},
		},
		['WB'] = {
			NAME = 'Word Bomb',
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
			library = libraryLoad('kavo', true) --// get kavo ui library
			notification = libraryLoad('notification') --// get notification library

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