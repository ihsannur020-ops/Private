--[[
	Script BY Azka - Ultimate Controller
	Fitur: WalkSpeed (1-200) + Boost (0-500), Inf Jump, Noclip, Fly UI, Teleport UI
	Modern Minimalist UI, draggable, replace on re-execute
]]

-- Hapus GUI lama jika sudah ada
local CoreGui = game:GetService("CoreGui")
local guiName = "ScriptBYAzka"
local flyGUIName = "AzkaFlyUI"
local tpGUIName = "AzkaTeleportUI"
local existingMain = CoreGui:FindFirstChild(guiName)
local existingFly = CoreGui:FindFirstChild(flyGUIName)
local existingTP = CoreGui:FindFirstChild(tpGUIName)
if existingMain then existingMain:Destroy() end
if existingFly then existingFly:Destroy() end
if existingTP then existingTP:Destroy() end

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Helper: wait for humanoid
local function waitForHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    while not hum do
        char = player.Character or player.CharacterAdded:Wait()
        hum = char:FindFirstChildWhichIsA("Humanoid")
        task.wait(0.05)
    end
    return hum
end

-- Draggable function
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- ========== MAIN MENU ==========
local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

-- Main panel (height increased to 160 to fit two rows)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(300, 160)
panel.Position = UDim2.new(0.5, -150, 0.4, -80)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
panel.Parent = gui

local corner = Instance.new("UICorner", panel)
corner.CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", panel)
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(80, 120, 255)
stroke.Transparency = 0.25

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
titleBar.Parent = panel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamSemibold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(230, 235, 255)
title.Text = "Script BY Azka"
title.Parent = titleBar

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Name = "Minimize"
minBtn.Size = UDim2.fromOffset(36, 24)
minBtn.Position = UDim2.new(1, -84, 0.5, -12)
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
minBtn.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.fromOffset(36, 24)
closeBtn.Position = UDim2.new(1, -44, 0.5, -12)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.Parent = titleBar

-- Body container
local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, -24, 1, -36)
body.Position = UDim2.new(0, 12, 0, 34)
body.BackgroundTransparency = 1
body.Parent = panel

-- ===== WalkSpeed Slider =====
local wsLabel = Instance.new("TextLabel")
wsLabel.BackgroundTransparency = 1
wsLabel.Size = UDim2.new(1, 0, 0, 20)
wsLabel.TextXAlignment = Enum.TextXAlignment.Left
wsLabel.Font = Enum.Font.Gotham
wsLabel.TextSize = 14
wsLabel.TextColor3 = Color3.fromRGB(210, 215, 230)
wsLabel.Text = "WalkSpeed"
wsLabel.Parent = body

local wsValue = Instance.new("TextLabel")
wsValue.BackgroundTransparency = 1
wsValue.Size = UDim2.new(0, 60, 0, 20)
wsValue.Position = UDim2.new(1, -60, 0, 0)
wsValue.TextXAlignment = Enum.TextXAlignment.Right
wsValue.Font = Enum.Font.GothamMedium
wsValue.TextSize = 14
wsValue.TextColor3 = Color3.fromRGB(180, 220, 255)
wsValue.Text = "1"
wsValue.Parent = body

local wsTrack = Instance.new("Frame")
wsTrack.Name = "WSTrack"
wsTrack.Size = UDim2.new(1, 0, 0, 8)
wsTrack.Position = UDim2.new(0, 0, 0, 22)
wsTrack.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
Instance.new("UICorner", wsTrack).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", wsTrack).Color = Color3.fromRGB(80, 120, 255)
wsTrack.Parent = body

local wsFill = Instance.new("Frame")
wsFill.Name = "WSFill"
wsFill.Size = UDim2.new(0, 0, 1, 0)
wsFill.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
Instance.new("UICorner", wsFill).CornerRadius = UDim.new(0, 6)
wsFill.Parent = wsTrack

local wsKnob = Instance.new("Frame")
wsKnob.Name = "WSKnob"
wsKnob.Size = UDim2.fromOffset(16, 16)
wsKnob.Position = UDim2.new(0, -8, 0.5, -8)
wsKnob.BackgroundColor3 = Color3.fromRGB(220, 230, 255)
Instance.new("UICorner", wsKnob).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", wsKnob).Color = Color3.fromRGB(40, 70, 160)
wsKnob.Parent = wsTrack

