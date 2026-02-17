-- Script UI untuk Delta Executor
-- GUI: {NamaGame}_ScriptByAzka

-- ==================================================
-- 1. KONFIGURASI AWAL
-- ==================================================
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local userInput = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local textService = game:GetService("TextService")
local workspace = game:GetService("Workspace")

local localPlayer = players.LocalPlayer
local gameName = "{NamaGame}"  -- Ganti dengan nama game sebenarnya
local guiName = gameName .. "_ScriptByAzka"

-- Hapus GUI lama jika ada
if coreGui:FindFirstChild(guiName) then
    coreGui:FindFirstChild(guiName):Destroy()
end

-- ==================================================
-- 2. MEMBUAT LOADING SCREEN
-- ==================================================
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = guiName .. "_Loading"
loadingGui.Parent = coreGui
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.Enabled = true

-- Background hitam dengan opacity 70%
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
loadingFrame.BackgroundTransparency = 0.3
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = loadingGui

-- Label "Script By Azka"
local scriptLabel = Instance.new("TextLabel")
scriptLabel.Size = UDim2.new(1, 0, 0, 50)
scriptLabel.Position = UDim2.new(0, 0, 0.5, -60)
scriptLabel.BackgroundTransparency = 1
scriptLabel.Text = "Script By Azka"
scriptLabel.TextColor3 = Color3.new(1, 1, 1)
scriptLabel.TextScaled = true
scriptLabel.Font = Enum.Font.GothamBold
scriptLabel.TextStrokeTransparency = 0.5
scriptLabel.Parent = loadingFrame

-- Label nama game
local gameLabel = Instance.new("TextLabel")
gameLabel.Size = UDim2.new(1, 0, 0, 50)
gameLabel.Position = UDim2.new(0, 0, 0.5, 10)
gameLabel.BackgroundTransparency = 1
gameLabel.Text = gameName
gameLabel.TextColor3 = Color3.new(1, 1, 1)
gameLabel.TextScaled = true
gameLabel.Font = Enum.Font.GothamBold
gameLabel.TextStrokeTransparency = 0.5
gameLabel.Parent = loadingFrame

-- Hilangkan loading screen setelah 2 detik
task.wait(2)

-- Animasi fade out
tweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
tweenService:Create(scriptLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
tweenService:Create(gameLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()

task.wait(0.5)
loadingGui:Destroy()

-- ==================================================
-- 3. MEMBUAT ELEMEN DASAR GUI UTAMA
-- ==================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame utama, ukuran akan ditentukan kemudian
local mainFrame = Instance.new("Frame")
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Sudut melengkung
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- ==================================================
-- 4. HEADER (dapat digeser)
-- ==================================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -10, 0, 30)
header.Position = UDim2.new(0, 5, 0, 5)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 6)
headerCorner.Parent = header

-- Container untuk judul (dengan margin kanan agar tidak tertimpa tombol)
local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, -70, 1, 0)  -- sisakan ruang untuk tombol
titleContainer.BackgroundTransparency = 1
titleContainer.Parent = header

-- Judul
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)  -- padding kiri
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = gameName .. " "
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleContainer

-- Container tombol di kanan header
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0, 60, 1, 0)
buttonContainer.Position = UDim2.new(0, -60, 0, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = header

-- Tombol Minimize
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(0.5, 5, 0.5, -12.5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = buttonContainer

-- Tombol Close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(0, 35, 0.5, -12.5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = buttonContainer

-- ==================================================
-- 5. MENENTUKAN LEBAR BERDASARKAN JUDUL
-- ==================================================
local function getTextWidth(text, fontSize, font)
    local success, result = pcall(function()
        return textService:GetTextSize(text, fontSize, font, Vector2.new(1000, 1000))
    end)
    if success then
        return result.X
    else
        -- Fallback: perkiraan kasar
        return #text * fontSize * 0.6
    end
end

local fontSize = 18  -- Ukuran font judul (cocok dengan tinggi header 30)
local textWidth = getTextWidth(titleLabel.Text, fontSize, Enum.Font.GothamBold)
local minWidth = 100
local maxWidth = 400
local paddingLeft = 10
local paddingRight = 10
local buttonsWidth = 70  -- ruang untuk minimize dan close

-- Hitung lebar total, tambahkan padding dan ruang tombol
local totalWidth = textWidth + paddingLeft + buttonsWidth + paddingRight
totalWidth = math.clamp(totalWidth, minWidth, maxWidth)

-- ==================================================
-- 6. SCROLLING FRAME UNTUK KONTEN
-- ==================================================
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -55)  -- Sisakan header
scrollingFrame.Position = UDim2.new(0, 10, 0, 45)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.Parent = mainFrame

-- ==================================================
-- 7. FUNGSI UPDATE TINGGI MAINFRAME BERDASARKAN KONTEN
-- ==================================================
local minHeight = 100
local maxHeight = 500  -- diubah dari 400 menjadi 500
local headerHeight = 45  -- header + margin

local function updateMainFrameHeight()
    -- Beri sedikit waktu agar CanvasSize terupdate
    task.wait()
    local contentHeight = scrollingFrame.CanvasSize.Y.Offset
    local newHeight = contentHeight + headerHeight
    newHeight = math.clamp(newHeight, minHeight, maxHeight)
    
    -- Hanya update jika ukuran berubah
    if mainFrame.Size.Y.Offset ~= newHeight then
        tweenService:Create(mainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, totalWidth, 0, newHeight)}):Play()
    end
