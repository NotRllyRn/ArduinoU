games_scripts = {
	["5993942214"] = {
		name = 'Rush Point',
		Detected = false,
		check = function()
			return (workspace:FindFirstChild('MapFolder') and workspace.MapFolder:FindFirstChild('Players') and localPlayer:FindFirstChild('PermanentTeam'))
		end,
		main = function(window, settings)

        end
    }
}