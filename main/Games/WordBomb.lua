games_scripts = {
	["WordBomb"] = {
		name = 'Word Bomb',
		Detected = false,
		check = function()
			return replicatedS:FindFirstChild("Postie") and replicatedS:FindFirstChild("Network") and replicatedS:FindFirstChild("Products") and replicatedS:FindFirstChild("GameAssets")
		end,
		main = function(window, settings)
            local self = settings.GAMES["WordBomb"].SETTINGS
            local Settings = {
                speed = {
                    wpm = 140,
                    speed = 60 / (140*5),
                    instant_type = false,
                },
                autotype = false,
                longest = false,
                autotype_delay = true,
                word_length = 35,
                auto_mistakes = true,
                human_like = true,
                type_speed_variation = true,
                autojoin = false,
                mod_detection = true,
            }

            compare_save(Settings, self)
            self = Settings
            
            local comms = replicatedS.Network.Games.GameEvent

            local playerStats = {
                ingame = false,
                currentgame = nil,
                index = nil,
            }
            local typing = false

            local WORD_LIST = {}
            local worddoc = httpRequest({
                Url = 'https://raw.githubusercontent.com/YoungsterGlenn/bpDictionaryStatistics/master/dictionary.txt'
            }).Body
            for i,v in ipairs(worddoc:split('\n')) do
                table.insert(WORD_LIST, v:lower())
            end
            table.sort(WORD_LIST, function(a,b)
                return a:len() > b:len()
            end)

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
                        type = gamef.Game,
                        gamef = gamef,
                        main = main,
                    }
                    if main.GetArena then
                        returnee.arena = main:GetArena()
                        returnee.words_available = copyOver(WORD_LIST)
                    end
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

            local function typeSequence(sequence, speed, box)
                local sequence = (sequence and (type(sequence) == 'table') and sequence) or (sequence and (type(sequence) == 'string') and sequence:split(''))

                for _,v in pairs(sequence) do
                    if not typing then return end
                    if self.auto_mistakes and math.random(1,25) == 8 then
                        typeMistake(v, speed, box)
                    else
                        box.Text = box.Text .. v:upper()
                        if self.type_speed_variation and math.random(1,5) == 3 then
                            wait(60/((self.speed.wpm + math.random(-10, 10)) * 5))
                        else
                            wait(speed)
                        end
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
                    if word then
                        typing = true; typeWord(word, currentgame.gamef) heartS:Wait()
                        enter(currentgame.gamef, word) typing = false

                        if table.find(currentgame.words_available, word) then
                            table.remove(currentgame.words_available, table.find(currentgame.words_available, word))
                        end
                    end
                end
            end

            local function checkInGame(arena)
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
                if playerStats.currentgame.gamef then
                    playerStats.currentgame.gamef.Events.ChangePossessor.Event:Connect(function(_, index, prompt)
                        if tostring(index) == tostring(playerStats.index) then
                            gameTypeWord(playerStats.currentgame, true, prompt)
                        else
                            typing = false
                        end
                    end)
    
                    playerStats.currentgame.gamef.Events.MistakeEvent.Event:Connect(function()
                        playerStats.currentgame.gamef.UI.GameContainer.DesktopContainer.Typebar.Typebox.Text = ''
                        gameTypeWord(playerStats.currentgame)
                    end)

                    playerStats.currentgame.gamef.Events.TypingEvent.Event:Connect(function(_, word, enter)
                        local word = word:lower()
                        if enter and table.find(playerStats.currentgame.words_available, word) then
                            table.remove(playerStats.currentgame.words_available, table.find(playerStats.currentgame.words_available, word))
                        end
                    end)
                end
            end

            localPlayer.PlayerScripts.ClientGameScript.Games.ChildAdded:Connect(function(v)
                wait(0.1)
                playerStats.currentgame = getGame(v)
                if playerStats.currentgame and playerStats.type == 'WordBomb' then
                    playerStats.ingame = checkInGame(playerStats.currentgame.arena)
                    setupGame()
                else
                    joinGame(playerStats.currentgame.gamef)
                end
            end)

            playerStats.currentgame = getGame()
            playerStats.ingame = checkInGame(playerStats.currentgame.arena)
            setupGame()

            getgenv().type1 = function()
                gameTypeWord(playerStats.currentgame)
            end
		end,
	},
}