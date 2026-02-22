local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local userInput = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualInput = game:GetService("VirtualInputManager")

local localPlayer = players.LocalPlayer
local guiName = "RunForBrainrot"  -- Ganti nama GUI

if coreGui:FindFirstChild(guiName) then
    coreGui:FindFirstChild(guiName):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Run For Brainrot"  -- Ganti judul
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -65, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 40
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

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

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Parent = scrollingFrame
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 10)

local function createContainer(name)
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = scrollingFrame
    container.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    return container
end

local slideContainer = createContainer("SlideContainer")
local buttonContainer = createContainer("ButtonContainer")
local switchContainer = createContainer("SwitchContainer")

-- ============================================================
-- FUNGSI-FUNGSI UTAMA (diperbaiki)
-- ============================================================

-- Mendapatkan folder plot milik player sendiri
local function getPlayerPlotFolder()
    local playerName = localPlayer.Name
    return workspace:FindFirstChild("Plot_" .. playerName)
end

-- Teleport ke plot sendiri (Go To Plot)
local function teleportToHome()
    local plotFolder = getPlayerPlotFolder()
    if plotFolder then
        -- Coba cari part "Spawn" atau "Start" di dalam plot
        local spawnPart = plotFolder:FindFirstChild("Spawn") or plotFolder:FindFirstChild("Start") or plotFolder:FindFirstChild("Base")
        if spawnPart and spawnPart:IsA("BasePart") then
            local character = localPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
            end
        else
            -- Jika tidak ada, teleport ke posisi tengah plot
            local cframe = plotFolder:GetPivot()
            local character = localPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = cframe + Vector3.new(0, 3, 0)
            end
        end
    else
        warn("Plot folder not found!")
    end
end

-- Menghapus semua objek bernama "BreakableZone" (Remove Breakble Zone)
local function removeBreakableZone()
    -- Cari di workspace semua instance dengan nama "BreakableZone" (atau "BreakbleZone")
    local zones = workspace:GetDescendants()
    for _, obj in ipairs(zones) do
        if obj.Name == "BreakableZone" or obj.Name == "BreakbleZone" then
            obj:Destroy()
        end
    end
    -- Coba juga di GameFolder jika ada
    local gameFolder = workspace:FindFirstChild("GameFolder")
    if gameFolder then
        for _, obj in ipairs(gameFolder:GetDescendants()) do
            if obj.Name == "BreakableZone" or obj.Name == "BreakbleZone" then
                obj:Destroy()
            end
        end
    end
end

-- ============================================================
-- AUTO COLLECT CASH & AUTO UPGRADE ALL (diperbaiki)
-- ============================================================

local collectCashEnabled = false
local upgradeAllEnabled = false
local placesCache = nil
local lastPlotName = ""

local function getPlacesData()
    local plotFolder = getPlayerPlotFolder()
    if not plotFolder then return nil end

    -- Jika plot berubah, reset cache
    if plotFolder.Name ~= lastPlotName then
        placesCache = nil
        lastPlotName = plotFolder.Name
    end

    if placesCache then return placesCache end

    local places = plotFolder:FindFirstChild("Places")
    if not places then return nil end

    local touchParts = {}
    local upgradeButtons = {}

    for i = 1, 30 do
        local model = places:FindFirstChild(tostring(i))
        if model then
            -- Claim (TouchTransmitter)
            local claim = model:FindFirstChild("Claim")
            if claim then
                local touchInterest = claim:FindFirstChildWhichIsA("TouchTransmitter")
                if touchInterest then
                    table.insert(touchParts, claim)
                end
            end
            -- Upgrade (Tombol di SurfaceGui)
            local upgradePart = model:FindFirstChild("Upgrade")
            if upgradePart then
                local surfaceGui = upgradePart:FindFirstChildWhichIsA("SurfaceGui")
                if surfaceGui then
                    local upgradeButton = surfaceGui:FindFirstChild("Upgrade")
                    if upgradeButton and upgradeButton:IsA("GuiButton") then
                        table.insert(upgradeButtons, upgradeButton)
                    end
                end
            end
        end
    end

    placesCache = {
        touchParts = touchParts,
        upgradeButtons = upgradeButtons
    }
    return placesCache
end

local function fireAllTouchInterests()
    local data = getPlacesData()
    if not data then return end

    local character = localPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, part in ipairs(data.touchParts) do
        firetouchinterest(rootPart, part, 0)
        firetouchinterest(rootPart, part, 1)
        task.wait()
    end
end

local function clickAllUpgrades()
    local data = getPlacesData()
    if not data then return end

    for _, button in ipairs(data.upgradeButtons) do
        local event = button.MouseButton1Click
        if event then
            if firesignal then
                firesignal(event)
            else
                pcall(function()
                    event:Fire()
                end)
            end
        end
        task.wait()
    end
end

local function startCollectCashLoop()
    while true do
        if collectCashEnabled then
            fireAllTouchInterests()
        end
        task.wait(1)
    end
end

local function startUpgradeAllLoop()
    while true do
        if upgradeAllEnabled then
            clickAllUpgrades()
        end
        task.wait(1)
    end
end

task.spawn(startCollectCashLoop)
task.spawn(startUpgradeAllLoop)

