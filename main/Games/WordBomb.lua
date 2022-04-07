games_scripts = {
	["5993942214"] = {
		name = 'Word Bomb',
		Detected = false,
		check = function()
			return replicatedS:FindFirstChild("Postie") and replicatedS:FindFirstChild("Network") and replicatedS:FindFirstChild("Products") and replicatedS:FindFirstChild("GameAssets")
		end,
		main = function(window, settings)
            local Settings = {
                speed = {
                    wpm = 100,
                    speed = 60 / (100*5),
                },
                autotype = false,
                autotype_delay = true,
                word_length = 100,
                auto_mistakes = true,
                human_like = true,
                type_speed_variation = true,
                autojoin = false,
                mod_detection = true,
            }

            local function findGame()
                local self = {
                    GameInfo = {},
                    GameValues = {},
                }

                local GameInfo
                local GameValues
                local games = {}
                for i,v in pairs(getgc(true)) do
                    if GameInfo and GameValues then
                        break
                    end
                    if v and type(v) == 'table' then
                        local s,r = pcall(function()
                            return v.UI.Parent and v.GameModule.Parent and getrawmetatable(v).GetStartArgs
                        end)
                        if s and r then
                            GameInfo = v
                        elseif not GameValues then
                            local s,r = pcall(function()
                                return v.Players and v.TickingProgress and v.TypingText and v.TickingRate
                            end)
                            if s and r then
                                if GameInfo then
                                    if v.Players == GameInfo.StartArgs[2].Players then
                                        GameValues = v
                                    end
                                else
                                    table.insert(games, v)
                                end
                            end
                        end
                    end
                end

                if GameInfo and not GameValues then
                    for i,v in pairs(games) do
                        if v.Players == GameInfo.StartArgs[2].Players then
                            GameValues = v
                            break
                        end
                    end
                end

                if GameInfo and not GameValues then
                    local func = getrawmetatable(gameInfo).StartGame
                    getrawmetatable(gameInfo).StartGame = function(...)
                        cWrap(function()
                            for i,v in pairs(getgc(true)) do
                                if v and type(v) == 'table' then
                                    local s,r = pcall(function()
                                        return v.Players and v.TickingProgress and v.TypingText and v.TickingRate
                                    end)
                                    if s and r then
                                        self.GameValues = v
                                        break
                                    end
                                end
                            end
                        end)

                        getrawmetatable(gameInfo).StartGame = func

                        return func(...)
                    end
                end

                if GameInfo then
                    self.GameInfo = GameInfo
                end
                if GameValues then
                    self.GameValues = GameValues
                end

                return self
            end

            
		end,
	},
}