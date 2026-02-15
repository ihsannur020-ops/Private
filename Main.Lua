-- Script untuk Delta Executor
-- Membuat GUI dengan nama "ScriptByAzka_Deepseek" di CoreGui
-- Dilengkapi drag header, minimize (animasi gulung), dan close

-- Hapus GUI lama jika ada
local coreGui = game:GetService("CoreGui")
local guiName = "ScriptByAzka_Deepseek"
local existing = coreGui:FindFirstChild(guiName)
if existing then existing:Destroy() end

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 400)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = false -- kita akan buat drag manual via header

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 4, 1, 0)
accentBar.Position = UDim2.new(0, 0, 0, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
accentBar.BorderSizePixel = 0
accentBar.Parent = mainFrame

-- Header (bisa di-drag)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -10, 0, 40)
header.Position = UDim2.new(0, 5, 0, 5)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 6)
headerCorner.Parent = header

-- Ikon
local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 30, 0, 30)
icon.Position = UDim2.new(0, 5, 0.5, -15)
icon.BackgroundTransparency = 1
icon.Text = "⚡"
icon.TextColor3 = Color3.fromRGB(0, 255, 0)
icon.TextScaled = true
icon.Font = Enum.Font.GothamBold
icon.Parent = header

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 40, 0, 0)
title.BackgroundTransparency = 1
title.Text = "WAVE LOOP CONTROL"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Tombol Minimize
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -65, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = minimizeBtn

-- Tombol Close (dengan X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- Content frame (akan di-minimize, berisi container tombol dan footer)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 0, 150) -- tinggi: 120 (container) + 30 (footer) = 150
contentFrame.Position = UDim2.new(0, 10, 0, 50) -- di bawah header (50 = 5 header pos y + 40 tinggi header + 5 jarak)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame
contentFrame.ClipsDescendants = true

-- Container tombol
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 0, 120)
buttonContainer.Position = UDim2.new(0, 0, 0, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = contentFrame

-- Tombol 1
local button1 = Instance.new("TextButton")
button1.Size = UDim2.new(1, 0, 0, 50)
button1.Position = UDim2.new(0, 0, 0, 0)
button1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button1.Text = "Hapus Wave Loop"
button1.TextColor3 = Color3.fromRGB(255, 255, 255)
button1.TextScaled = true
button1.Font = Enum.Font.GothamBold
button1.BorderSizePixel = 0
button1.Parent = buttonContainer

local btn1Corner = Instance.new("UICorner")
btn1Corner.CornerRadius = UDim.new(0, 8)
btn1Corner.Parent = button1

-- Tombol 2
local button2 = Instance.new("TextButton")
button2.Size = UDim2.new(1, 0, 0, 50)
button2.Position = UDim2.new(0, 0, 0, 60)
button2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button2.Text = "Stop Loop"
button2.TextColor3 = Color3.fromRGB(255, 255, 255)
button2.TextScaled = true
button2.Font = Enum.Font.GothamBold
button2.BorderSizePixel = 0
button2.Parent = buttonContainer

local btn2Corner = Instance.new("UICorner")
btn2Corner.CornerRadius = UDim.new(0, 8)
btn2Corner.Parent = button2

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -30) -- di bagian bawah contentFrame
footer.BackgroundTransparency = 1
footer.Text = "Azka Script"
footer.TextColor3 = Color3.fromRGB(180, 180, 180)
footer.TextScaled = true
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = contentFrame

-- ===========================================
-- FUNGSI DRAG HEADER
-- ===========================================
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart = nil
local startPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Cek apakah yang diklik adalah tombol (minimize/close) atau turunannya? Kita ingin drag hanya jika klik di area header selain tombol.
        -- Kita bisa cek apakah target adalah tombol atau bagian dari tombol.
        local target = input.UserInputObject.Target
        if target and (target:IsDescendantOf(minimizeBtn) or target:IsDescendantOf(closeBtn)) then
            return -- jangan drag jika klik tombol
        end
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ===========================================
-- FUNGSI MINIMIZE
-- ===========================================
local TweenService = game:GetService("TweenService")
local isMinimized = false
local originalContentHeight = contentFrame.Size.Y.Offset

local function toggleMinimize()
    if isMinimized then
        -- Maximize: kembalikan ukuran contentFrame
        local tween = TweenService:Create(contentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -20, 0, originalContentHeight)})
        tween:Play()
    else
        -- Minimize: kecilkan contentFrame hingga 0
        local tween = TweenService:Create(contentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -20, 0, 0)})
        tween:Play()
    end
    isMinimized = not isMinimized
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

-- ===========================================
-- FUNGSI CLOSE
-- ===========================================
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ===========================================
-- FUNGSIONALITAS WAVE LOOP (client-side)
-- ===========================================
local workspace = game:GetService("Workspace")
local targetNames = {
    "SuperSlow", "Slow", "Medium", "Fast", "SuperFast", "Lightning"
}

local connection = nil

local function deleteExistingModels()
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and table.find(targetNames, child.Name) then
            child:Destroy()
        end
    end
end

local function onChildAdded(child)
    if child:IsA("Model") and table.find(targetNames, child.Name) then
        child:Destroy()
    end
end

button1.MouseButton1Click:Connect(function()
    deleteExistingModels()
    if not connection then
        connection = workspace.ChildAdded:Connect(onChildAdded)
    end
    button1.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    wait(0.2)
    button1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

button2.MouseButton1Click:Connect(function()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    button2.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    wait(0.2)
    button2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

print("GUI " .. guiName .. " loaded. Drag header to move, minimize and close buttons work.")
