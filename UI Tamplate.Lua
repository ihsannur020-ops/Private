-- Script UI untuk Delta Executor
-- GUI: [ Nama Game ]

-- ==================================================
-- 1. KONFIGURASI AWAL
-- ==================================================
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local userInput = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local localPlayer = players.LocalPlayer
local guiName = "[{NamaGame}_ByAzka]"

-- Hapus GUI lama jika ada
if coreGui:FindFirstChild(guiName) then
    coreGui:FindFirstChild(guiName):Destroy()
end

-- ==================================================
-- 2. MEMBUAT ELEMEN DASAR GUI
-- ==================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame utama (dapat digeser)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)      -- Ukuran dapat diubah
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100) -- Posisi tengah
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true   -- Mengizinkan penggeseran
mainFrame.Parent = screenGui

-- Sudut melengkung untuk frame utama
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Judul UI
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Escape Tsunami For Phones"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = mainFrame

-- Tombol Minimize
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -60, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = mainFrame

-- Tombol Close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

-- ==================================================
-- 3. SCROLLING FRAME UNTUK KONTEN
-- ==================================================
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -55)
scrollingFrame.Position = UDim2.new(0, 10, 0, 45)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = mainFrame
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- ==================================================
-- 4. MINIMIZED FRAME (KOTAK KECIL)
-- ==================================================
local minimizedFrame = Instance.new("Frame")
minimizedFrame.Size = UDim2.new(0, 50, 0, 50)
minimizedFrame.Position = UDim2.new(1, -70, 1, -70) -- pojok kanan bawah
minimizedFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimizedFrame.BackgroundTransparency = 0
minimizedFrame.BorderSizePixel = 1
minimizedFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
minimizedFrame.Active = true
minimizedFrame.Draggable = true
minimizedFrame.Visible = false  -- Mulai tersembunyi
minimizedFrame.Parent = screenGui

-- Sudut sangat melingkar (lingkaran sempurna)
local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 25) -- 25 karena 50/2 = 25
miniCorner.Parent = minimizedFrame

-- Teks di tengah ( + dan bolt ⚡ )
local miniLabel = Instance.new("TextLabel")
miniLabel.Size = UDim2.new(1, 0, 1, 0)
miniLabel.BackgroundTransparency = 1
miniLabel.Text = "+ ⚡"  -- Tambahkan bolt
miniLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
miniLabel.TextScaled = true
miniLabel.Font = Enum.Font.GothamBold
miniLabel.Parent = minimizedFrame

-- ==================================================
-- 5. FUNGSI MINIMIZE (TANPA ANIMASI)
-- ==================================================
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizedFrame.Visible = true
end)

minimizedFrame.MouseButton1Click:Connect(function()
    minimizedFrame.Visible = false
    mainFrame.Visible = true
end)

-- ==================================================
-- 6. CLOSE
-- ==================================================
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ==================================================
-- SELESAI
-- ==================================================
print("GUI [Nama Gui] Berhasil di muat.")
