games_scripts = {
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
                mistake_chance = 8,
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
            Settings = self
            
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

            local function getChance(chance)
                return chance <= math.random(1,100)
            end

            local function typeMistake(avoid, speed, box)
                local original = box.Text:split('')
                local text = box.Text

                local times = math.random(1,3)
                for _ = 1,times do
                    if not typing then return end

                    local char = string.char(math.random(65,90))
                    while char == avoid:upper() do
                        char = string.char(math.random(65,90))
                    end

                    text = text .. char
                    box.Text = text
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
                local text = box.Text

                for _,v in pairs(sequence) do
                    if not typing then return end
                    if not overide and self.auto_mistakes and getChance(self.mistake_chance) then
                        typeMistake(v, speed, box)
					end

					text = text .. v:upper()
                    box.Text = text
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
                    auto_section:NewSlider('Mistake Chance', 'The chance of making a mistake when automatically typing out a word', self.mistake_chance, 1, 80, function(v)
                        self.mistake_chance = v
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
                        self.speed.speed = 60 / (speed * 5)
                    end)
                    word_section:NewSlider('Word length', 'change the word length you want it to find and type', self.word_length, 5, 35, function(length)
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