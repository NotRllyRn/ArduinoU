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
	["5993942214"] = {
		name = "Grand Piece Online",
		Detected = false,
		check = function()
			return true
		end,
		main = function(window, settings)
			local Settings = {
				ESP_SETTINGS = {
					tracers = false,
					box = false,
					aim = "humanoid",
					on = true,
					colors = {
						sameTeam = { 0, 255, 0 },
						otherTeam = { 255, 0, 0 },
					},
					keybind = 'E',
					overide = false,
				},

			}
			compare_save(Settings, settings.GAMES["5993942214"].SETTINGS)
			settings.GAMES["5993942214"].SETTINGS = Settings
			Settings = settings.GAMES["5993942214"].SETTINGS

			if settings.autofarm.ON then
				
			end

		end,
	},
}
