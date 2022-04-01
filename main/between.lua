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
                    }
        
                    local gameTables = {}
                    for _, v in ipairs(getgc(true)) do
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
                    compare_save(Settings, settings.GAMES["5993942214"].SETTINGS)
                    settings.GAMES["5993942214"].SETTINGS = Settings
                    Settings = settings.GAMES["5993942214"].SETTINGS
        
                    local walkspeed 
                    walkspeed = hookfunction(getrawmetatable(game).__newindex, function(...)
                        for i,v in pairs({...}) do
                            if not i or not v then
                                return walkspeed(...)
                            end
                        end
        
                        local self, data = select(1, ...)
                        if self == humanoid and data == 'WalkSpeed' then
                            return walkspeed(self, data, 16 * Settings.MISC_SETTINGS.movement_speed)
                        end
        
                        return walkspeed(...)
                    end)
        
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
                        if Settings.CAMERA_SETTINGS.no_spread then
                            gameTables.WeaponHandler.Raw.Offset = CFrame.new()
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
                    local page_char = window:NewTab('Character') do
                        local CHAR = page_char:NewSection('CHARACTER', true) do
                            CHAR:NewSlider('Increase movement speed', 'changes the movement speed of the character',Settings.MISC_SETTINGS.movement_speed*10,10,14, function(v)
                                Settings.MISC_SETTINGS.movement_speed = v/10
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