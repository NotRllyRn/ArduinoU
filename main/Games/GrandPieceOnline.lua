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
					drawdistance = 600,
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
					walkonair = false,
				},
			}
			compare_save(Settings, settings.GAMES["GPO"].SETTINGS)
			Settings = settings.GAMES["GPO"].SETTINGS

			idleAfk(true)

			UpdateStatus('game mods')
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

			local function checkingameDF()
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
			end

			local function startAutofarm()
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

			local function testDiscordWebhook()
				discordWebSend(Settings.autofarm.dragonfruit.webhook, {
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

			local function walkonair()
				if Settings.character.walkonair then
					
				end
			end

			UpdateStatus('esp functions')
			local espTable = {
				dragonfruit = {},
				npcs = {},
				players = {},
				hostile = {},
			}
			local esp_run = function()
				for _,v in ipairs(workspace:GetChildren()) do
					if v and v:IsA("Tool") and v:FindFirstChild("FruitEater") and v:FindFirstChild("Owner") then
						if not table.find(espTable.dragonfruit, v) then
							local info = {
								text = Drawing.new('Text')
							}
							local old 
							old = hookfunction(getrawmetatable(v).__index, function(...)
								local self, data = select(1, ...)
								if info[data] then
									return info[data]
								end
								return old(...)
							end)
							table.insert(espTable.dragonfruit, v)
						end
					end
				end
				for _,v in ipairs(workspace.NPCs:GetChildren()) do
					if v and v:FindFirstChild('Info') and v.Info:FindFirstChild('Hostile') and not v.Info.Hostile.Value and v:FindFirstChild('HumanoidRootPart') then
						if not table.find(espTable.npcs, v) then
							local info = {
								line = (function()
									local line = Drawing.new('Line')
									line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
									line.Thickness = 2
									return line
								end)(),
								box = (function()
									local box = Drawing.new('Quad')
									box.Filled = false
									box.Thickness = 2
									return box
								end)(),
								text = (function()
									local text = Drawing.new('Text')
									text.Text = v.Name
									text.Color = Color3.fromRGB(255,255,255)
									text.OutlineColor = Color3.fromRGB(0,0,0)
									text.Outline = true
									return text
								end)(),
							}
							local old
							old = hookfunction(getrawmetatable(v).__index, function(...)
								local self, data = select(1, ...)
								if not (info[data] == nil) then
									return info[data]
								end
								return old(...)
							end)

							table.insert(espTable.npcs, v)
						end
					elseif v and v:FindFirstChild('Info') and v.Info:FindFirstChild('Hostile') and v.Info.Hostile.Value and v:FindFirstChild('HumanoidRootPart') then
						if not table.find(espTable.hostile, v) then
							local info = {
								line = (function()
									local line = Drawing.new('Line')
									line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
									line.Thickness = 2
									return line
								end)(),
								box = (function()
									local box = Drawing.new('Quad')
									box.Filled = false
									box.Thickness = 2
									return box
								end)(),
								text = (function()
									local text = Drawing.new('Text')
									text.Text = v.Name
									text.Color = Color3.fromRGB(255,255,255)
									text.OutlineColor = Color3.fromRGB(0,0,0)
									text.Outline = true
									return text
								end)(),
							}
							local old
							old = hookfunction(getrawmetatable(v).__index, function(...)
								local self, data = select(1, ...)
								if not (info[data] == nil) then
									return info[data]
								end
								return old(...)
							end)

							table.insert(espTable.hostile, v)
						end
					end
				end
				for i,v in ipairs(workspace.PlayerCharacters:GetChildren()) do
					if v and v:FindFirstChild('HumanoidRootPart') then
						if not table.find(espTable.players, v) then
							local info = {
								line = (function()
									local line = Drawing.new('Line')
									line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
									line.Thickness = 2
									return line
								end)(),
								box = (function()
									local box = Drawing.new('Quad')
									box.Filled = false
									box.Thickness = 2
									return box
								end)(),
								text = (function()
									local text = Drawing.new('Text')
									text.Text = v.Name
									text.Color = Color3.fromRGB(255,255,255)
									text.OutlineColor = Color3.fromRGB(0,0,0)
									text.Outline = true
									return text
								end)(),
							}
							local old
							old = hookfunction(getrawmetatable(v).__index, function(...)
								local self, data = select(1, ...)
								if not (info[data] == nil) then
									return info[data]
								end
								return old(...)
							end)

							table.insert(espTable.players, v)
						end
					end
				end
				for i,v in ipairs(espTable.dragonfruit) do
					if not Settings.esp.dragonfruit or not Settings.esp.on then
						return 
					end

					local text = v.text
					local target = v.preHandle
					local point = getPoint(target)

					if point then
						text.Position = point
						text.Visible = true
					else
						text.Visible = false
					end
				end
				for i,v in ipairs(espTable.hostile) do
					if not Settings.esp.on or not Settings.esp.hostile then
						return
					end

					local line = v.line
					local box = v.box
					local text = v.box
					local target = v:FindFirstChild("HumanoidRootPart")
					local point = getPoint(target)
					local distance = target and (target.Position - humanoidRP.Position).magnitude

					if point and distance and distance <= Settings.esp.drawdistance then
						line.To = point
						line.Visible = true

						local TL = getPoint(target.Position * Vector3.new(-3, 3, 0), true)
						local TR = getPoint(target.Position * Vector3.new(3, 3, 0), true)
						local BL = getPoint(target.Position * Vector3.new(-3, -3, 0), true)
						local BR = getPoint(target.Position * Vector3.new(3, -3, 0), true)

						box.PointA = TL
						box.PointB = TR
						box.PointC = BR
						box.PointD = BL
						box.Visible = true

						local textPoint = getPoint(target.Position * Vector3.new(0, 5, 0), true)
						if textPoint then
							text.Position = textPoint
							text.Visible = true
						else
							text.Visible = false
						end
					else
						line.Visible = false
						box.Visible = false
						text.Visible = false
					end

					line.Color = Color3.fromRGB(table.unpack(Settings.esp.colors.hostile))
					box.Color = Color3.fromRGB(table.unpack(Settings.esp.colors.hostile))
				end
				for i,v in ipairs(espTable.players) do
					if not Settings.esp.on or not Settings.esp.players then
						return
					end

					local line = v.line
					local box = v.box
					local text = v.box
					local target = v:FindFirstChild("HumanoidRootPart")
					local point = getPoint(target)
					local distance = target and (target.Position - humanoidRP.Position).magnitude

					if point and distance and distance <= Settings.esp.drawdistance then
						line.To = point
						line.Visible = true

						local TL = getPoint(target.Position * Vector3.new(-3, 3, 0), true)
						local TR = getPoint(target.Position * Vector3.new(3, 3, 0), true)
						local BL = getPoint(target.Position * Vector3.new(-3, -3, 0), true)
						local BR = getPoint(target.Position * Vector3.new(3, -3, 0), true)

						box.PointA = TL
						box.PointB = TR
						box.PointC = BR
						box.PointD = BL
						box.Visible = true

						local textPoint = getPoint(target.Position * Vector3.new(0, 5, 0), true)
						if textPoint then
							text.Position = textPoint
							text.Visible = true
						else
							text.Visible = false
						end
					else
						line.Visible = false
						box.Visible = false
						text.Visible = false
					end

					line.Color = Color3.fromRGB(table.unpack(Settings.esp.colors.players))
					box.Color = Color3.fromRGB(table.unpack(Settings.esp.colors.players))
				end
				for i,v in ipairs(espTable.npcs) do
					if not Settings.esp.on or not Settings.esp.npcs then
						return
					end

					local line = v.line
					local box = v.box
					local text = v.box
					local target = v:FindFirstChild("HumanoidRootPart")
					local point = getPoint(target)
					local distance = target and (target.Position - humanoidRP.Position).magnitude

					if point and distance and distance <= Settings.esp.drawdistance then
						line.To = point
						line.Visible = true

						local TL = getPoint(target.Position * Vector3.new(-3, 3, 0), true)
						local TR = getPoint(target.Position * Vector3.new(3, 3, 0), true)
						local BL = getPoint(target.Position * Vector3.new(-3, -3, 0), true)
						local BR = getPoint(target.Position * Vector3.new(3, -3, 0), true)

						box.PointA = TL
						box.PointB = TR
						box.PointC = BR
						box.PointD = BL
						box.Visible = true

						local textPoint = getPoint(target.Position * Vector3.new(0, 5, 0), true)
						if textPoint then
							text.Position = textPoint
							text.Visible = true
						else
							text.Visible = false
						end
					else
						line.Visible = false
						box.Visible = false
						text.Visible = false
					end

					line.Color = Color3.fromRGB(table.unpack(Settings.esp.colors.npcs))
					box.Color = Color3.fromRGB(table.unpack(Settings.esp.colors.npcs))
				end
			end

			UpdateStatus('game ui')
			local autofarm_page = window:NewTab('Auto Farm') do
				local dragonfruit = autofarm_page:NewSection('Dragonfruit (ingame)') do
					dragonfruit:NewLabel('dragon fruit farm for ingame (no hop)')
					local tog
					tog = dragonfruit:NewToggle('autofarm', 'goes to dragon fruit, picks it up, and tries to store it.',Settings.autofarm.dragonfruit.ingame.on, function(v)
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
							checkingameDF()
						else
							found:UpdateLabel('Status: not found')
							wait(3)
							found:UpdateLabel('Status: nil')
						end
					end)
					dragonfruit:NewToggle('Go to dragonfruit', 'tweens to dragonfruit if it finds one',Settings.autofarm.dragonfruit.checker.gotof, function(v)
						Settings.dragonfruit.gotof = v
					end)
					dragonfruit:NewToggle('Auto pickup', 'automatically picks up dragonfruit if found', Settings.autofarm.dragonfruit.checker.autopickup, function(v)
						Settings.dragonfruit.autopickup = v
					end)
					dragonfruit:NewToggle('Go back to spawn', 'tweens back to spawn after picking up dragon fruit', Settings.autofarm.dragonfruit.checker.gobacksafe, function(v)
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
							startAutofarm()
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
							testDiscordWebhook()
						end
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
					espSection:NewSlider('Draw distance', 'the distance it has to be within to draw it', Settings.esp.drawdistance, 200, 10000, function(v)
						Settings.esp.drawdistance = v
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

			renderS:Connect(function()
				local s,e = pcall(function()
					-- esp_run()
				end)
				if not s then
					print(e)
				end
			end)
			updateWalkSpeed()
		end,
	},
}