-- ===== Boost Slider =====
local boostLabel = Instance.new("TextLabel")
boostLabel.BackgroundTransparency = 1
boostLabel.Size = UDim2.new(1, 0, 0, 20)
boostLabel.Position = UDim2.new(0, 0, 0, 38)
boostLabel.TextXAlignment = Enum.TextXAlignment.Left
boostLabel.Font = Enum.Font.Gotham
boostLabel.TextSize = 14
boostLabel.TextColor3 = Color3.fromRGB(210, 215, 230)
boostLabel.Text = "Boost"
boostLabel.Parent = body

local boostValue = Instance.new("TextLabel")
boostValue.BackgroundTransparency = 1
boostValue.Size = UDim2.new(0, 60, 0, 20)
boostValue.Position = UDim2.new(1, -60, 0, 38)
boostValue.TextXAlignment = Enum.TextXAlignment.Right
boostValue.Font = Enum.Font.GothamMedium
boostValue.TextSize = 14
boostValue.TextColor3 = Color3.fromRGB(180, 220, 255)
boostValue.Text = "0"
boostValue.Parent = body

local boostTrack = Instance.new("Frame")
boostTrack.Name = "BoostTrack"
boostTrack.Size = UDim2.new(1, 0, 0, 8)
boostTrack.Position = UDim2.new(0, 0, 0, 60)
boostTrack.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
Instance.new("UICorner", boostTrack).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", boostTrack).Color = Color3.fromRGB(80, 120, 255)
boostTrack.Parent = body

local boostFill = Instance.new("Frame")
boostFill.Name = "BoostFill"
boostFill.Size = UDim2.new(0, 0, 1, 0)
boostFill.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
Instance.new("UICorner", boostFill).CornerRadius = UDim.new(0, 6)
boostFill.Parent = boostTrack

local boostKnob = Instance.new("Frame")
boostKnob.Name = "BoostKnob"
boostKnob.Size = UDim2.fromOffset(16, 16)
boostKnob.Position = UDim2.new(0, -8, 0.5, -8)
boostKnob.BackgroundColor3 = Color3.fromRGB(220, 230, 255)
Instance.new("UICorner", boostKnob).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", boostKnob).Color = Color3.fromRGB(40, 70, 160)
boostKnob.Parent = boostTrack

-- ===== Row 1: Inf Jump & Noclip =====
local row1 = Instance.new("Frame")
row1.Size = UDim2.new(1, 0, 0, 22)
row1.Position = UDim2.new(0, 0, 0, 78)
row1.BackgroundTransparency = 1
row1.Parent = body

local layout1 = Instance.new("UIListLayout", row1)
layout1.FillDirection = Enum.FillDirection.Horizontal
layout1.Padding = UDim.new(0, 8)
layout1.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout1.VerticalAlignment = Enum.VerticalAlignment.Center

local function makeToggle(name, labelText, width)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, width or 90, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.TextColor3 = Color3.fromRGB(210, 215, 230)
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Text = labelText .. ": OFF"
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(80, 120, 255)
    btn.Parent = row1
    return btn
end

local infJumpBtn = makeToggle("InfJumpBtn", "Inf Jump", 100)
local noclipBtn  = makeToggle("NoclipBtn" , "Noclip", 100)

-- ===== Row 2: Fly UI & TP UI =====
local row2 = Instance.new("Frame")
row2.Size = UDim2.new(1, 0, 0, 22)
row2.Position = UDim2.new(0, 0, 0, 108) -- 78+22+8
row2.BackgroundTransparency = 1
row2.Parent = body

local layout2 = Instance.new("UIListLayout", row2)
layout2.FillDirection = Enum.FillDirection.Horizontal
layout2.Padding = UDim.new(0, 8)
layout2.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout2.VerticalAlignment = Enum.VerticalAlignment.Center

local flyUIBtn   = makeToggle("FlyUIBtn"  , "Fly UI", 100)
local tpUIBtn    = makeToggle("TPUIBtn"   , "TP UI", 100)

-- (Credit dihapus sesuai permintaan)

-- Shoe icon minimized button (for main menu)
local shoe = Instance.new("TextButton")
shoe.Name = "ShoeIcon"
shoe.Visible = false
shoe.Text = "👟"
shoe.Font = Enum.Font.GothamBold
shoe.TextSize = 20
shoe.Size = UDim2.fromOffset(40, 40)
shoe.Position = UDim2.new(0.5, -20, 0.45, -20)
shoe.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
shoe.TextColor3 = Color3.fromRGB(220, 230, 255)
Instance.new("UICorner", shoe).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", shoe).Color = Color3.fromRGB(80, 120, 255)
shoe.Parent = gui

