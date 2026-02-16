-- Script untuk Delta Executor
-- Menampilkan ID Game (Place ID & Job ID) secara real-time dalam GUI sederhana

-- Memuat layanan yang diperlukan
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Mendapatkan pemain lokal
local player = Players.LocalPlayer
if not player then
    warn("Tidak dapat menemukan pemain lokal.")
    return
end

-- Membuat ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "GameIDDisplay"
gui.ResetOnSpawn = false  -- Agar tidak hilang saat respawn

-- Menempatkan GUI di CoreGui jika memungkinkan, fallback ke PlayerGui
local parentGui = CoreGui
pcall(function()
    gui.Parent = parentGui
end)
if not gui.Parent then
    gui.Parent = player:WaitForChild("PlayerGui")
end

-- Membuat frame utama (dapat digeser)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)  -- Posisi tengah layar
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = true  -- Memungkinkan pengguna menggeser GUI
frame.Parent = gui

-- Judul GUI
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 25)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Game ID Info (Realtime)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- Label untuk menampilkan ID
local idLabel = Instance.new("TextLabel")
idLabel.Size = UDim2.new(1, -20, 0, 50)
idLabel.Position = UDim2.new(0, 10, 0, 35)
idLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
idLabel.BackgroundTransparency = 0.5
idLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
idLabel.Font = Enum.Font.SourceSans
idLabel.TextSize = 16
idLabel.TextWrapped = true
idLabel.Text = "Memuat..."
idLabel.Parent = frame

-- Tombol tutup (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()  -- Menghapus GUI saat tombol diklik
end)

-- Fungsi untuk memperbarui teks dengan ID game terbaru
local function updateID()
    local placeId = game.PlaceId or "Tidak tersedia"
    local jobId = game.JobId or "Tidak tersedia"
    -- Baris baru untuk memisahkan Place ID dan Job ID
    idLabel.Text = "Place ID: " .. tostring(placeId) .. "\nJob ID: " .. tostring(jobId)
end

-- Memperbarui ID setiap detik (real-time)
spawn(function()
    while gui and gui.Parent do
        updateID()
        task.wait(1)  -- Tunggu 1 detik sebelum update berikutnya
    end
end)

-- Update pertama segera setelah GUI dibuat
updateID()