end

-- Hubungkan ke perubahan canvas size
scrollingFrame:GetPropertyChangedSignal("CanvasSize"):Connect(updateMainFrameHeight)

-- Set ukuran awal (minimal)
mainFrame.Size = UDim2.new(0, totalWidth, 0, minHeight)
mainFrame.Position = UDim2.new(0.5, -totalWidth/2, 0.5, -minHeight/2)

-- ==================================================
-- 8. DRAG (header dapat digeser)
-- ==================================================
local dragging = false
local dragStart
local startPos

-- Fungsi drag untuk header
local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end

local function updateDrag(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

local function stopDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end

header.InputBegan:Connect(startDrag)
header.InputChanged:Connect(updateDrag)
header.InputEnded:Connect(stopDrag)

-- ==================================================
-- 9. MINIMIZE: UI KECIL DENGAN TANDA +
-- ==================================================
local minimizedFrame = Instance.new("Frame")
minimizedFrame.Size = UDim2.new(0, 60, 0, 60)
minimizedFrame.BackgroundColor3 = Color3.new(0, 0, 0)
minimizedFrame.BorderSizePixel = 0
minimizedFrame.Visible = false
minimizedFrame.Active = true
minimizedFrame.Parent = screenGui

-- Sudut melingkar penuh (lingkaran)
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 30)  -- setengah dari lebar
minCorner.Parent = minimizedFrame

-- Label +
local plusLabel = Instance.new("TextLabel")
plusLabel.Size = UDim2.new(1, 0, 1, 0)
plusLabel.BackgroundTransparency = 1
plusLabel.Text = "+"
plusLabel.TextColor3 = Color3.new(1, 1, 1)
plusLabel.TextScaled = true
plusLabel.Font = Enum.Font.GothamBold
plusLabel.Parent = minimizedFrame

-- Drag untuk minimizedFrame
local dragMin = false
local dragStartMin
local startPosMin

minimizedFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragMin = true
        dragStartMin = input.Position
        startPosMin = minimizedFrame.Position
    end
end)

minimizedFrame.InputChanged:Connect(function(input)
    if dragMin and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartMin
        minimizedFrame.Position = UDim2.new(
            startPosMin.X.Scale,
            startPosMin.X.Offset + delta.X,
            startPosMin.Y.Scale,
            startPosMin.Y.Offset + delta.Y
        )
    end
end)

minimizedFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragMin = false
    end
end)

-- Klik pada minimizedFrame untuk restore
minimizedFrame.MouseButton1Click:Connect(function()
    minimizedFrame.Visible = false
    mainFrame.Visible = true
end)

-- Tombol minimize pada mainFrame
minimizeBtn.MouseButton1Click:Connect(function()
    -- Simpan posisi mainFrame untuk minimized frame
    minimizedFrame.Position = mainFrame.Position
    mainFrame.Visible = false
    minimizedFrame.Visible = true
end)

-- ==================================================
-- 10. CLOSE
-- ==================================================
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ==================================================
-- 11. CONTOH PENAMBAHAN KONTEN
-- ==================================================
for i = 1, 5 do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*35)
    btn.Text = "Tombol " .. i
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = scrollingFrame
end

-- Panggil update tinggi setelah konten ditambahkan (dengan sedikit jeda)
task.spawn(function()
    task.wait(0.1)
    updateMainFrameHeight()
end)

-- ==================================================
-- SELESAI
-- ==================================================