-- Draggable
makeDraggable(panel, titleBar)
makeDraggable(shoe, shoe)

-- ===== Slider Logic =====
local MIN_WS = 1
local MAX_WS = 200
local MIN_BOOST = 0
local MAX_BOOST = 500
local currentWS = MIN_WS
local currentBoost = MIN_BOOST

local draggingWS = false
local draggingBoost = false

-- WS slider
local function setWSFromX(x)
    local absX = math.clamp(x - wsTrack.AbsolutePosition.X, 0, wsTrack.AbsoluteSize.X)
    local alpha = absX / wsTrack.AbsoluteSize.X
    local val = math.floor(MIN_WS + alpha * (MAX_WS - MIN_WS) + 0.5)
    currentWS = math.clamp(val, MIN_WS, MAX_WS)
    wsValue.Text = tostring(currentWS)
    wsFill.Size = UDim2.new(alpha, 0, 1, 0)
    wsKnob.Position = UDim2.new(alpha, -8, 0.5, -8)
end

wsTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingWS = true
        setWSFromX(input.Position.X)
    end
end)

wsKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingWS = true
    end
end)

-- Boost slider
local function setBoostFromX(x)
    local absX = math.clamp(x - boostTrack.AbsolutePosition.X, 0, boostTrack.AbsoluteSize.X)
    local alpha = absX / boostTrack.AbsoluteSize.X
    local val = math.floor(MIN_BOOST + alpha * (MAX_BOOST - MIN_BOOST) + 0.5)
    currentBoost = math.clamp(val, MIN_BOOST, MAX_BOOST)
    boostValue.Text = tostring(currentBoost)
    boostFill.Size = UDim2.new(alpha, 0, 1, 0)
    boostKnob.Position = UDim2.new(alpha, -8, 0.5, -8)
end

boostTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingBoost = true
        setBoostFromX(input.Position.X)
    end
end)

boostKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingBoost = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWS and (input.UserInputType == Enum.UserInputType.MouseMovement or
                       input.UserInputType == Enum.UserInputType.Touch) then
        setWSFromX(input.Position.X)
    end
    if draggingBoost and (input.UserInputType == Enum.UserInputType.MouseMovement or
                          input.UserInputType == Enum.UserInputType.Touch) then
        setBoostFromX(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingWS = false
        draggingBoost = false
    end
end)

-- Initialize sliders
setWSFromX(wsTrack.AbsolutePosition.X)
setBoostFromX(boostTrack.AbsolutePosition.X)

-- Minimize and close for main menu
minBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
    shoe.Visible = true
end)

shoe.MouseButton1Click:Connect(function()
    shoe.Visible = false
    panel.Visible = true
end)

-- ===== State variables =====
local running = true
local infJumpEnabled = false
local noclipEnabled = false
local flyUIVisible = false
local tpUIVisible = false

-- Toggle helpers
local function setToggle(btn, enabled)
    btn.TextColor3 = enabled and Color3.fromRGB(180, 255, 200) or Color3.fromRGB(210, 215, 230)
    btn.BackgroundColor3 = enabled and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
    btn.Text = btn.Text:gsub(": ON", ""):gsub(": OFF", "") .. (enabled and ": ON" or ": OFF")
end

infJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    setToggle(infJumpBtn, infJumpEnabled)
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    setToggle(noclipBtn, noclipEnabled)
end)

