local gameScripts = {
    [119987266683883] = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/SurviveLAVAforBrainrots",
    [134763881293027] = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/StealFromBrainrots",
    [138048509924404] = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/SaveBrainrotfromLava",
    [78326551441316]  = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/EscapeGettingCrushedForBrainrots",
    [135094773390024] = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/EscapePoliceForBrainrots",
    [109533024287077] = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/1SpeedEscapeforBrainrots",
    [119579217517090] = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/EscapeTsunamiForLuckyBlocks",
    [71812071769179]  = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/EscapeGuardstoStealBrainrots",
    [131623223084840] = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/EscapeTsunamiForBrainrots"
    
}

local currentGameId = game.PlaceId
local scriptUrl = gameScripts[currentGameId]

if scriptUrl then
    local success, content = pcall(game.HttpGet, game, scriptUrl)
    if success and content then
        local loadSuccess, func = pcall(loadstring, content)
        if loadSuccess and func then
            pcall(func)
        end
    end
end


--Saya Buat Code ini untuk mempermudah saya Load script Dari https://github.com/gumanba/Scripts [ Tora Isme ] Agar tidak perlu banyak Loadstring yang di simpan
