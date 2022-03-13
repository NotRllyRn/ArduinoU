
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotRllyRn/Universal-loader/main/UniversalLoader.lua"))(true)
local library, utility = getVenyx()

local compare_save
compare_save = function(s1, s2)
    for name, v in pairs(s1) do
        if not s2[name] then
            s2[name] = v
        elseif s2[name] and type(s2[name]) == 'table' and v and type(v) == 'table' then
            compare_save(v, s2[name])
        end
    end
end

local loadSettings = function(settings)
    if isfolder('Arduino') then
        local input
        local s = pcall(function()
            input = JSONDecode(readfile('Arduino/saved.json'))
        end)
        if s then
            compare_save(settings, input)
            settings = input
        else
            local input = JSONEncode(settings)
            writefile('Arduino/saved.json', input)
        end
    else
        makefolder('Arduino')
        local input = JSONEncode(settings)
        writefile('Arduino/saved.json', input)
    end
end

local saveSettings = function(settings)
    if isfolder('Arduino') and isfile('Arduino/saved.json') then
        local input
        local s = pcall(function()
            input = JSONEncode(settings)
        end)
        if s then
            writefile('Arduino/saved.json', input)
        else
            return false
        end
    else
        makefolder('Arduino')
        local input = JSONEncode(settings)
        writefile('Arduino/saved.json', input)
    end
end

local Settings = {
    UI_SETTINGS = {
        UI_POS = UDim2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2),
        COLORS = {
            Background = Color3.new(0.0941176, 0.0941176, 0.0941176),
            Glow = Color3.new(0, 0, 0),
            Accent = Color3.new(0.0392157, 0.0392157, 0.0392157),
            LightContrast = Color3.new(0.0784314, 0.0784314, 0.0784314),
            DarkContrast = Color3.new(0.054902, 0.054902, 0.054902),  
            TextColor = Color3.new(1, 1, 1),
        },
        GAMES_UI = {}
    },
    GAMES = {}
}

loadSettings(Settings)

local load_ui = function(settings)
    local Window = library.new('Arduino') do
        for theme, color3 in pairs(settings.UI_SETTINGS.COLORS) do
            Window:setTheme(theme, color3)
        end
    end

    Window.container.Main.Position = settings.UI_SETTINGS.UI_POS

    utility:DraggingEnded(function()
        settings.UI_SETTINGS.UI_POS = Window.container.Main.Position
    end)

    return Window
end

local Arduino = load_ui(Settings) do

end