-- ========== FLY UI ==========
local function createFlyUI()
    local flyGui = Instance.new("ScreenGui")
    flyGui.Name = flyGUIName
    flyGui.ResetOnSpawn = false
    flyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    flyGui.Parent = CoreGui

    local flyFrame = Instance.new("Frame")
    flyFrame.Name = "FlyFrame"
    flyFrame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
    flyFrame.BorderColor3 = Color3.fromRGB(103, 221, 213)
    flyFrame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
    flyFrame.Size = UDim2.new(0, 190, 0, 57)
    flyFrame.Active = true
    flyFrame.Draggable = true
    flyFrame.Parent = flyGui
    flyFrame.Visible = false

    -- Buttons
    local up = Instance.new("TextButton")
    up.Name = "up"
    up.Parent = flyFrame
    up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
    up.Size = UDim2.new(0, 44, 0, 28)
    up.Font = Enum.Font.SourceSans
    up.Text = "UP"
    up.TextColor3 = Color3.fromRGB(0, 0, 0)
    up.TextSize = 14.000

    local down = Instance.new("TextButton")
    down.Name = "down"
    down.Parent = flyFrame
    down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
    down.Position = UDim2.new(0, 0, 0.491228074, 0)
    down.Size = UDim2.new(0, 44, 0, 28)
    down.Font = Enum.Font.SourceSans
    down.Text = "DOWN"
    down.TextColor3 = Color3.fromRGB(0, 0, 0)
    down.TextSize = 14.000

    local onof = Instance.new("TextButton")
    onof.Name = "onof"
    onof.Parent = flyFrame
    onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
    onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
    onof.Size = UDim2.new(0, 56, 0, 28)
    onof.Font = Enum.Font.SourceSans
    onof.Text = "fly"
    onof.TextColor3 = Color3.fromRGB(0, 0, 0)
    onof.TextSize = 14.000

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = flyFrame
    titleLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
    titleLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
    titleLabel.Size = UDim2.new(0, 100, 0, 28)
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.Text = "AzkaFLY"
    titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.TextScaled = true
    titleLabel.TextSize = 14.000
    titleLabel.TextWrapped = true

    local plus = Instance.new("TextButton")
    plus.Name = "plus"
    plus.Parent = flyFrame
    plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
    plus.Position = UDim2.new(0.231578946, 0, 0, 0)
    plus.Size = UDim2.new(0, 45, 0, 28)
    plus.Font = Enum.Font.SourceSans
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(0, 0, 0)
    plus.TextScaled = true
    plus.TextSize = 14.000
    plus.TextWrapped = true

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "speed"
    speedLabel.Parent = flyFrame
    speedLabel.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    speedLabel.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
    speedLabel.Size = UDim2.new(0, 44, 0, 28)
    speedLabel.Font = Enum.Font.SourceSans
    speedLabel.Text = "1"
    speedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    speedLabel.TextScaled = true
    speedLabel.TextSize = 14.000
    speedLabel.TextWrapped = true

    local mine = Instance.new("TextButton")
    mine.Name = "mine"
    mine.Parent = flyFrame
    mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
    mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
    mine.Size = UDim2.new(0, 45, 0, 29)
    mine.Font = Enum.Font.SourceSans
    mine.Text = "-"
    mine.TextColor3 = Color3.fromRGB(0, 0, 0)
    mine.TextScaled = true
    mine.TextSize = 14.000
    mine.TextWrapped = true

    local closeFly = Instance.new("TextButton")
    closeFly.Name = "Close"
    closeFly.Parent = flyFrame
    closeFly.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
    closeFly.Font = Enum.Font.SourceSans
    closeFly.Size = UDim2.new(0, 45, 0, 28)
    closeFly.Text = "X"
    closeFly.TextSize = 30
    closeFly.Position = UDim2.new(0, 0, -1, 27)

    local mini = Instance.new("TextButton")
    mini.Name = "minimize"
    mini.Parent = flyFrame
    mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
    mini.Font = Enum.Font.SourceSans
    mini.Size = UDim2.new(0, 45, 0, 28)
    mini.Text = "-"
    mini.TextSize = 40
    mini.Position = UDim2.new(0, 44, -1, 27)

    local mini2 = Instance.new("TextButton")
    mini2.Name = "minimize2"
    mini2.Parent = flyFrame
    mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
    mini2.Font = Enum.Font.SourceSans
    mini2.Size = UDim2.new(0, 45, 0, 28)
    mini2.Text = "+"
    mini2.TextSize = 40
    mini2.Position = UDim2.new(0, 44, -1, 57)
    mini2.Visible = false

    -- Fly logic variables
    local speeds = 1
    local nowe = false
    local tpwalking = false
    local speaker = player

    -- Functionality
    onof.MouseButton1Click:Connect(function()
        if nowe == true then
            nowe = false
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        else
            nowe = true
            for i = 1, speeds do
                task.spawn(function()
                    local hb = RunService.Heartbeat
                    tpwalking = true
                    local chr = player.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
                end)
            end
            player.Character.Animate.Disabled = true
            local Char = player.Character
            local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
            for _, v in next, Hum:GetPlayingAnimationTracks() do
                v:AdjustSpeed(0)
            end
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end

        -- R6/R8 fly physics
        if player.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
            local torso = player.Character.Torso
            local flying = true
            local deb = true
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local speed = 0

            local bg = Instance.new("BodyGyro", torso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = torso.CFrame
            local bv = Instance.new("BodyVelocity", torso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then
                player.Character.Humanoid.PlatformStand = true
            end
            while nowe == true or player.Character.Humanoid.Health == 0 do
                RunService.RenderStepped:Wait()
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed+.5+(speed/maxspeed)
                    if speed > maxspeed then speed = maxspeed end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed-1
                    if speed < 0 then speed = 0 end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
                bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
            end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            lastctrl = {f = 0, b = 0, l = 0, r = 0}
            speed = 0
            bg:Destroy()
            bv:Destroy()
            player.Character.Humanoid.PlatformStand = false
            player.Character.Animate.Disabled = false
            tpwalking = false
        else
            local UpperTorso = player.Character.UpperTorso
            local flying = true
            local deb = true
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local speed = 0

            local bg = Instance.new("BodyGyro", UpperTorso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = UpperTorso.CFrame
            local bv = Instance.new("BodyVelocity", UpperTorso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then
                player.Character.Humanoid.PlatformStand = true
            end
            while nowe == true or player.Character.Humanoid.Health == 0 do
                task.wait()
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed+.5+(speed/maxspeed)
                    if speed > maxspeed then speed = maxspeed end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed-1
                    if speed < 0 then speed = 0 end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
                bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
            end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            lastctrl = {f = 0, b = 0, l = 0, r = 0}
            speed = 0
            bg:Destroy()
            bv:Destroy()
            player.Character.Humanoid.PlatformStand = false
            player.Character.Animate.Disabled = false
            tpwalking = false
        end
    end)

    -- Up/Down hold
    local tis, dis
    up.MouseButton1Down:Connect(function()
        tis = up.MouseEnter:Connect(function()
            while tis do
                task.wait()
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
            end
        end)
    end)
    up.MouseLeave:Connect(function()
        if tis then tis:Disconnect() tis = nil end
    end)

    down.MouseButton1Down:Connect(function()
        dis = down.MouseEnter:Connect(function()
            while dis do
                task.wait()
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
            end
        end)
    end)
    down.MouseLeave:Connect(function()
        if dis then dis:Disconnect() dis = nil end
    end)

    -- Speed controls
    plus.MouseButton1Click:Connect(function()
        speeds = speeds + 1
        speedLabel.Text = tostring(speeds)
        if nowe == true then
            tpwalking = false
            for i = 1, speeds do
                task.spawn(function()
                    local hb = RunService.Heartbeat
                    tpwalking = true
                    local chr = player.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
                end)
            end
        end
    end)

    mine.MouseButton1Click:Connect(function()
        if speeds == 1 then
            speedLabel.Text = 'cannot be less than 1'
            task.wait(1)
            speedLabel.Text = tostring(speeds)
        else
            speeds = speeds - 1
            speedLabel.Text = tostring(speeds)
            if nowe == true then
                tpwalking = false
                for i = 1, speeds do
                    task.spawn(function()
                        local hb = RunService.Heartbeat
                        tpwalking = true
                        local chr = player.Character
                        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                        while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                            if hum.MoveDirection.Magnitude > 0 then
                                chr:TranslateBy(hum.MoveDirection)
                            end
                        end
                    end)
                end
            end
        end
    end)

    -- Close button: hanya menyembunyikan dan mematikan toggle di main menu
    closeFly.MouseButton1Click:Connect(function()
        flyUIVisible = false
        flyFrame.Visible = false
        setToggle(flyUIBtn, false)
    end)

    -- Minimize
    mini.MouseButton1Click:Connect(function()
        up.Visible = false
        down.Visible = false
        onof.Visible = false
        plus.Visible = false
        speedLabel.Visible = false
        mine.Visible = false
        mini.Visible = false
        mini2.Visible = true
        flyFrame.BackgroundTransparency = 1
        closeFly.Position = UDim2.new(0, 0, -1, 57)
    end)

    mini2.MouseButton1Click:Connect(function()
        up.Visible = true
        down.Visible = true
        onof.Visible = true
        plus.Visible = true
        speedLabel.Visible = true
        mine.Visible = true
        mini.Visible = true
        mini2.Visible = false
        flyFrame.BackgroundTransparency = 0
        closeFly.Position = UDim2.new(0, 0, -1, 27)
    end)

    -- Character respawn handling
    player.CharacterAdded:Connect(function(char)
        task.wait(0.7)
        player.Character.Humanoid.PlatformStand = false
        player.Character.Animate.Disabled = false
    end)

    return flyGui, flyFrame
end

-- Create fly UI
local flyGui, flyFrame = createFlyUI()

-- Fly UI button toggle
flyUIBtn.MouseButton1Click:Connect(function()
    flyUIVisible = not flyUIVisible
    flyFrame.Visible = flyUIVisible
    setToggle(flyUIBtn, flyUIVisible)
end)

-- ========== TELEPORT UI ==========
-- Global storage untuk teleport
_G.AzkaTeleports = _G.AzkaTeleports or {}  -- setiap item: {name = string, pos = Vector3}

local function createTeleportUI()
    local tpGui = Instance.new("ScreenGui")
    tpGui.Name = tpGUIName
    tpGui.ResetOnSpawn = false
    tpGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    tpGui.Parent = CoreGui

    -- Main Teleport Panel
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "TeleportPanel"
    mainPanel.Size = UDim2.fromOffset(350, 300)
    mainPanel.Position = UDim2.new(0.5, -175, 0.3, -150)
    mainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    mainPanel.Parent = tpGui
    mainPanel.Visible = false  -- start hidden
    makeDraggable(mainPanel, mainPanel)

    local corner = Instance.new("UICorner", mainPanel)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", mainPanel)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(80, 120, 255)
    stroke.Transparency = 0.25

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    titleBar.Parent = mainPanel
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(230, 235, 255)
    title.Text = "Teleport Menu"
    title.Parent = titleBar

    -- Close button for main panel (X) - hanya sembunyikan panel dan matikan toggle
    local closeTP = Instance.new("TextButton")
    closeTP.Size = UDim2.fromOffset(36, 24)
    closeTP.Position = UDim2.new(1, -44, 0.5, -12)
    closeTP.Text = "X"
    closeTP.Font = Enum.Font.GothamBold
    closeTP.TextSize = 16
    closeTP.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    closeTP.TextColor3 = Color3.fromRGB(255, 220, 220)
    Instance.new("UICorner", closeTP).CornerRadius = UDim.new(0, 8)
    closeTP.Parent = titleBar
    closeTP.MouseButton1Click:Connect(function()
        tpUIVisible = false
        mainPanel.Visible = false
        setToggle(tpUIBtn, false)
    end)

    -- Body
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, -24, 1, -50)
    body.Position = UDim2.new(0, 12, 0, 44)
    body.BackgroundTransparency = 1
    body.Parent = mainPanel

    -- Tombol "Save Teleport" (panjang)
    local saveTPBtn = Instance.new("TextButton")
    saveTPBtn.Size = UDim2.new(1, 0, 0, 40)
    saveTPBtn.Position = UDim2.new(0, 0, 0, 0)
    saveTPBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    saveTPBtn.Text = "Save Teleport"
    saveTPBtn.TextColor3 = Color3.fromRGB(230, 235, 255)
    saveTPBtn.Font = Enum.Font.GothamBold
    saveTPBtn.TextSize = 16
    Instance.new("UICorner", saveTPBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", saveTPBtn).Color = Color3.fromRGB(80, 120, 255)
    saveTPBtn.Parent = body

    -- Label "Teleport Saved" (tebal)
    local savedLabel = Instance.new("TextLabel")
    savedLabel.Size = UDim2.new(1, 0, 0, 30)
    savedLabel.Position = UDim2.new(0, 0, 0, 50)
    savedLabel.BackgroundTransparency = 1
    savedLabel.Text = "Teleport Saved"
    savedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    savedLabel.Font = Enum.Font.GothamBold
    savedLabel.TextSize = 18
    savedLabel.TextXAlignment = Enum.TextXAlignment.Left
    savedLabel.Parent = body

    -- Container untuk list teleport (scrolling frame)
    local listContainer = Instance.new("ScrollingFrame")
    listContainer.Size = UDim2.new(1, 0, 0, 150)
    listContainer.Position = UDim2.new(0, 0, 0, 85)
    listContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    listContainer.BorderSizePixel = 0
    listContainer.ScrollBarThickness = 6
    listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", listContainer).CornerRadius = UDim.new(0, 8)
    listContainer.Parent = body

    local listLayout = Instance.new("UIListLayout", listContainer)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)

    -- Pagination frame
    local pageFrame = Instance.new("Frame")
    pageFrame.Size = UDim2.new(1, 0, 0, 30)
    pageFrame.Position = UDim2.new(0, 0, 1, -35)
    pageFrame.BackgroundTransparency = 1
    pageFrame.Parent = body

    local pageLayout = Instance.new("UIListLayout", pageFrame)
    pageLayout.FillDirection = Enum.FillDirection.Horizontal
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    pageLayout.Padding = UDim.new(0, 5)

    -- Variabel untuk pagination
    local itemsPerPage = 5
    local currentPage = 1
    local totalPages = 1

    -- Fungsi refresh list
    local function refreshList()
        -- Hapus semua item di listContainer
        for _, child in ipairs(listContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        local teleports = _G.AzkaTeleports or {}
        totalPages = math.max(1, math.ceil(#teleports / itemsPerPage))
        currentPage = math.clamp(currentPage, 1, totalPages)

        -- Tampilkan item untuk halaman ini
        local startIdx = (currentPage - 1) * itemsPerPage + 1
        local endIdx = math.min(startIdx + itemsPerPage - 1, #teleports)

        for i = startIdx, endIdx do
            local data = teleports[i]
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 40)
            itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
            itemFrame.Parent = listContainer

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.5, -5, 1, 0)
            nameLabel.Position = UDim2.new(0, 5, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = data.name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = itemFrame

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 70, 0, 30)
            tpBtn.Position = UDim2.new(0.5, -35, 0.5, -15)
            tpBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
            tpBtn.Text = "Teleport"
            tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtn.Font = Enum.Font.GothamMedium
            tpBtn.TextSize = 12
            Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
            tpBtn.Parent = itemFrame
            tpBtn.MouseButton1Click:Connect(function()
                if data.pos then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(data.pos)
                    end
                end
            end)

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0, 50, 0, 30)
            delBtn.Position = UDim2.new(1, -55, 0.5, -15)
            delBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            delBtn.Text = "Delete"
            delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            delBtn.Font = Enum.Font.GothamMedium
            delBtn.TextSize = 12
            Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
            delBtn.Parent = itemFrame
            delBtn.MouseButton1Click:Connect(function()
                table.remove(_G.AzkaTeleports, i)
                refreshList()
            end)
        end

        -- Update pagination buttons
        for _, child in ipairs(pageFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for p = 1, totalPages do
            local pageBtn = Instance.new("TextButton")
            pageBtn.Size = UDim2.fromOffset(30, 30)
            pageBtn.BackgroundColor3 = (p == currentPage) and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(50, 50, 60)
            pageBtn.Text = tostring(p)
            pageBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pageBtn.Font = Enum.Font.GothamBold
            pageBtn.TextSize = 14
            Instance.new("UICorner", pageBtn).CornerRadius = UDim.new(0, 6)
            pageBtn.Parent = pageFrame
            pageBtn.MouseButton1Click:Connect(function()
                currentPage = p
                refreshList()
            end)
        end
    end

    -- Sub-panel Save Teleport
    local saveSubPanel = Instance.new("Frame")
    saveSubPanel.Name = "SaveSubPanel"
    saveSubPanel.Size = UDim2.fromOffset(300, 200)
    saveSubPanel.Position = UDim2.new(0.5, -150, 0.5, -100)
    saveSubPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    saveSubPanel.Parent = tpGui
    saveSubPanel.Visible = false
    makeDraggable(saveSubPanel, saveSubPanel)

    local subCorner = Instance.new("UICorner", saveSubPanel)
    subCorner.CornerRadius = UDim.new(0, 12)
    local subStroke = Instance.new("UIStroke", saveSubPanel)
    subStroke.Color = Color3.fromRGB(80, 120, 255)

    -- Title sub
    local subTitle = Instance.new("TextLabel")
    subTitle.Size = UDim2.new(1, 0, 0, 40)
    subTitle.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    subTitle.Text = "Save Teleport"
    subTitle.TextColor3 = Color3.fromRGB(230, 235, 255)
    subTitle.Font = Enum.Font.GothamBold
    subTitle.TextSize = 18
    Instance.new("UICorner", subTitle).CornerRadius = UDim.new(0, 12)
    subTitle.Parent = saveSubPanel

    -- Label koordinat
    local coordLabel = Instance.new("TextLabel")
    coordLabel.Size = UDim2.new(1, -20, 0, 30)
    coordLabel.Position = UDim2.new(0, 10, 0, 50)
    coordLabel.BackgroundTransparency = 1
    coordLabel.Text = "Position: 0, 0, 0"
    coordLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    coordLabel.Font = Enum.Font.Gotham
    coordLabel.TextSize = 14
    coordLabel.Parent = saveSubPanel

    -- TextBox untuk nama
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(1, -20, 0, 36)
    nameBox.Position = UDim2.new(0, 10, 0, 90)
    nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    nameBox.PlaceholderText = "Nama"
    nameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    nameBox.Text = ""
    nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 14
    nameBox.ClearTextOnFocus = false
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)
    nameBox.Parent = saveSubPanel
    -- Batasi panjang teks
    nameBox.FocusLost:Connect(function()
        if #nameBox.Text > 20 then
            nameBox.Text = nameBox.Text:sub(1, 20)
        end
    end)
    nameBox:GetPropertyChangedSignal("Text"):Connect(function()
        if #nameBox.Text > 20 then
            nameBox.Text = nameBox.Text:sub(1, 20)
        end
    end)

    -- Tombol Save
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 100, 0, 40)
    saveBtn.Position = UDim2.new(0, 10, 0, 140)
    saveBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    saveBtn.Text = "Save"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 16
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    saveBtn.Parent = saveSubPanel
    saveBtn.MouseButton1Click:Connect(function()
        local name = nameBox.Text
        if name == "" then name = "Unnamed" end
        local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
        if pos then
            table.insert(_G.AzkaTeleports, {name = name, pos = pos})
            refreshList()
            saveSubPanel.Visible = false
            mainPanel.Visible = true
        end
    end)

    -- Tombol Close
    local closeSubBtn = Instance.new("TextButton")
    closeSubBtn.Size = UDim2.new(0, 100, 0, 40)
    closeSubBtn.Position = UDim2.new(1, -110, 0, 140)
    closeSubBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeSubBtn.Text = "Close"
    closeSubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeSubBtn.Font = Enum.Font.GothamBold
    closeSubBtn.TextSize = 16
    Instance.new("UICorner", closeSubBtn).CornerRadius = UDim.new(0, 8)
    closeSubBtn.Parent = saveSubPanel
    closeSubBtn.MouseButton1Click:Connect(function()
        saveSubPanel.Visible = false
        mainPanel.Visible = true
    end)

    -- Tombol Save Teleport di main panel
    saveTPBtn.MouseButton1Click:Connect(function()
        -- Update koordinat saat ini
        local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
        if pos then
            coordLabel.Text = string.format("Position: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
        end
        mainPanel.Visible = false
        saveSubPanel.Visible = true
    end)

    -- Inisialisasi list
    refreshList()

    return tpGui, mainPanel
end

-- Create Teleport UI
local tpGui, tpPanel = createTeleportUI()

-- TP UI button toggle
tpUIBtn.MouseButton1Click:Connect(function()
    tpUIVisible = not tpUIVisible
    tpPanel.Visible = tpUIVisible
    setToggle(tpUIBtn, tpUIVisible)
end)

-- Close main menu
closeBtn.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
    -- Kita tidak destroy fly/tp GUI, biarkan pengguna menutup sendiri
end)

-- ===== WalkSpeed enforcer (WS + Boost) =====
task.spawn(function()
    local hum = waitForHumanoid()
    player.CharacterAdded:Connect(function()
        hum = waitForHumanoid()
    end)
    while running do
        if hum and hum.Parent then
            hum.WalkSpeed = currentWS + currentBoost
        else
            hum = waitForHumanoid()
        end
        task.wait(0.01)
    end
end)

-- Inf Jump
task.spawn(function()
    local hum = waitForHumanoid()
    player.CharacterAdded:Connect(function()
        hum = waitForHumanoid()
    end)
    UserInputService.JumpRequest:Connect(function()
        if infJumpEnabled and hum and hum.Parent then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hum.Jump = true
        end
    end)
end)

-- Noclip
task.spawn(function()
    while running do
        if noclipEnabled then
            local char = player.Character
            if char then
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.CanCollide = false
                    end
                end
            end
        end
        RunService.Stepped:Wait()
    end
end)

-- Notification
local notif = Instance.new("TextLabel")
notif.Name = "LoadNotif"
notif.Size = UDim2.new(0, 200, 0, 36)
notif.Position = UDim2.new(0.5, -100, 0, 20)
notif.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
notif.BackgroundTransparency = 0.2
notif.Text = "Script BY Azka - Loaded"
notif.TextColor3 = Color3.fromRGB(220, 230, 255)
notif.Font = Enum.Font.Gotham
notif.TextSize = 14
notif.Parent = gui
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)

task.wait(2)
TweenService:Create(notif, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
task.wait(0.5)
notif:Destroy()

print("Script BY Azka - Ultimate Controller loaded (old version replaced)")
