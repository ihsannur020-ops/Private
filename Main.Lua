-- Script Profesional untuk Delta Executor - AzkaUI
-- Support semua game, fitur lengkap, minim error

-- =====================================================
-- 1. Inisialisasi dan Environment Check
-- =====================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Tunggu player siap
if not player then
    player = Players.PlayerAdded:Wait()
end
local mouse = player:GetMouse()

-- Warna utama
local COLOR_PURPLE = Color3.fromRGB(138, 43, 226)   -- #8A2BE2
local COLOR_BG_DARK = Color3.fromRGB(20, 20, 25)    -- #141419
local COLOR_PANEL_DARK = Color3.fromRGB(30, 30, 38) -- #1E1E26
local COLOR_CONTENT_DARK = Color3.fromRGB(25, 25, 32) -- #191920

-- Hapus GUI lama jika ada (dengan aman)
local function cleanupOldGUI()
    local existing = CoreGui:FindFirstChild("AzkaUI")
    if existing then
        existing:Destroy()
    end
    if _G.AzkaUI and type(_G.AzkaUI) == "table" and _G.AzkaUI.Cleanup then
        pcall(_G.AzkaUI.Cleanup)
    end
    _G.AzkaUI = nil
end
cleanupOldGUI()

-- =====================================================
-- 2. Membuat ScreenGui baru
-- =====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AzkaUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- =====================================================
-- 3. State dan Variabel Global
-- =====================================================
local state = {
    isMinimized = false,
    currentMenu = "Main",
    currentTeleportSubMenu = "Custom",
    walkSpeed = 30,
    boost = 0,
    infJump = false,
    noclip = false,
    instantProximity = false,
    infiniteZoom = false,
    godMode = false,
    freecam = false,
    lockPosition = false,
    savedPositions = {},
    freecamActive = false,
    freecamCamera = nil,
    freecamKeys = { W = false, A = false, S = false, D = false, Space = false, Ctrl = false, Shift = false },
    originalCameraSubject = nil,
    originalCameraType = nil,
}

local connections = {}  -- untuk cleanup

local function addConnection(conn)
    table.insert(connections, conn)
end

-- =====================================================
-- 4. Fungsi Utility
-- =====================================================
local function makeRounded(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end

local function makeCircular(frame)
    makeRounded(frame, 1000)
end

local function addFullBorder(frame, color, thickness)
    -- border atas
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, thickness)
    top.Position = UDim2.new(0, 0, 0, 0)
    top.BackgroundColor3 = color
    top.BorderSizePixel = 0
    top.Parent = frame

    -- border bawah
    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, 0, 0, thickness)
    bottom.Position = UDim2.new(0, 0, 1, -thickness)
    bottom.BackgroundColor3 = color
    bottom.BorderSizePixel = 0
    bottom.Parent = frame

    -- border kiri
    local left = Instance.new("Frame")
    left.Size = UDim2.new(0, thickness, 1, -thickness*2)
    left.Position = UDim2.new(0, 0, 0, thickness)
    left.BackgroundColor3 = color
    left.BorderSizePixel = 0
    left.Parent = frame

    -- border kanan
    local right = Instance.new("Frame")
    right.Size = UDim2.new(0, thickness, 1, -thickness*2)
    right.Position = UDim2.new(1, -thickness, 0, thickness)
    right.BackgroundColor3 = color
    right.BorderSizePixel = 0
    right.Parent = frame
end

-- Fungsi membuat switch toggle (di pojok kanan)
local function createSwitch(parent, posY, initialState, callback)
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, 50, 0, 24)
    switchFrame.Position = UDim2.new(1, -60, 0, posY)
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

    local currentState = initialState
    addConnection(button.MouseButton1Click:Connect(function()
        currentState = not currentState
        switchFrame.BackgroundColor3 = currentState and COLOR_PURPLE or Color3.fromHex("#32323C")
        knob:TweenPosition(currentState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10), "Out", "Linear", 0.1)
        pcall(callback, currentState)  -- amankan callback
    end))

    return switchFrame
end

