local list = {}

local request = syn.request({
    Url = 'https://raw.githubusercontent.com/YoungsterGlenn/bpDictionaryStatistics/master/dictionary.txt'
}).Body
local count = 0
for i,v in ipairs(request:split('\n')) do
    table.insert(list, v)
    count = count + 1
    if count == 1000 then
        count = 0
        game.RunService.Heartbeat:Wait()
    end
end
table.sort(list, function(a,b)
    return a:len() > b:len()
end)

_G.list = list

local list = _G.list

local wpm = 140
local speed = 60 / (wpm*5)
local box = game:GetService("Players").GladOGGG.PlayerGui.GameUI.Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.Typebar.Typebox
local on = false
local id 
local current
local find

local newword
function newword()
    local id2 = id
    local word = 'myhackisstupidaf'
    for i,v in ipairs(list) do
        if v:lower():match(find) then
            word = v
            break
        end
    end
    current = word:lower()
    for _, v in ipairs(word:split('')) do
        wait(speed)
        box.Text = box.Text .. v:upper()
    end
    syn.set_thread_identity(7)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    wait(0.5) 
    if id2 == id and on then
        newword()
    end
end

local old
old = hookmetamethod(game, '__namecall', function(self, ...)
    local name = getnamecallmethod()
    
    local args = {...}
    if name == 'Fire' and self.ClassName and self.ClassName == 'BindableEvent' and args[1] == 'English' then
        id = game:GetService("HttpService"):GenerateGUID(false)
        find = args[3]:lower()
        coroutine.resume(coroutine.create(function()
            newword()
        end))
    elseif name == 'FireServer' and self.ClassName and self.ClassName == 'RemoteEvent' and current and args[3] and type(args[3]) == 'string' then
        local index = table.find(list, args[3])
        if index then
            table.remove(list, index)
        end
        on = args[4]
        if args[4] then
            spawn(function()
                wait(5)
                on = false
            end)
        end
    end
    return old(self, ...)
end)

print('activated')