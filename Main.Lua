-- Script untuk Delta Executor - GUI Panel "AzkaUI" dengan fitur Lengkap
-- Warna biru diubah menjadi ungu (#8A2BE2)
-- Ditempatkan di CoreGui, dengan nama "AzkaUI"

-- =====================================================
-- 1. Inisialisasi dan Cleanup GUI lama
-- =====================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Warna utama ungu
local COLOR_PURPLE = Color3.fromHex("#8A2BE2")
local COLOR_PURPLE_DARK = Color3.fromHex("#6B1FA2")
local COLOR_BG_DARK = Color3.fromHex("#141419")
local COLOR_PANEL_DARK = Color3.fromHex("#1E1E26")
local COLOR_CONTENT_DARK = Color3.fromHex("#191920")

-- Hapus GUI lama jika ada
local existingGui = CoreGui:FindFirstChild("AzkaUI")
if existingGui then
    existingGui:Destroy()
end

if _G.AzkaUI and type(_G.AzkaUI) == "table" and _G.AzkaUI.Cleanup then
    _G.AzkaUI.Cleanup()
end

-- =====================================================
-- 2. Membuat GUI baru
-- =====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AzkaUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Variabel global state
local isMinimized = false
local mainFrame
local miniFrame
local currentMenu = "Main"
local currentTeleportSubMenu = "Custom" -- "Custom" atau "Player"

-- Variabel untuk WalkSpeed & Boost
local walkSpeedValue = 30
local boostValue = 0
local function getEffectiveWalkSpeed()
    return walkSpeedValue + boostValue
end

-- Variabel fitur
local infJumpEnabled = false
local noclipEnabled = false
local instantProximityEnabled = false
local unlockCameraEnabled = false
local godModeEnabled = false
local freecamEnabled = false
local lockPositionEnabled = false

-- Freecam variables
local freecamActive = false
local freecamCamera = Instance.new("Camera")
local freecamConnection = nil
local freecamSpeed = 10
local freecamShiftSpeed = 30
local freecamKeys = {
    W = false, A = false, S = false, D = false,
    Space = false, Ctrl = false, Shift = false
}

-- Saved positions
local savedPositions = {}

-- Player list
local playerList = {}

-- Tabel untuk menyimpan semua koneksi
local connections = {}

local function addConnection(conn)
    table.insert(connections, conn)
end

-- =====================================================
-- 3. Fungsi Utility
-- =====================================================
local function makeCircular(frame)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
end

local function makeRounded(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end

-- Fungsi untuk membuat switch toggle
local function createSwitch(parent, posX, posY, initialState, callback)
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, 50, 0, 24)
    switchFrame.Position = UDim2.new(0, posX, 0, posY)
    switchFrame.BackgroundColor3 = initialState and COLOR_PURPLE or Color3.fromHex("#32323C")
    switchFrame.BorderSizePixel = 0
    switchFrame.Parent = parent
    makeRounded(switchFrame, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = initialState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = switchFrame
    makeCircular(knob)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = switchFrame

    local state = initialState
    addConnection(button.MouseButton1Click:Connect(function()
        state = not state
        switchFrame.BackgroundColor3 = state and COLOR_PURPLE or Color3.fromHex("#32323C")
        knob:TweenPosition(state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10), "Out", "Linear", 0.1)
        callback(state)
    end))

    return switchFrame
end

-- =====================================================
-- 4. Membuat frame utama
-- =====================================================
local function createMainFrame()
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 600, 0, 450)
    frame.Position = UDim2.new(0.5, -300, 0.5, -225)
    frame.BackgroundColor3 = COLOR_BG_DARK
    frame.BorderSizePixel = 2
    frame.BorderColor3 = COLOR_PURPLE
    frame.ClipsDescendants = false
    frame.Parent = screenGui
    makeRounded(frame, 12)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromHex("#23232D")
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    makeRounded(titleBar, 12)
    -- Hanya sudut atas yang rounded
    titleBar:FindFirstChild("UICorner").CornerRadius = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Script BY Azka"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromHex("#C83232")
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar
    makeRounded(closeBtn, 6)

    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -70, 0.5, -15)
    minBtn.BackgroundColor3 = COLOR_PURPLE
    minBtn.Text = "-"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.TextSize = 24
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar
    makeRounded(minBtn, 6)

    -- Panel kiri dengan garis pembatas di semua sisi
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 130, 0, 380)
    leftPanel.Position = UDim2.new(0, 10, 0, 50)
    leftPanel.BackgroundColor3 = COLOR_PANEL_DARK
    leftPanel.BorderSizePixel = 2
    leftPanel.BorderColor3 = COLOR_PURPLE
    leftPanel.Parent = frame
    makeRounded(leftPanel, 10)

    local btnMain = Instance.new("TextButton")
    btnMain.Name = "MenuMain"
    btnMain.Size = UDim2.new(0, 110, 0, 40)
    btnMain.Position = UDim2.new(0, 10, 0, 10)
    btnMain.BackgroundColor3 = COLOR_PURPLE
    btnMain.Text = "Main"
    btnMain.TextColor3 = Color3.new(1, 1, 1)
    btnMain.TextSize = 16
    btnMain.Font = Enum.Font.GothamBold
    btnMain.AutoButtonColor = false
    btnMain.Parent = leftPanel
    makeRounded(btnMain, 6)

    local btnTele = Instance.new("TextButton")
    btnTele.Name = "MenuTeleport"
    btnTele.Size = UDim2.new(0, 110, 0, 40)
    btnTele.Position = UDim2.new(0, 10, 0, 60)
    btnTele.BackgroundColor3 = Color3.fromHex("#32323C")
    btnTele.Text = "Teleport"
    btnTele.TextColor3 = Color3.new(1, 1, 1)
    btnTele.TextSize = 16
    btnTele.Font = Enum.Font.GothamBold
    btnTele.AutoButtonColor = false
    btnTele.Parent = leftPanel
    makeRounded(btnTele, 6)

    local btnSet = Instance.new("TextButton")
    btnSet.Name = "MenuSetting"
    btnSet.Size = UDim2.new(0, 110, 0, 40)
    btnSet.Position = UDim2.new(0, 10, 0, 110)
    btnSet.BackgroundColor3 = Color3.fromHex("#32323C")
    btnSet.Text = "Setting"
    btnSet.TextColor3 = Color3.new(1, 1, 1)
    btnSet.TextSize = 16
    btnSet.Font = Enum.Font.GothamBold
    btnSet.AutoButtonColor = false
    btnSet.Parent = leftPanel
    makeRounded(btnSet, 6)

    -- Garis pemisah vertikal (UNGU)
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(0, 2, 0, 350)
    separator.Position = UDim2.new(0, 145, 0, 50)
    separator.BackgroundColor3 = COLOR_PURPLE
    separator.BorderSizePixel = 0
    separator.Parent = frame

    -- Panel kanan dengan garis pembatas di semua sisi
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(0, 430, 0, 380)
    rightPanel.Position = UDim2.new(0, 155, 0, 50)
    rightPanel.BackgroundColor3 = COLOR_CONTENT_DARK
    rightPanel.BorderSizePixel = 2
    rightPanel.BorderColor3 = COLOR_PURPLE
    rightPanel.Parent = frame
    makeRounded(rightPanel, 10)

    -- =====================================================
    -- KONTEN MAIN
    -- =====================================================
    local contentMain = Instance.new("ScrollingFrame")
    contentMain.Name = "ContentMain"
    contentMain.Size = UDim2.new(1, -20, 1, -20)
    contentMain.Position = UDim2.new(0, 10, 0, 10)
    contentMain.BackgroundTransparency = 1
    contentMain.BorderSizePixel = 0
    contentMain.CanvasSize = UDim2.new(0, 0, 0, 500)
    contentMain.ScrollBarThickness = 6
    contentMain.ScrollBarImageColor3 = COLOR_PURPLE
    contentMain.Visible = (currentMenu == "Main")
    contentMain.Parent = rightPanel

    local function createMainContent()
        local yPos = 0
        
        -- WalkSpeed Section
        local wsTitle = Instance.new("TextLabel")
        wsTitle.Size = UDim2.new(0, 150, 0, 30)
        wsTitle.Position = UDim2.new(0, 0, 0, yPos)
        wsTitle.BackgroundTransparency = 1
        wsTitle.Text = "WalkSpeed"
        wsTitle.TextColor3 = Color3.new(1, 1, 1)
        wsTitle.TextSize = 18
        wsTitle.Font = Enum.Font.GothamBold
        wsTitle.TextXAlignment = Enum.TextXAlignment.Left
        wsTitle.Parent = contentMain

        local wsValue = Instance.new("TextLabel")
        wsValue.Size = UDim2.new(0, 80, 0, 30)
        wsValue.Position = UDim2.new(1, -90, 0, yPos)
        wsValue.BackgroundTransparency = 1
        wsValue.Text = tostring(walkSpeedValue)
        wsValue.TextColor3 = COLOR_PURPLE
        wsValue.TextSize = 18
        wsValue.Font = Enum.Font.GothamBold
        wsValue.TextXAlignment = Enum.TextXAlignment.Right
        wsValue.Parent = contentMain

        yPos = yPos + 35

        -- Slider WalkSpeed
        local wsTrack = Instance.new("Frame")
        wsTrack.Size = UDim2.new(1, -20, 0, 6)
        wsTrack.Position = UDim2.new(0, 0, 0, yPos)
        wsTrack.BackgroundColor3 = Color3.fromHex("#3C3C46")
        wsTrack.BorderSizePixel = 2
        wsTrack.BorderColor3 = COLOR_PURPLE
        wsTrack.Parent = contentMain
        makeRounded(wsTrack, 3)

        local wsFill = Instance.new("Frame")
        wsFill.Name = "WSFill"
        wsFill.Size = UDim2.new((walkSpeedValue - 30) / (200 - 30), 0, 1, 0)
        wsFill.BackgroundColor3 = COLOR_PURPLE
        wsFill.BorderSizePixel = 0
        wsFill.Parent = wsTrack
        makeRounded(wsFill, 3)

        local wsKnob = Instance.new("ImageButton")
        wsKnob.Name = "WSKnob"
        wsKnob.Size = UDim2.new(0, 16, 0, 16)
        wsKnob.Position = UDim2.new((walkSpeedValue - 30) / (200 - 30), -8, 0.5, -8)
        wsKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        wsKnob.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        wsKnob.ImageTransparency = 1
        wsKnob.BorderSizePixel = 2
        wsKnob.BorderColor3 = COLOR_PURPLE
        wsKnob.Parent = wsTrack
        makeCircular(wsKnob)

        yPos = yPos + 25

        -- Boost Section
        local boostTitle = Instance.new("TextLabel")
        boostTitle.Size = UDim2.new(0, 150, 0, 30)
        boostTitle.Position = UDim2.new(0, 0, 0, yPos)
        boostTitle.BackgroundTransparency = 1
        boostTitle.Text = "Boost"
        boostTitle.TextColor3 = Color3.new(1, 1, 1)
        boostTitle.TextSize = 18
        boostTitle.Font = Enum.Font.GothamBold
        boostTitle.TextXAlignment = Enum.TextXAlignment.Left
        boostTitle.Parent = contentMain

        local boostValueLabel = Instance.new("TextLabel")
        boostValueLabel.Size = UDim2.new(0, 80, 0, 30)
        boostValueLabel.Position = UDim2.new(1, -90, 0, yPos)
        boostValueLabel.BackgroundTransparency = 1
        boostValueLabel.Text = tostring(boostValue)
        boostValueLabel.TextColor3 = COLOR_PURPLE
        boostValueLabel.TextSize = 18
        boostValueLabel.Font = Enum.Font.GothamBold
        boostValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        boostValueLabel.Parent = contentMain

        local totalSpeedLabel = Instance.new("TextLabel")
        totalSpeedLabel.Size = UDim2.new(1, -20, 0, 20)
        totalSpeedLabel.Position = UDim2.new(0, 0, 0, yPos + 30)
        totalSpeedLabel.BackgroundTransparency = 1
        totalSpeedLabel.Text = "Total: " .. getEffectiveWalkSpeed()
        totalSpeedLabel.TextColor3 = COLOR_PURPLE
        totalSpeedLabel.TextSize = 14
        totalSpeedLabel.Font = Enum.Font.Gotham
        totalSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
        totalSpeedLabel.Parent = contentMain

        yPos = yPos + 55

        -- Boost Slider
        local boostTrack = Instance.new("Frame")
        boostTrack.Size = UDim2.new(1, -20, 0, 6)
        boostTrack.Position = UDim2.new(0, 0, 0, yPos)
        boostTrack.BackgroundColor3 = Color3.fromHex("#3C3C46")
        boostTrack.BorderSizePixel = 2
        boostTrack.BorderColor3 = COLOR_PURPLE
        boostTrack.Parent = contentMain
        makeRounded(boostTrack, 3)

        local boostFill = Instance.new("Frame")
        boostFill.Name = "BoostFill"
        boostFill.Size = UDim2.new(boostValue / 500, 0, 1, 0)
        boostFill.BackgroundColor3 = COLOR_PURPLE
        boostFill.BorderSizePixel = 0
        boostFill.Parent = boostTrack
        makeRounded(boostFill, 3)

        local boostKnob = Instance.new("ImageButton")
        boostKnob.Name = "BoostKnob"
        boostKnob.Size = UDim2.new(0, 16, 0, 16)
        boostKnob.Position = UDim2.new(boostValue / 500, -8, 0.5, -8)
        boostKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        boostKnob.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        boostKnob.ImageTransparency = 1
        boostKnob.BorderSizePixel = 2
        boostKnob.BorderColor3 = COLOR_PURPLE
        boostKnob.Parent = boostTrack
        makeCircular(boostKnob)

        yPos = yPos + 25

        -- Fitur-fitur dengan Switch
        local features = {
            {name = "Inf Jump", y = yPos},
            {name = "Noclip", y = yPos + 35},
            {name = "Instant Proximity", y = yPos + 70},
            {name = "Unlock Camera", y = yPos + 105},
            {name = "God Mode", y = yPos + 140},
            {name = "Freecam", y = yPos + 175},
            {name = "Lock Position", y = yPos + 210}
        }

        for _, feat in ipairs(features) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 150, 0, 30)
            label.Position = UDim2.new(0, 0, 0, feat.y)
            label.BackgroundTransparency = 1
            label.Text = feat.name
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextSize = 16
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = contentMain
        end

        -- Switches
        local infSwitch = createSwitch(contentMain, 250, yPos, infJumpEnabled, function(state)
            infJumpEnabled = state
        end)

        local noclipSwitch = createSwitch(contentMain, 250, yPos + 35, noclipEnabled, function(state)
            noclipEnabled = state
        end)

        local proxSwitch = createSwitch(contentMain, 250, yPos + 70, instantProximityEnabled, function(state)
            instantProximityEnabled = state
        end)

        local unlockSwitch = createSwitch(contentMain, 250, yPos + 105, unlockCameraEnabled, function(state)
            unlockCameraEnabled = state
            if state then
                Camera.MaxZoomDistance = math.huge
                Camera.MinZoomDistance = 0.5
            else
                Camera.MaxZoomDistance = 400
                Camera.MinZoomDistance = 0.5
            end
        end)

        local godSwitch = createSwitch(contentMain, 250, yPos + 140, godModeEnabled, function(state)
            godModeEnabled = state
        end)

        local freecamSwitch = createSwitch(contentMain, 250, yPos + 175, freecamEnabled, function(state)
            freecamEnabled = state
            if state then
                startFreecam()
            else
                stopFreecam()
            end
        end)

        local lockSwitch = createSwitch(contentMain, 250, yPos + 210, lockPositionEnabled, function(state)
            lockPositionEnabled = state
        end)

        -- Slider functions
        local wsDragging = false
        addConnection(wsKnob.MouseButton1Down:Connect(function() wsDragging = true end))
        addConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then wsDragging = false end
        end))
        addConnection(UserInputService.InputChanged:Connect(function(input)
            if wsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local localPos = wsTrack.AbsolutePosition
                local sizeX = wsTrack.AbsoluteSize.X
                local mouseX = mouse.X
                local relX = math.clamp(mouseX - localPos.X, 0, sizeX)
                local newVal = 30 + (relX / sizeX) * (200 - 30)
                walkSpeedValue = math.floor(newVal)
                wsValue.Text = tostring(walkSpeedValue)
                wsFill.Size = UDim2.new((walkSpeedValue - 30) / (200 - 30), 0, 1, 0)
                wsKnob.Position = UDim2.new((walkSpeedValue - 30) / (200 - 30), -8, 0.5, -8)
                totalSpeedLabel.Text = "Total: " .. getEffectiveWalkSpeed()
            end
        end))

        -- Click to set
        addConnection(wsTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local localPos = wsTrack.AbsolutePosition
                local sizeX = wsTrack.AbsoluteSize.X
                local mouseX = mouse.X
                local relX = math.clamp(mouseX - localPos.X, 0, sizeX)
                local newVal = 30 + (relX / sizeX) * (200 - 30)
                walkSpeedValue = math.floor(newVal)
                wsValue.Text = tostring(walkSpeedValue)
                wsFill.Size = UDim2.new((walkSpeedValue - 30) / (200 - 30), 0, 1, 0)
                wsKnob.Position = UDim2.new((walkSpeedValue - 30) / (200 - 30), -8, 0.5, -8)
                totalSpeedLabel.Text = "Total: " .. getEffectiveWalkSpeed()
            end
        end))

        local boostDragging = false
        addConnection(boostKnob.MouseButton1Down:Connect(function() boostDragging = true end))
        addConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then boostDragging = false end
        end))
        addConnection(UserInputService.InputChanged:Connect(function(input)
            if boostDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local localPos = boostTrack.AbsolutePosition
                local sizeX = boostTrack.AbsoluteSize.X
                local mouseX = mouse.X
                local relX = math.clamp(mouseX - localPos.X, 0, sizeX)
                local newVal = (relX / sizeX) * 500
                boostValue = math.floor(newVal)
                boostValueLabel.Text = tostring(boostValue)
                boostFill.Size = UDim2.new(boostValue / 500, 0, 1, 0)
                boostKnob.Position = UDim2.new(boostValue / 500, -8, 0.5, -8)
                totalSpeedLabel.Text = "Total: " .. getEffectiveWalkSpeed()
            end
        end))

        addConnection(boostTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local localPos = boostTrack.AbsolutePosition
                local sizeX = boostTrack.AbsoluteSize.X
                local mouseX = mouse.X
                local relX = math.clamp(mouseX - localPos.X, 0, sizeX)
                local newVal = (relX / sizeX) * 500
                boostValue = math.floor(newVal)
                boostValueLabel.Text = tostring(boostValue)
                boostFill.Size = UDim2.new(boostValue / 500, 0, 1, 0)
                boostKnob.Position = UDim2.new(boostValue / 500, -8, 0.5, -8)
                totalSpeedLabel.Text = "Total: " .. getEffectiveWalkSpeed()
            end
        end))

        contentMain.CanvasSize = UDim2.new(0, 0, 0, yPos + 250)
    end

    createMainContent()

    -- =====================================================
    -- KONTEN TELEPORT
    -- =====================================================
    local contentTele = Instance.new("Frame")
    contentTele.Name = "ContentTeleport"
    contentTele.Size = UDim2.new(1, -20, 1, -20)
    contentTele.Position = UDim2.new(0, 10, 0, 10)
    contentTele.BackgroundTransparency = 1
    contentTele.Visible = (currentMenu == "Teleport")
    contentTele.Parent = rightPanel

    local teleTabCustom = Instance.new("TextButton")
    teleTabCustom.Size = UDim2.new(0, 200, 0, 30)
    teleTabCustom.Position = UDim2.new(0, 0, 0, 0)
    teleTabCustom.BackgroundColor3 = COLOR_PURPLE
    teleTabCustom.Text = "Custom Teleport"
    teleTabCustom.TextColor3 = Color3.new(1, 1, 1)
    teleTabCustom.TextSize = 16
    teleTabCustom.Font = Enum.Font.GothamBold
    teleTabCustom.AutoButtonColor = false
    teleTabCustom.Parent = contentTele
    makeRounded(teleTabCustom, 6)

    local teleTabPlayer = Instance.new("TextButton")
    teleTabPlayer.Size = UDim2.new(0, 200, 0, 30)
    teleTabPlayer.Position = UDim2.new(0, 210, 0, 0)
    teleTabPlayer.BackgroundColor3 = Color3.fromHex("#32323C")
    teleTabPlayer.Text = "Player Teleport"
    teleTabPlayer.TextColor3 = Color3.new(1, 1, 1)
    teleTabPlayer.TextSize = 16
    teleTabPlayer.Font = Enum.Font.GothamBold
    teleTabPlayer.AutoButtonColor = false
    teleTabPlayer.Parent = contentTele
    makeRounded(teleTabPlayer, 6)

    -- Custom Teleport Content
    local customContent = Instance.new("Frame")
    customContent.Size = UDim2.new(1, 0, 1, -40)
    customContent.Position = UDim2.new(0, 0, 0, 40)
    customContent.BackgroundTransparency = 1
    customContent.Visible = (currentTeleportSubMenu == "Custom")
    customContent.Parent = contentTele

    -- Player Teleport Content
    local playerContent = Instance.new("Frame")
    playerContent.Size = UDim2.new(1, 0, 1, -40)
    playerContent.Position = UDim2.new(0, 0, 0, 40)
    playerContent.BackgroundTransparency = 1
    playerContent.Visible = (currentTeleportSubMenu == "Player")
    playerContent.Parent = contentTele

    -- Custom Teleport UI
    local saveNameBox = Instance.new("TextBox")
    saveNameBox.Size = UDim2.new(0, 200, 0, 30)
    saveNameBox.Position = UDim2.new(0, 0, 0, 10)
    saveNameBox.PlaceholderText = "Position Name"
    saveNameBox.Text = ""
    saveNameBox.BackgroundColor3 = Color3.fromHex("#32323C")
    saveNameBox.TextColor3 = Color3.new(1, 1, 1)
    saveNameBox.Parent = customContent
    makeRounded(saveNameBox, 6)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 100, 0, 30)
    saveBtn.Position = UDim2.new(0, 210, 0, 10)
    saveBtn.BackgroundColor3 = COLOR_PURPLE
    saveBtn.Text = "Save"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Parent = customContent
    makeRounded(saveBtn, 6)

    local posList = Instance.new("ScrollingFrame")
    posList.Size = UDim2.new(1, 0, 0, 200)
    posList.Position = UDim2.new(0, 0, 0, 50)
    posList.BackgroundColor3 = Color3.fromHex("#32323C")
    posList.BorderSizePixel = 2
    posList.BorderColor3 = COLOR_PURPLE
    posList.CanvasSize = UDim2.new(0, 0, 0, 0)
    posList.ScrollBarThickness = 6
    posList.ScrollBarImageColor3 = COLOR_PURPLE
    posList.Parent = customContent
    makeRounded(posList, 6)

    local function updatePosList()
        for _, child in ipairs(posList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local y = 0
        for name, pos in pairs(savedPositions) do
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, -10, 0, 30)
            item.Position = UDim2.new(0, 5, 0, y)
            item.BackgroundColor3 = Color3.fromHex("#1E1E26")
            item.BorderSizePixel = 2
            item.BorderColor3 = COLOR_PURPLE
            item.Parent = posList
            makeRounded(item, 4)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 150, 1, 0)
            nameLabel.Position = UDim2.new(0, 5, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = item

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 60, 0, 20)
            tpBtn.Position = UDim2.new(1, -125, 0.5, -10)
            tpBtn.BackgroundColor3 = COLOR_PURPLE
            tpBtn.Text = "TP"
            tpBtn.TextColor3 = Color3.new(1, 1, 1)
            tpBtn.TextSize = 12
            tpBtn.Parent = item
            makeRounded(tpBtn, 4)

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0, 60, 0, 20)
            delBtn.Position = UDim2.new(1, -60, 0.5, -10)
            delBtn.BackgroundColor3 = Color3.fromHex("#C83232")
            delBtn.Text = "Del"
            delBtn.TextColor3 = Color3.new(1, 1, 1)
            delBtn.TextSize = 12
            delBtn.Parent = item
            makeRounded(delBtn, 4)

            addConnection(tpBtn.MouseButton1Click:Connect(function()
                if player.Character and player.Character.PrimaryPart then
                    player.Character.PrimaryPart.CFrame = pos
                end
            end))

            addConnection(delBtn.MouseButton1Click:Connect(function()
                savedPositions[name] = nil
                updatePosList()
            end))

            y = y + 35
        end
        posList.CanvasSize = UDim2.new(0, 0, 0, y)
    end

    addConnection(saveBtn.MouseButton1Click:Connect(function()
        if saveNameBox.Text ~= "" and player.Character and player.Character.PrimaryPart then
            savedPositions[saveNameBox.Text] = player.Character.PrimaryPart.CFrame
            saveNameBox.Text = ""
            updatePosList()
        end
    end))

    -- Player Teleport UI
    local playerListFrame = Instance.new("ScrollingFrame")
    playerListFrame.Size = UDim2.new(1, 0, 1, -10)
    playerListFrame.Position = UDim2.new(0, 0, 0, 10)
    playerListFrame.BackgroundColor3 = Color3.fromHex("#32323C")
    playerListFrame.BorderSizePixel = 2
    playerListFrame.BorderColor3 = COLOR_PURPLE
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerListFrame.ScrollBarThickness = 6
    playerListFrame.ScrollBarImageColor3 = COLOR_PURPLE
    playerListFrame.Parent = playerContent
    makeRounded(playerListFrame, 6)

    local function updatePlayerList()
        for _, child in ipairs(playerListFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local y = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, -10, 0, 40)
                item.Position = UDim2.new(0, 5, 0, y)
                item.BackgroundColor3 = Color3.fromHex("#1E1E26")
                item.BorderSizePixel = 2
                item.BorderColor3 = COLOR_PURPLE
                item.Parent = playerListFrame
                makeRounded(item, 4)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0, 150, 0, 20)
                nameLabel.Position = UDim2.new(0, 5, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = plr.Name
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Parent = item

                local idLabel = Instance.new("TextLabel")
                idLabel.Size = UDim2.new(0, 150, 0, 15)
                idLabel.Position = UDim2.new(0, 5, 0, 20)
                idLabel.BackgroundTransparency = 1
                idLabel.Text = "ID: " .. plr.UserId
                idLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                idLabel.TextSize = 12
                idLabel.TextXAlignment = Enum.TextXAlignment.Left
                idLabel.Parent = item

                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0, 80, 0, 30)
                tpBtn.Position = UDim2.new(1, -90, 0.5, -15)
                tpBtn.BackgroundColor3 = COLOR_PURPLE
                tpBtn.Text = "TP"
                tpBtn.TextColor3 = Color3.new(1, 1, 1)
                tpBtn.Parent = item
                makeRounded(tpBtn, 4)

                addConnection(tpBtn.MouseButton1Click:Connect(function()
                    if plr.Character and plr.Character.PrimaryPart and player.Character and player.Character.PrimaryPart then
                        player.Character.PrimaryPart.CFrame = plr.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -3)
                    end
                end))

                y = y + 45
            end
        end
        playerListFrame.CanvasSize = UDim2.new(0, 0, 0, y)
    end

    updatePlayerList()
    addConnection(Players.PlayerAdded:Connect(updatePlayerList))
    addConnection(Players.PlayerRemoving:Connect(updatePlayerList))

    addConnection(teleTabCustom.MouseButton1Click:Connect(function()
        currentTeleportSubMenu = "Custom"
        teleTabCustom.BackgroundColor3 = COLOR_PURPLE
        teleTabPlayer.BackgroundColor3 = Color3.fromHex("#32323C")
        customContent.Visible = true
        playerContent.Visible = false
    end))

    addConnection(teleTabPlayer.MouseButton1Click:Connect(function()
        currentTeleportSubMenu = "Player"
        teleTabCustom.BackgroundColor3 = Color3.fromHex("#32323C")
        teleTabPlayer.BackgroundColor3 = COLOR_PURPLE
        customContent.Visible = false
        playerContent.Visible = true
        updatePlayerList()
    end))

    -- =====================================================
    -- KONTEN SETTING (Coming Soon)
    -- =====================================================
    local contentSet = Instance.new("Frame")
    contentSet.Name = "ContentSetting"
    contentSet.Size = UDim2.new(1, -20, 1, -20)
    contentSet.Position = UDim2.new(0, 10, 0, 10)
    contentSet.BackgroundTransparency = 1
    contentSet.Visible = (currentMenu == "Setting")
    contentSet.Parent = rightPanel

    local setLabel = Instance.new("TextLabel")
    setLabel.Size = UDim2.new(1, 0, 1, 0)
    setLabel.BackgroundTransparency = 1
    setLabel.Text = "Coming Soon"
    setLabel.TextColor3 = Color3.new(1, 1, 1)
    setLabel.TextSize = 24
    setLabel.Font = Enum.Font.GothamBold
    setLabel.Parent = contentSet

    -- =====================================================
    -- Fungsi Menu
    -- =====================================================
    local function setActiveMenu(menuName)
        currentMenu = menuName
        btnMain.BackgroundColor3 = (menuName == "Main") and COLOR_PURPLE or Color3.fromHex("#32323C")
        btnTele.BackgroundColor3 = (menuName == "Teleport") and COLOR_PURPLE or Color3.fromHex("#32323C")
        btnSet.BackgroundColor3 = (menuName == "Setting") and COLOR_PURPLE or Color3.fromHex("#32323C")
        contentMain.Visible = (menuName == "Main")
        contentTele.Visible = (menuName == "Teleport")
        contentSet.Visible = (menuName == "Setting")
    end

    addConnection(btnMain.MouseButton1Click:Connect(function() setActiveMenu("Main") end))
    addConnection(btnTele.MouseButton1Click:Connect(function() setActiveMenu("Teleport") end))
    addConnection(btnSet.MouseButton1Click:Connect(function() setActiveMenu("Setting") end))

    -- =====================================================
    -- Drag Utama
    -- =====================================================
    local dragToggle = false
    local dragStart = nil
    local framePos = nil

    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end

    local function updateDrag(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end

    addConnection(titleBar.InputBegan:Connect(startDrag))
    addConnection(UserInputService.InputChanged:Connect(updateDrag))

    -- Tombol close
    addConnection(closeBtn.MouseButton1Click:Connect(function()
        _G.AzkaUI.Cleanup()
    end))

    -- Tombol minimize
    addConnection(minBtn.MouseButton1Click:Connect(function()
        isMinimized = true
        frame.Visible = false
        createMiniFrame(frame.Position)
    end))

    return frame
end

-- =====================================================
-- 5. Freecam Functions
-- =====================================================
function startFreecam()
    if freecamActive then return end
    freecamActive = true
    
    local character = player.Character
    if character then
        character.HumanoidRootPart.Anchored = true
    end
    
    freecamCamera.CFrame = Camera.CFrame
    freecamCamera.Parent = screenGui
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = freecamCamera.CFrame
    
    freecamConnection = RunService.RenderStepped:Connect(function()
        local moveVector = Vector3.new()
        if freecamKeys.W then moveVector = moveVector + Camera.CFrame.LookVector end
        if freecamKeys.S then moveVector = moveVector - Camera.CFrame.LookVector end
        if freecamKeys.A then moveVector = moveVector - Camera.CFrame.RightVector end
        if freecamKeys.D then moveVector = moveVector + Camera.CFrame.RightVector end
        if freecamKeys.Space then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if freecamKeys.Ctrl then moveVector = moveVector + Vector3.new(0, -1, 0) end
        
        local speed = freecamKeys.Shift and freecamShiftSpeed or freecamSpeed
        if moveVector.Magnitude > 0 then
            freecamCamera.CFrame = freecamCamera.CFrame + moveVector * speed * RunService.RenderStepped.DeltaTime
            Camera.CFrame = freecamCamera.CFrame
        end
    end)
end

function stopFreecam()
    if not freecamActive then return end
    freecamActive = false
    
    local character = player.Character
    if character then
        character.HumanoidRootPart.Anchored = false
    end
    
    if freecamConnection then
        freecamConnection:Disconnect()
        freecamConnection = nil
    end
    
    Camera.CameraType = Enum.CameraType.Custom
    freecamCamera.Parent = nil
end

-- Keyboard handling for freecam
addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not freecamActive or gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then freecamKeys.W = true
    elseif input.KeyCode == Enum.KeyCode.A then freecamKeys.A = true
    elseif input.KeyCode == Enum.KeyCode.S then freecamKeys.S = true
    elseif input.KeyCode == Enum.KeyCode.D then freecamKeys.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then freecamKeys.Space = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then freecamKeys.Ctrl = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then freecamKeys.Shift = true
    end
end))