-- ============================================================
-- FUNGSI CREATE CHECKBOX (dengan tampilan baru)
-- ============================================================
local function createCheckbox(config)
    local container = switchContainer
    local text = config.Text or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 24, 0, 24)
    checkBtn.Position = UDim2.new(1, -30, 0.5, -12)
    checkBtn.BackgroundColor3 = default and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
    checkBtn.Text = ""
    checkBtn.BorderSizePixel = 0
    checkBtn.Parent = frame

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 4)
    checkCorner.Parent = checkBtn

    -- Centang (hanya muncul jika on)
    local checkMark = Instance.new("TextLabel")
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = default and "✓" or ""  -- kosong jika off
    checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkMark.TextSize = 18
    checkMark.Font = Enum.Font.GothamBold  -- bold
    checkMark.Parent = checkBtn

    local state = default

    local function updateCheck()
        if state then
            checkBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)  -- biru
            checkMark.Text = "✓"  -- centang muncul
        else
            checkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)  -- abu-abu
            checkMark.Text = ""  -- kosong
        end
    end

    checkBtn.MouseButton1Click:Connect(function()
        state = not state
        updateCheck()
        callback(state)
    end)

    return frame
end

-- ============================================================
-- MINIMIZED FRAME (sama seperti sebelumnya)
-- ============================================================
local minimizedFrame = Instance.new("Frame")
minimizedFrame.Size = UDim2.new(0, 50, 0, 50)
minimizedFrame.Position = UDim2.new(1, -70, 1, -70)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimizedFrame.BorderSizePixel = 1
minimizedFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
minimizedFrame.Active = true
minimizedFrame.Visible = false
minimizedFrame.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 10)
miniCorner.Parent = minimizedFrame

local miniLabel = Instance.new("TextLabel")
miniLabel.Size = UDim2.new(1, 0, 1, 0)
miniLabel.BackgroundTransparency = 1
miniLabel.Text = "+"
miniLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
miniLabel.TextSize = 50
miniLabel.Font = Enum.Font.GothamBold
miniLabel.Parent = minimizedFrame

local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(1, 0, 1, 0)
miniButton.BackgroundTransparency = 1
miniButton.Text = ""
miniButton.Parent = minimizedFrame

local dragging = false
local dragStartPos
local frameStartPos
local isDragging = false
local dragThreshold = 5

miniButton.MouseButton1Down:Connect(function()
    dragging = true
    dragStartPos = userInput:GetMouseLocation()
    frameStartPos = minimizedFrame.Position
    isDragging = false
end)

userInput.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = userInput:GetMouseLocation()
        local delta = currentPos - dragStartPos
        if not isDragging and (delta.X^2 + delta.Y^2) > dragThreshold^2 then
            isDragging = true
        end
        if isDragging then
            minimizedFrame.Position = UDim2.new(
                frameStartPos.X.Scale,
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

userInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
        if not isDragging then
            minimizedFrame.Visible = false
            mainFrame.Visible = true
        end
        dragging = false
    end
end)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizedFrame.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ============================================================
-- MEMBUAT TOMBOL & CHECKBOX DI UI
-- ============================================================

-- Tombol Go To Plot
local goToPlotBtn = Instance.new("TextButton")
goToPlotBtn.Size = UDim2.new(1, 0, 0, 30)
goToPlotBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
goToPlotBtn.Text = "Go To Plot"
goToPlotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
goToPlotBtn.Font = Enum.Font.Gotham
goToPlotBtn.TextSize = 14
goToPlotBtn.BorderSizePixel = 0
goToPlotBtn.Parent = buttonContainer

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = goToPlotBtn

goToPlotBtn.MouseEnter:Connect(function()
    goToPlotBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)
goToPlotBtn.MouseLeave:Connect(function()
    goToPlotBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)
goToPlotBtn.MouseButton1Click:Connect(teleportToHome)

-- Tombol Remove Breakble Zone
local removeZoneBtn = Instance.new("TextButton")
removeZoneBtn.Size = UDim2.new(1, 0, 0, 30)
removeZoneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
removeZoneBtn.Text = "Remove Breakble Zone"
removeZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
removeZoneBtn.Font = Enum.Font.Gotham
removeZoneBtn.TextSize = 14
removeZoneBtn.BorderSizePixel = 0
removeZoneBtn.Parent = buttonContainer

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 4)
btnCorner2.Parent = removeZoneBtn

removeZoneBtn.MouseEnter:Connect(function()
    removeZoneBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)
removeZoneBtn.MouseLeave:Connect(function()
    removeZoneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)
removeZoneBtn.MouseButton1Click:Connect(removeBreakableZone)

-- Checkbox Auto Collect Cash
createCheckbox({
    Text = "Auto Collect Cash",
    Default = false,
    Callback = function(state)
        collectCashEnabled = state
        if state then
            -- refresh cache
            placesCache = nil
            getPlacesData()
        end
    end
})

-- Checkbox Auto Upgrade All
createCheckbox({
    Text = "Auto Upgrade All",
    Default = false,
    Callback = function(state)
        upgradeAllEnabled = state
        if state then
            placesCache = nil
            getPlacesData()
        end
    end
})

-- (Opsional) bisa tambahkan tombol lain jika diperlukan, tapi sesuai permintaan hanya ini.

-- ============================================================
-- EXPORT UI (optional)
-- ============================================================
local UI = {}
_G[guiName] = UI
