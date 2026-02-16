-- Script untuk mencocokkan ID game dan menjalankan script sesuai URL
-- Sumber daftar game: https://raw.githubusercontent.com/ihsannur020-ops/SpeedControl-Azka/refs/heads/main/List%20ID%20Game.Lua

-- Load daftar game dari URL
local success, Games = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsannur020-ops/SpeedControl-Azka/refs/heads/main/List%20ID%20Game.Lua"))()
end)

-- Jika gagal memuat daftar game, tampilkan peringatan
if not success or not Games then
    warn("Gagal memuat daftar game. Periksa koneksi internet atau URL.")
    return
end

-- Dapatkan ID game saat ini
local currentGameId = game.GameId

-- Cari URL berdasarkan ID game
local scriptUrl = Games[currentGameId]

if scriptUrl then
    -- Jika ditemukan, load dan jalankan script dari URL tersebut
    local scriptLoadSuccess, scriptResult = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    if not scriptLoadSuccess then
        warn("Gagal menjalankan script dari URL: " .. scriptUrl)
    end
else
    -- Jika tidak ada script untuk game ini
    warn("Tidak ada script untuk game ini. ID: " .. currentGameId)
end