addConnection(UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not freecamActive or gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then freecamKeys.W = false
    elseif input.KeyCode == Enum.KeyCode.A then freecamKeys.A = false
    elseif input.KeyCode == Enum.KeyCode.S then freecamKeys.S = false
    elseif input.KeyCode == Enum.KeyCode.D then freecamKeys.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then freecamKeys.Space = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then freecamKeys.Ctrl = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then freecamKeys.Shift = false
    end
end))

-- =====================================================
-- 6. Mini Frame (Minimized)
-- =====================================================
local function createMiniFrame(mainPos)
    if miniFrame and miniFrame.Parent then
        miniFrame:Destroy()
    end
    
    miniFrame = Instance.new("Frame")
    miniFrame.Name = "MiniFrame"
    miniFrame.Size = UDim2.new(0, 40, 0, 40)
    miniFrame.Position = mainPos or UDim2.new(1, -50, 0, 50)
    miniFrame.BackgroundColor3 = COLOR_BG_DARK
    miniFrame.BorderSizePixel = 2
    miniFrame.BorderColor3 = COLOR_PURPLE
    miniFrame.Parent = screenGui
    makeCircular(miniFrame) -- Membuat frame kecil berbentuk lingkaran

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "☰"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.Parent = miniFrame

    -- Drag mini frame
    local dragToggle = false
    local dragStart = nil
    local framePos = nil

    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            framePos = miniFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end

    local function updateDrag(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            miniFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end

    addConnection(miniFrame.InputBegan:Connect(startDrag))
    addConnection(UserInputService.InputChanged:Connect(updateDrag))

    -- Klik untuk restore
    addConnection(miniFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.wait(0.2)
            if not dragToggle then
                isMinimized = false
                local restorePos = miniFrame.Position
                miniFrame:Destroy()
                if mainFrame then
                    mainFrame.Position = restorePos
                    mainFrame.Visible = true
                end
            end
        end
    end))
