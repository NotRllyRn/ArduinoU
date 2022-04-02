local function click()
	virtualIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	virtualIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end
local function to(pos)
	local dis = (humanoidRP.Position - pos).Magnitude
	local time = dis / 130
	local tween = tweenService:Create(humanoidRP, TweenInfo.new(time, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(pos),
	})
	tween:Play()
	return tween
end

local npcs = workspace.NPCs:GetChildren()
local punch = true

spawn(function()
	while true do
		heartS:Wait()
		for i = 1, 50 do
			game:GetService("ReplicatedStorage").Events.Block:InvokeServer({
				true,
				"Melee",
			})
			heartS:Wait()
		end
		game:GetService("ReplicatedStorage").Events.Block:InvokeServer({
			false,
			"Melee"
		})
	end
end)

local old
old = hookfunction(getrawmetatable(game).__namecall, function(...)
	for i, v in pairs({ ... }) do
		if not i or not v then
			return old(...)
		end
	end

	local self, data = select(1, ...)
	local namecall = getnamecallmethod()

	if namecall == "InvokeServer" then
		if data and type(data) == "table" and data[3] and type(data[3]) == "number" then
			if data[3] == 5 then
				spawn(function()
					punch = false
					wait(4)
					punch = true
				end)
			end
		end
	end

	return old(...)
end)

if localPlayer.Backpack:FindFirstChild("Melee") then
	humanoid:EquipTool(localPlayer.Backpack.Melee)
end

for _, target in pairs(npcs) do
	if target then
		to(
			Vector3.new(
				humanoidRP.Position.X,
				target.HumanoidRootPart.Position.Y - 7,
				humanoidRP.Position.Z
			)
		).Completed:Wait()
		to(target.HumanoidRootPart.Position + Vector3.new(0, -7, 0)).Completed:Wait()
		repeat
			if punch then
				click()
			end
			heartS:Wait()
			if punch then
				humanoidRP.CFrame = CFrame.new(
					target.HumanoidRootPart.Position + Vector3.new(0, -4, 0),
					target.HumanoidRootPart.Position + Vector3.new(0, 10, 0)
				)
			else
				humanoidRP.CFrame = CFrame.new(
					target.HumanoidRootPart.Position + Vector3.new(0, -7, 0),
					target.HumanoidRootPart.Position + Vector3.new(0, 10, 0)
				)
			end
			humanoidRP.Velocity = Vector3.new()
		until not target or not (target:FindFirstChild("HumanoidRootPart"))
	end
end

games_scripts = {
	["GPO"] = {
		name = "Grand Piece Online",
		Detected = false,
		check = function()
			return (game.PlaceId == 1730877806)
		end,
		autofarm = function(data)
			print('Hi')
		end,
		main = function(window, settings)
			UpdateStatus('game settings')
			local Settings = {
				autofarm = {
					on = false,
					auto_skill = false,
					auto_skill_info = {
						Strength = 50,
						Stamina = 0,
						Defense = 50,
						Gun = 0,
						Sword = 0,
					},
				},
				character = {
					no_stamina_dash = true,
					walkspeedOveride = false,
					walkspeed = 40,
					no_fall_damage = true,
				},
			}
			compare_save(Settings, settings.GAMES["GPO"].SETTINGS)
			settings.GAMES["GPO"].SETTINGS = Settings
			Settings = settings.GAMES["GPO"].SETTINGS

			local walkspeed
			walkspeed = hookfunction(getrawmetatable(game).__index, function(...)
				local self, data = ...
				if (self == humanoid and data == 'WalkSpeed') and Settings.character.walkspeedOveride then
					return 16
				end

				return walkspeed(...)
			end)

			local staminaRemote = replicatedS.Events.takestam
			local namecall
			namecall = hookfunction(getrawmetatable(game).__namecall, function(...)
				for i,v in pairs({...}) do
					if not i or not v then
						return namecall(...)
					end
				end

				local self = select(1, ...)
				if (self == staminaRemote) and Settings.character.no_stamina_dash then
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
					if v and v:IsA("Tool") and v:FindFirstChild("FruitEater") and v:FindFirstChild("Owner") and (v.Owner.Value == nil) then
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
					tweento(Vector3.new(fruit.prehandle.Position.X, game_G.SeaLevel, fruit.prehandle.Position.Z)).Completed:Wait()
					tweento(fruit.prehandle.Position).Completed:Wait()
				end
			end

			local function updateWalkSpeed()
				if Settings.character.walkspeedOveride then
					humanoid.WalkSpeed = Settings.character.walkspeed
				else
					humanoid.WalkSpeed = 16
				end
			end
			local function updateNoFallDamage()
				if Settings.character.no_fall_damage then
					character.FallDamage.Disabled = true
				else
					character.FallDamage.Disabled = false
				end
			end

			local autofarm_page = window:newTab('Auto Farm') do

			end
			local character_page = window:newTab('Character') do
				local walkspeed_overide = character_page:newToggle('Walkspeed Overide', 'Turns on walkspeed', Settings.character.walkspeedOveride, function(value)
					Settings.character.walkspeedOveride = value
					updateWalkSpeed()
				end)
				local walkspeed = character_page:newSlider('Walkspeed','changes walk speed', Settings.character.walkspeed, 16, 150, function(value)
					Settings.character.walkspeed = value
					updateWalkSpeed()
				end)
				local no_fall_damage = character_page:newToggle('No Fall Damage','activates no fall damage', Settings.character.no_fall_damage, function(value)
					Settings.character.no_fall_damage = value
					updateNoFallDamage()
				end)
				local no_stamina_dash = character_page:newToggle('No Stamina Dash','takes away very little stamina', Settings.character.no_stamina_dash, function(value)
					Settings.character.no_stamina_dash = value
				end)
			end

		end,
	},
}