-- =====================================================
-- 5. Freecam Functions (diperbaiki)
-- =====================================================
local function startFreecam()
    if state.freecamActive then return end
    state.freecamActive = true

    -- Simpan state kamera asli
    state.originalCameraType = Camera.CameraType
    state.originalCameraSubject = Camera.CameraSubject

    -- Anchor karakter
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        if root then
            root.Anchored = true
        end
    end

    -- Buat kamera freecam
    if not state.freecamCamera then
        state.freecamCamera = Instance.new("Camera")
    end
    state.freecamCamera.CFrame = Camera.CFrame
    state.freecamCamera.Parent = screenGui
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CameraSubject = nil
    Camera.CFrame = state.freecamCamera.CFrame

    -- Loop gerakan
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not state.freecamActive then
            conn:Disconnect()
            return
        end

        local move = Vector3.new()
        if state.freecamKeys.W then move = move + state.freecamCamera.CFrame.LookVector end
        if state.freecamKeys.S then move = move - state.freecamCamera.CFrame.LookVector end
        if state.freecamKeys.A then move = move - state.freecamCamera.CFrame.RightVector end
        if state.freecamKeys.D then move = move + state.freecamCamera.CFrame.RightVector end
        if state.freecamKeys.Space then move = move + Vector3.new(0, 1, 0) end
        if state.freecamKeys.Ctrl then move = move + Vector3.new(0, -1, 0) end

        local speed = state.freecamKeys.Shift and 30 or 10
        if move.Magnitude > 0 then
            state.freecamCamera.CFrame = state.freecamCamera.CFrame + move * speed * RunService.RenderStepped.DeltaTime
            Camera.CFrame = state.freecamCamera.CFrame
        end
    end)
    addConnection(conn)
end

local function stopFreecam()
    if not state.freecamActive then return end
    state.freecamActive = false

    -- Unanchor karakter
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        if root then
            root.Anchored = false
        end
    end

    -- Kembalikan kamera
    Camera.CameraType = state.originalCameraType or Enum.CameraType.Custom
    Camera.CameraSubject = state.originalCameraSubject
    if state.freecamCamera then
        state.freecamCamera.Parent = nil
    end
end

-- Keyboard handling untuk freecam
addConnection(UserInputService.InputBegan:Connect(function(input, gpe)
    if not state.freecamActive or gpe then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then state.freecamKeys.W = true
    elseif key == Enum.KeyCode.A then state.freecamKeys.A = true
    elseif key == Enum.KeyCode.S then state.freecamKeys.S = true
    elseif key == Enum.KeyCode.D then state.freecamKeys.D = true
    elseif key == Enum.KeyCode.Space then state.freecamKeys.Space = true
    elseif key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.RightControl then state.freecamKeys.Ctrl = true
    elseif key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift then state.freecamKeys.Shift = true
    end
end))

addConnection(UserInputService.InputEnded:Connect(function(input, gpe)
    if not state.freecamActive or gpe then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then state.freecamKeys.W = false
    elseif key == Enum.KeyCode.A then state.freecamKeys.A = false
    elseif key == Enum.KeyCode.S then state.freecamKeys.S = false
    elseif key == Enum.KeyCode.D then state.freecamKeys.D = false
    elseif key == Enum.KeyCode.Space then state.freecamKeys.Space = false
    elseif key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.RightControl then state.freecamKeys.Ctrl = false
    elseif key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift then state.freecamKeys.Shift = false
    end
end))

-- =====================================================
-- 6. God Mode Helper
-- =====================================================
local function applyGodMode(character)
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid.BreakJointsOnDeath = false
    end
end

-- =====================================================
-- 7. Loop Utama untuk Fitur Berulang
-- =====================================================
addConnection(RunService.RenderStepped:Connect(function()
    -- WalkSpeed + Boost
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = state.walkSpeed + state.boost
        end
    end

    -- Infinite Zoom
    if state.infiniteZoom then
        Camera.MaxZoomDistance = 1e9
        Camera.MinZoomDistance = 0.5
    else
        Camera.MaxZoomDistance = 400
        Camera.MinZoomDistance = 0.5
    end

    -- God Mode (reinforce)
    if state.godMode and character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
            humanoid.BreakJointsOnDeath = false
        end
    end

    -- Noclip
    if state.noclip and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Instant Proximity
    if state.instantProximity then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
    end

    -- Lock Position
    if state.lockPosition and not state.freecamActive and character then
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        if root then
            root.Anchored = true
        end
    elseif character and not state.lockPosition then
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        if root then
            root.Anchored = false
        end
    end
end))