end

-- =====================================================
-- 7. Apply WalkSpeed & Boost secara periodik
-- =====================================================
addConnection(RunService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        humanoid.WalkSpeed = getEffectiveWalkSpeed()
    end
end))

-- =====================================================
-- 8. Instant Proximity
-- =====================================================
addConnection(RunService.Stepped:Connect(function()
    if instantProximityEnabled then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
    end
end))

-- =====================================================
-- 9. God Mode
-- =====================================================
addConnection(player.CharacterAdded:Connect(function(character)
    if godModeEnabled then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid.BreakJointsOnDeath = false
    end
end))

addConnection(RunService.Stepped:Connect(function()
    if godModeEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid.BreakJointsOnDeath = false
    end
end))

-- =====================================================
-- 10. Lock Position
-- =====================================================
addConnection(RunService.RenderStepped:Connect(function()
    if lockPositionEnabled and player.Character and player.Character.PrimaryPart then
        player.Character.PrimaryPart.Anchored = true
    elseif player.Character and player.Character.PrimaryPart then
        player.Character.PrimaryPart.Anchored = false
    end
end))

-- =====================================================
-- 11. Noclip
-- =====================================================
addConnection(RunService.Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

-- =====================================================
-- 12. Membuat GUI dan Cleanup
-- =====================================================
mainFrame = createMainFrame()

_G.AzkaUI = {
    Cleanup = function()
        stopFreecam()
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        connections = {}
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        mainFrame = nil
        miniFrame = nil
        _G.AzkaUI = nil
    end
}
