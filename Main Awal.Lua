local success, result = pcall(function()
    local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsannur020-ops/SpeedControl-Azka/refs/heads/main/List%20ID%20Game.Lua"))()
    if type(Games) == "table" then
        local URL = Games[game.PlaceId]
        if URL and type(URL) == "string" then
            loadstring(game:HttpGet(URL))()
        end
    end
end)
if not success then
    warn("Gagal memuat skrip: ", result)
end