-- Inf Jump
addConnection(UserInputService.JumpRequest:Connect(function()
    if state.infJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState("Jumping")
    end
end))

-- =====================================================
-- 8. Membuat Frame Utama
-- =====================================================
local function createMainFrame()
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 600, 0, 450)
    frame.Position = UDim2.new(0.5, -300, 0.5, -225) -- tengah layar
    frame.BackgroundColor3 = COLOR_BG_DARK
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.Parent = screenGui
    makeRounded(frame, 12)
    addFullBorder(frame, COLOR_PURPLE, 2)

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, -4, 0, 36)
    titleBar.Position = UDim2.new(0, 2, 0, 2)
    titleBar.BackgroundColor3 = Color3.fromHex("#23232D")
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    makeRounded(titleBar, 12)
    -- Hanya sudut atas
    titleBar:FindFirstChild("UICorner").CornerRadius = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel")
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

    -- Panel Kiri
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 130, 0, 380)
    leftPanel.Position = UDim2.new(0, 12, 0, 52)
    leftPanel.BackgroundColor3 = COLOR_PANEL_DARK
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = frame
    makeRounded(leftPanel, 10)
    addFullBorder(leftPanel, COLOR_PURPLE, 2)

    local btnMain = Instance.new("TextButton")
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

    -- Panel Kanan
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(0, 430, 0, 380)
    rightPanel.Position = UDim2.new(0, 157, 0, 52)
    rightPanel.BackgroundColor3 = COLOR_CONTENT_DARK
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = frame
    makeRounded(rightPanel, 10)
    addFullBorder(rightPanel, COLOR_PURPLE, 2)

    -- =====================================================
    -- KONTEN MAIN
    -- =====================================================
    local contentMain = Instance.new("ScrollingFrame")
    contentMain.Size = UDim2.new(1, -20, 1, -20)
    contentMain.Position = UDim2.new(0, 10, 0, 10)
    contentMain.BackgroundTransparency = 1
    contentMain.BorderSizePixel = 0
    contentMain.CanvasSize = UDim2.new(0, 0, 0, 500)
    contentMain.ScrollBarThickness = 6
    contentMain.ScrollBarImageColor3 = COLOR_PURPLE
    contentMain.Visible = (state.currentMenu == "Main")
    contentMain.Parent = rightPanel

    local function buildMainContent()
        local y = 0

        -- WalkSpeed
        local wsTitle = Instance.new("TextLabel")
        wsTitle.Size = UDim2.new(0, 150, 0, 30)
        wsTitle.Position = UDim2.new(0, 0, 0, y)
        wsTitle.BackgroundTransparency = 1
        wsTitle.Text = "WalkSpeed"
        wsTitle.TextColor3 = COLOR_PURPLE
        wsTitle.TextSize = 18
        wsTitle.Font = Enum.Font.GothamBold
        wsTitle.TextXAlignment = Enum.TextXAlignment.Left
        wsTitle.Parent = contentMain

        local wsValue = Instance.new("TextLabel")
        wsValue.Size = UDim2.new(0, 80, 0, 30)
        wsValue.Position = UDim2.new(1, -90, 0, y)
        wsValue.BackgroundTransparency = 1
        wsValue.Text = tostring(state.walkSpeed)
        wsValue.TextColor3 = COLOR_PURPLE
        wsValue.TextSize = 18
        wsValue.Font = Enum.Font.GothamBold
        wsValue.TextXAlignment = Enum.TextXAlignment.Right
        wsValue.Parent = contentMain

        y = y + 35

        -- Slider WalkSpeed
        local wsTrack = Instance.new("Frame")
        wsTrack.Size = UDim2.new(1, -20, 0, 6)
        wsTrack.Position = UDim2.new(0, 0, 0, y)
        wsTrack.BackgroundColor3 = Color3.fromHex("#3C3C46")
        wsTrack.BorderSizePixel = 0
        wsTrack.Parent = contentMain
        makeRounded(wsTrack, 3)
        addFullBorder(wsTrack, COLOR_PURPLE, 1)

        local wsFill = Instance.new("Frame")
        wsFill.Size = UDim2.new((state.walkSpeed - 30) / (200 - 30), 0, 1, 0)
        wsFill.BackgroundColor3 = COLOR_PURPLE
        wsFill.BorderSizePixel = 0
        wsFill.Parent = wsTrack
        makeRounded(wsFill, 3)

        local wsKnob = Instance.new("ImageButton")
        wsKnob.Size = UDim2.new(0, 16, 0, 16)
        wsKnob.Position = UDim2.new((state.walkSpeed - 30) / (200 - 30), -8, 0.5, -8)
        wsKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        wsKnob.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        wsKnob.ImageTransparency = 1
        wsKnob.BorderSizePixel = 1
        wsKnob.BorderColor3 = COLOR_PURPLE
        wsKnob.Parent = wsTrack
        makeCircular(wsKnob)

        y = y + 25

        -- Boost
        local boostTitle = Instance.new("TextLabel")
        boostTitle.Size = UDim2.new(0, 150, 0, 30)
        boostTitle.Position = UDim2.new(0, 0, 0, y)
        boostTitle.BackgroundTransparency = 1
        boostTitle.Text = "Boost"
        boostTitle.TextColor3 = COLOR_PURPLE
        boostTitle.TextSize = 18
        boostTitle.Font = Enum.Font.GothamBold
        boostTitle.TextXAlignment = Enum.TextXAlignment.Left
        boostTitle.Parent = contentMain

        local boostValue = Instance.new("TextLabel")
        boostValue.Size = UDim2.new(0, 80, 0, 30)
        boostValue.Position = UDim2.new(1, -90, 0, y)
        boostValue.BackgroundTransparency = 1
        boostValue.Text = tostring(state.boost)
        boostValue.TextColor3 = COLOR_PURPLE
        boostValue.TextSize = 18
        boostValue.Font = Enum.Font.GothamBold
        boostValue.TextXAlignment = Enum.TextXAlignment.Right
        boostValue.Parent = contentMain

        local totalSpeed = Instance.new("TextLabel")
        totalSpeed.Size = UDim2.new(1, -20, 0, 20)
        totalSpeed.Position = UDim2.new(0, 0, 0, y + 30)
        totalSpeed.BackgroundTransparency = 1
        totalSpeed.Text = "Total: " .. (state.walkSpeed + state.boost)
        totalSpeed.TextColor3 = COLOR_PURPLE
        totalSpeed.TextSize = 14
        totalSpeed.Font = Enum.Font.GothamBold
        totalSpeed.TextXAlignment = Enum.TextXAlignment.Left
        totalSpeed.Parent = contentMain

        y = y + 55

        -- Slider Boost
        local boostTrack = Instance.new("Frame")
        boostTrack.Size = UDim2.new(1, -20, 0, 6)
        boostTrack.Position = UDim2.new(0, 0, 0, y)
        boostTrack.BackgroundColor3 = Color3.fromHex("#3C3C46")
        boostTrack.BorderSizePixel = 0
        boostTrack.Parent = contentMain
        makeRounded(boostTrack, 3)
        addFullBorder(boostTrack, COLOR_PURPLE, 1)

        local boostFill = Instance.new("Frame")
        boostFill.Size = UDim2.new(state.boost / 500, 0, 1, 0)
        boostFill.BackgroundColor3 = COLOR_PURPLE
        boostFill.BorderSizePixel = 0
        boostFill.Parent = boostTrack
        makeRounded(boostFill, 3)

        local boostKnob = Instance.new("ImageButton")
        boostKnob.Size = UDim2.new(0, 16, 0, 16)
        boostKnob.Position = UDim2.new(state.boost / 500, -8, 0.5, -8)
        boostKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        boostKnob.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        boostKnob.ImageTransparency = 1
        boostKnob.BorderSizePixel = 1
        boostKnob.BorderColor3 = COLOR_PURPLE
        boostKnob.Parent = boostTrack
        makeCircular(boostKnob)

        y = y + 25

        -- Fitur-fitur dengan switch
        local features = {
            { name = "Inf Jump", y = y },
            { name = "Noclip", y = y + 35 },
            { name = "Instant Proximity", y = y + 70 },
            { name = "Infinite Zoom", y = y + 105 },
            { name = "God Mode", y = y + 140 },
            { name = "Freecam", y = y + 175 },
            { name = "Lock Position", y = y + 210 }
        }

        for _, feat in ipairs(features) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 200, 0, 30)
            label.Position = UDim2.new(0, 0, 0, feat.y)
            label.BackgroundTransparency = 1
            label.Text = feat.name
            label.TextColor3 = COLOR_PURPLE
            label.TextSize = 16
            label.Font = Enum.Font.GothamBold
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = contentMain
        end

        -- Switches
        createSwitch(contentMain, y, state.infJump, function(v) state.infJump = v end)
        createSwitch(contentMain, y + 35, state.noclip, function(v) state.noclip = v end)
        createSwitch(contentMain, y + 70, state.instantProximity, function(v) state.instantProximity = v end)
        createSwitch(contentMain, y + 105, state.infiniteZoom, function(v) state.infiniteZoom = v end)
        createSwitch(contentMain, y + 140, state.godMode, function(v)
            state.godMode = v
            if v and player.Character then
                applyGodMode(player.Character)
            end
        end)
        createSwitch(contentMain, y + 175, state.freecam, function(v)
            state.freecam = v
            if v then
                startFreecam()
            else
                stopFreecam()
            end
        end)
        createSwitch(contentMain, y + 210, state.lockPosition, function(v) state.lockPosition = v end)

        -- Slider event handlers
        local wsDragging = false
        addConnection(wsKnob.MouseButton1Down:Connect(function() wsDragging = true end))
        addConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then wsDragging = false end
        end))
        addConnection(UserInputService.InputChanged:Connect(function(input)
            if wsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = wsTrack.AbsolutePosition
                local size = wsTrack.AbsoluteSize.X
                local rel = math.clamp(mouse.X - pos.X, 0, size)
                local val = 30 + (rel / size) * (200 - 30)
                state.walkSpeed = math.floor(val)
                wsValue.Text = tostring(state.walkSpeed)
                wsFill.Size = UDim2.new((state.walkSpeed - 30) / (200 - 30), 0, 1, 0)
                wsKnob.Position = UDim2.new((state.walkSpeed - 30) / (200 - 30), -8, 0.5, -8)
                totalSpeed.Text = "Total: " .. (state.walkSpeed + state.boost)
            end
        end))

        addConnection(wsTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = wsTrack.AbsolutePosition
                local size = wsTrack.AbsoluteSize.X
                local rel = math.clamp(mouse.X - pos.X, 0, size)
                local val = 30 + (rel / size) * (200 - 30)
                state.walkSpeed = math.floor(val)
                wsValue.Text = tostring(state.walkSpeed)
                wsFill.Size = UDim2.new((state.walkSpeed - 30) / (200 - 30), 0, 1, 0)
                wsKnob.Position = UDim2.new((state.walkSpeed - 30) / (200 - 30), -8, 0.5, -8)
                totalSpeed.Text = "Total: " .. (state.walkSpeed + state.boost)
            end
        end))

        local boostDragging = false
        addConnection(boostKnob.MouseButton1Down:Connect(function() boostDragging = true end))
        addConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then boostDragging = false end
        end))
        addConnection(UserInputService.InputChanged:Connect(function(input)
            if boostDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = boostTrack.AbsolutePosition
                local size = boostTrack.AbsoluteSize.X
                local rel = math.clamp(mouse.X - pos.X, 0, size)
                local val = (rel / size) * 500
                state.boost = math.floor(val)
                boostValue.Text = tostring(state.boost)
                boostFill.Size = UDim2.new(state.boost / 500, 0, 1, 0)
                boostKnob.Position = UDim2.new(state.boost / 500, -8, 0.5, -8)
                totalSpeed.Text = "Total: " .. (state.walkSpeed + state.boost)
            end
        end))

        addConnection(boostTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = boostTrack.AbsolutePosition
                local size = boostTrack.AbsoluteSize.X
                local rel = math.clamp(mouse.X - pos.X, 0, size)
                local val = (rel / size) * 500
                state.boost = math.floor(val)
                boostValue.Text = tostring(state.boost)
                boostFill.Size = UDim2.new(state.boost / 500, 0, 1, 0)
                boostKnob.Position = UDim2.new(state.boost / 500, -8, 0.5, -8)
                totalSpeed.Text = "Total: " .. (state.walkSpeed + state.boost)
            end
        end))

        contentMain.CanvasSize = UDim2.new(0, 0, 0, y + 250)
    end

    buildMainContent()

    -- =====================================================
    -- KONTEN TELEPORT (Tanpa Switch)
    -- =====================================================
    local contentTele = Instance.new("Frame")
    contentTele.Size = UDim2.new(1, -20, 1, -20)
    contentTele.Position = UDim2.new(0, 10, 0, 10)
    contentTele.BackgroundTransparency = 1
    contentTele.Visible = (state.currentMenu == "Teleport")
    contentTele.Parent = rightPanel

    local tabCustom = Instance.new("TextButton")
    tabCustom.Size = UDim2.new(0, 200, 0, 30)
    tabCustom.Position = UDim2.new(0, 0, 0, 0)
    tabCustom.BackgroundColor3 = COLOR_PURPLE
    tabCustom.Text = "Custom Teleport"
    tabCustom.TextColor3 = Color3.new(1, 1, 1)
    tabCustom.TextSize = 16
    tabCustom.Font = Enum.Font.GothamBold
    tabCustom.AutoButtonColor = false
    tabCustom.Parent = contentTele
    makeRounded(tabCustom, 6)

    local tabPlayer = Instance.new("TextButton")
    tabPlayer.Size = UDim2.new(0, 200, 0, 30)
    tabPlayer.Position = UDim2.new(0, 210, 0, 0)
    tabPlayer.BackgroundColor3 = Color3.fromHex("#32323C")
    tabPlayer.Text = "Player Teleport"
    tabPlayer.TextColor3 = Color3.new(1, 1, 1)
    tabPlayer.TextSize = 16
    tabPlayer.Font = Enum.Font.GothamBold
    tabPlayer.AutoButtonColor = false
    tabPlayer.Parent = contentTele
    makeRounded(tabPlayer, 6)

    -- Custom Teleport Content
    local customContent = Instance.new("Frame")
    customContent.Size = UDim2.new(1, 0, 1, -40)
    customContent.Position = UDim2.new(0, 0, 0, 40)
    customContent.BackgroundTransparency = 1
    customContent.Visible = (state.currentTeleportSubMenu == "Custom")
    customContent.Parent = contentTele

    local saveBox = Instance.new("TextBox")
    saveBox.Size = UDim2.new(0, 200, 0, 30)
    saveBox.Position = UDim2.new(0, 0, 0, 10)
    saveBox.PlaceholderText = "Position Name"
    saveBox.Text = ""
    saveBox.BackgroundColor3 = Color3.fromHex("#32323C")
    saveBox.TextColor3 = Color3.new(1, 1, 1)
    saveBox.PlaceholderColor3 = Color3.fromRGB(150,150,150)
    saveBox.Parent = customContent
    makeRounded(saveBox, 6)
    addFullBorder(saveBox, COLOR_PURPLE, 1)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 100, 0, 30)
    saveBtn.Position = UDim2.new(0, 210, 0, 10)
    saveBtn.BackgroundColor3 = COLOR_PURPLE
    saveBtn.Text = "Save"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Parent = customContent
    makeRounded(saveBtn, 6)

    local posList = Instance.new("ScrollingFrame")
    posList.Size = UDim2.new(1, 0, 0, 280)
    posList.Position = UDim2.new(0, 0, 0, 50)
    posList.BackgroundColor3 = Color3.fromHex("#32323C")
    posList.BorderSizePixel = 0
    posList.CanvasSize = UDim2.new(0, 0, 0, 0)
    posList.ScrollBarThickness = 6
    posList.ScrollBarImageColor3 = COLOR_PURPLE
    posList.Parent = customContent
    makeRounded(posList, 6)
    addFullBorder(posList, COLOR_PURPLE, 1)

    local function updatePosList()
        for _, child in ipairs(posList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local y = 0
        for name, pos in pairs(state.savedPositions) do
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, -10, 0, 40)
            item.Position = UDim2.new(0, 5, 0, y)
            item.BackgroundColor3 = Color3.fromHex("#1E1E26")
            item.BorderSizePixel = 0
            item.Parent = posList
            makeRounded(item, 4)
            addFullBorder(item, COLOR_PURPLE, 1)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 200, 0, 20)
            nameLabel.Position = UDim2.new(0, 5, 0, 2)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.TextColor3 = COLOR_PURPLE
            nameLabel.TextSize = 16
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = item

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 70, 0, 25)
            tpBtn.Position = UDim2.new(1, -120, 0.5, -12.5)
            tpBtn.BackgroundColor3 = COLOR_PURPLE
            tpBtn.Text = "Teleport"
            tpBtn.TextColor3 = Color3.new(1, 1, 1)
            tpBtn.TextSize = 12
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.Parent = item
            makeRounded(tpBtn, 4)

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0, 50, 0, 25)
            delBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
            delBtn.BackgroundColor3 = Color3.fromHex("#C83232")
            delBtn.Text = "Delete"
            delBtn.TextColor3 = Color3.new(1, 1, 1)
            delBtn.TextSize = 12
            delBtn.Font = Enum.Font.GothamBold
            delBtn.Parent = item
            makeRounded(delBtn, 4)

            addConnection(tpBtn.MouseButton1Click:Connect(function()
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                    if root then
                        root.CFrame = pos
                    end
                end
            end))

            addConnection(delBtn.MouseButton1Click:Connect(function()
                state.savedPositions[name] = nil
                updatePosList()
            end))

            y = y + 45
        end
        posList.CanvasSize = UDim2.new(0, 0, 0, y)
    end

    addConnection(saveBtn.MouseButton1Click:Connect(function()
        local name = saveBox.Text
        if name ~= "" then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                if root then
                    state.savedPositions[name] = root.CFrame
                    saveBox.Text = ""
                    updatePosList()
                end
            end
        end
    end))

    -- Player Teleport Content
    local playerContent = Instance.new("Frame")
    playerContent.Size = UDim2.new(1, 0, 1, -40)
    playerContent.Position = UDim2.new(0, 0, 0, 40)
    playerContent.BackgroundTransparency = 1
    playerContent.Visible = (state.currentTeleportSubMenu == "Player")
    playerContent.Parent = contentTele

    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(1, 0, 1, -10)
    playerList.Position = UDim2.new(0, 0, 0, 10)
    playerList.BackgroundColor3 = Color3.fromHex("#32323C")
    playerList.BorderSizePixel = 0
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerList.ScrollBarThickness = 6
    playerList.ScrollBarImageColor3 = COLOR_PURPLE
    playerList.Parent = playerContent
    makeRounded(playerList, 6)
    addFullBorder(playerList, COLOR_PURPLE, 1)

    local function updatePlayerList()
        for _, child in ipairs(playerList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local y = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, -10, 0, 40)
                item.Position = UDim2.new(0, 5, 0, y)
                item.BackgroundColor3 = Color3.fromHex("#1E1E26")
                item.BorderSizePixel = 0
                item.Parent = playerList
                makeRounded(item, 4)
                addFullBorder(item, COLOR_PURPLE, 1)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0, 150, 0, 20)
                nameLabel.Position = UDim2.new(0, 5, 0, 2)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = plr.Name
                nameLabel.TextColor3 = COLOR_PURPLE
                nameLabel.TextSize = 16
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Parent = item

                local displayLabel = Instance.new("TextLabel")
                displayLabel.Size = UDim2.new(0, 150, 0, 15)
                displayLabel.Position = UDim2.new(0, 5, 0, 22)
                displayLabel.BackgroundTransparency = 1
                displayLabel.Text = "Display: " .. plr.DisplayName
                displayLabel.TextColor3 = Color3.fromRGB(200,200,200)
                displayLabel.TextSize = 12
                displayLabel.Font = Enum.Font.Gotham
                displayLabel.TextXAlignment = Enum.TextXAlignment.Left
                displayLabel.Parent = item

                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0, 70, 0, 25)
                tpBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
                tpBtn.BackgroundColor3 = COLOR_PURPLE
                tpBtn.Text = "Teleport"
                tpBtn.TextColor3 = Color3.new(1, 1, 1)
                tpBtn.TextSize = 12
                tpBtn.Font = Enum.Font.GothamBold
                tpBtn.Parent = item
                makeRounded(tpBtn, 4)

                addConnection(tpBtn.MouseButton1Click:Connect(function()
                    if plr.Character and player.Character then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
                        local myRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
                        if targetRoot and myRoot then
                            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
                        end
                    end
                end))

                y = y + 45
            end
        end
        playerList.CanvasSize = UDim2.new(0, 0, 0, y)
    end

    updatePlayerList()
    addConnection(Players.PlayerAdded:Connect(updatePlayerList))
    addConnection(Players.PlayerRemoving:Connect(updatePlayerList))

    addConnection(tabCustom.MouseButton1Click:Connect(function()
        state.currentTeleportSubMenu = "Custom"
        tabCustom.BackgroundColor3 = COLOR_PURPLE
        tabPlayer.BackgroundColor3 = Color3.fromHex("#32323C")
        customContent.Visible = true
        playerContent.Visible = false
        updatePosList()
    end))

    addConnection(tabPlayer.MouseButton1Click:Connect(function()
        state.currentTeleportSubMenu = "Player"
        tabCustom.BackgroundColor3 = Color3.fromHex("#32323C")
        tabPlayer.BackgroundColor3 = COLOR_PURPLE
        customContent.Visible = false
        playerContent.Visible = true
        updatePlayerList()
    end))

    -- =====================================================
    -- KONTEN SETTING (Coming Soon)
    -- =====================================================
    local contentSet = Instance.new("Frame")
    contentSet.Size = UDim2.new(1, -20, 1, -20)
    contentSet.Position = UDim2.new(0, 10, 0, 10)
    contentSet.BackgroundTransparency = 1
    contentSet.Visible = (state.currentMenu == "Setting")
    contentSet.Parent = rightPanel

    local setLabel = Instance.new("TextLabel")
    setLabel.Size = UDim2.new(1, 0, 1, 0)
    setLabel.BackgroundTransparency = 1
    setLabel.Text = "Coming Soon"
    setLabel.TextColor3 = COLOR_PURPLE
    setLabel.TextSize = 24
    setLabel.Font = Enum.Font.GothamBold
    setLabel.Parent = contentSet

    -- =====================================================
    -- Navigasi Menu
    -- =====================================================
    local function setMenu(menu)
        state.currentMenu = menu
        btnMain.BackgroundColor3 = (menu == "Main") and COLOR_PURPLE or Color3.fromHex("#32323C")
        btnTele.BackgroundColor3 = (menu == "Teleport") and COLOR_PURPLE or Color3.fromHex("#32323C")
        btnSet.BackgroundColor3 = (menu == "Setting") and COLOR_PURPLE or Color3.fromHex("#32323C")
        contentMain.Visible = (menu == "Main")
        contentTele.Visible = (menu == "Teleport")
        contentSet.Visible = (menu == "Setting")
    end

    addConnection(btnMain.MouseButton1Click:Connect(function() setMenu("Main") end))
    addConnection(btnTele.MouseButton1Click:Connect(function() setMenu("Teleport") end))
    addConnection(btnSet.MouseButton1Click:Connect(function() setMenu("Setting") end))

    -- =====================================================
    -- Drag Utama
    -- =====================================================
    local dragToggle = false
    local dragStart, framePos

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

    -- Tombol Close
    addConnection(closeBtn.MouseButton1Click:Connect(function()
        _G.AzkaUI.Cleanup()
    end))

    -- Tombol Minimize
    addConnection(minBtn.MouseButton1Click:Connect(function()
        state.isMinimized = true
        frame.Visible = false
        createMiniFrame(frame.Position)
    end))

    return frame
end

-- =====================================================
-- 9. Mini Frame (Minimized)
-- =====================================================
local function createMiniFrame(pos)
    if miniFrame and miniFrame.Parent then
        miniFrame:Destroy()
    end

    miniFrame = Instance.new("Frame")
    miniFrame.Name = "MiniFrame"
    miniFrame.Size = UDim2.new(0, 40, 0, 40)
    miniFrame.Position = pos or UDim2.new(0.5, -20, 0.5, -20)
    miniFrame.BackgroundColor3 = COLOR_BG_DARK
    miniFrame.BorderSizePixel = 2
    miniFrame.BorderColor3 = COLOR_PURPLE
    miniFrame.Parent = screenGui
    makeRounded(miniFrame, 8)

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
    local dragStart, framePos

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
                state.isMinimized = false
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
-- 10. Inisialisasi dan Cleanup Global
-- =====================================================
mainFrame = createMainFrame()

_G.AzkaUI = {
    Cleanup = function()
        stopFreecam()
        for _, conn in ipairs(connections) do
            pcall(conn.Disconnect, conn)
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

-- Pesan sukses
print("AzkaUI berhasil dimuat! Gunakan _G.AzkaUI.Cleanup() untuk menutup.")
