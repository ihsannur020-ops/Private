local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local userInput = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualInput = game:GetService("VirtualInputManager")

local localPlayer = players.LocalPlayer
local guiName = "RunForBrainrot"

-- Clean up existing GUI
if coreGui:FindFirstChild(guiName) then
    coreGui:FindFirstChild(guiName):Destroy()
end

-- GUI Creation
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
title.Text = "Run For Brainrot"
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

-- Containers
local buttonContainer = createContainer("ButtonContainer")
local switchContainer = createContainer("SwitchContainer")

-- Minimized frame (for when GUI is minimized)
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

-- Dragging logic for minimized frame (same as before)
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

-- =============================================
-- Utility Functions
-- =============================================
local function getCharacter()
    return localPlayer.Character
end

local function getHumanoidRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportToCFrame(cf)
    local root = getHumanoidRootPart()
    if root then
        root.CFrame = cf
    end
end

local function teleportToPosition(x, y, z)
    teleportToCFrame(CFrame.new(x, y, z))
end

local function getPlotName()
    return "Plot_" .. localPlayer.Name
end

local function getPlotModel()
    return workspace:FindFirstChild(getPlotName())
end

local function getPlotSpawn()
    local plot = getPlotModel()
    return plot and plot:FindFirstChild("Spawn")
end

-- =============================================
-- Toggle States
-- =============================================
local toggleStates = {
    AlwaysGround = false,
    AutoCelestial = false,
    AutoSecret = false,
    AutoCollectCash = false,
    AutoUpgradeAll = false
}

-- Warning flags (only show once)
local warningsShown = {
    CollectCash = false,
    UpgradeAll = false
}

-- =============================================
-- Always Ground
-- =============================================
local groundPart = nil
local groundConnection = nil

local function updateGroundPart()
    if toggleStates.AlwaysGround then
        if not groundPart then
            groundPart = Instance.new("Part")
            groundPart.Name = "AlwaysGroundByAzka"
            groundPart.Anchored = true
            groundPart.CanCollide = true
            groundPart.CanQuery = true
            groundPart.CanTouch = true
            groundPart.Transparency = 1
            groundPart.Size = Vector3.new(20.554, 3, 21.96)
            groundPart.Parent = workspace
        end
        -- Start updating position
        if not groundConnection then
            groundConnection = runService.Heartbeat:Connect(function()
                if toggleStates.AlwaysGround and groundPart then
                    local root = getHumanoidRootPart()
                    if root then
                        local pos = root.Position
                        groundPart.Position = Vector3.new(pos.X, 13.686, pos.Z)
                    end
                end
            end)
        end
    else
        if groundConnection then
            groundConnection:Disconnect()
            groundConnection = nil
        end
        if groundPart then
            groundPart:Destroy()
            groundPart = nil
        end
    end
end

-- =============================================
-- Warning Popup Function
-- =============================================
local function showWarning(featureName, message, onNext, onClose)
    -- Create a semi-transparent overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.Active = true
    overlay.Parent = screenGui
    overlay.ZIndex = 10

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 300, 0, 150)
    popup.Position = UDim2.new(0.5, -150, 0.5, -75)
    popup.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    popup.BorderSizePixel = 2
    popup.BorderColor3 = Color3.fromRGB(255, 255, 255)
    popup.Parent = overlay
    popup.ZIndex = 11

    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 8)
    popupCorner.Parent = popup

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 60)
    messageLabel.Position = UDim2.new(0, 10, 0, 10)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextWrapped = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.Parent = popup

    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -20, 0, 40)
    buttonFrame.Position = UDim2.new(0, 10, 1, -50)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = popup

    local nextBtn = Instance.new("TextButton")
    nextBtn.Size = UDim2.new(0.5, -5, 1, 0)
    nextBtn.Position = UDim2.new(0, 0, 0, 0)
    nextBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    nextBtn.Text = "Next"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.TextSize = 16
    nextBtn.BorderSizePixel = 0
    nextBtn.Parent = buttonFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.5, -5, 1, 0)
    closeBtn.Position = UDim2.new(0.5, 5, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.Text = "Close"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = buttonFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = nextBtn
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(0, 5)
    btnCorner2.Parent = closeBtn

    nextBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        onNext()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        onClose()
    end)
end

-- =============================================
-- Auto Collect Cash (Fixed with Fire TouchInterest)
-- =============================================
local collectCashLoop = nil
local dummyTouchPart = nil

local function createDummyTouchPart()
    if not dummyTouchPart then
        dummyTouchPart = Instance.new("Part")
        dummyTouchPart.Name = "DummyTouchPart"
        dummyTouchPart.Anchored = true
        dummyTouchPart.CanCollide = false
        dummyTouchPart.CanTouch = true
        dummyTouchPart.Transparency = 1
        dummyTouchPart.Size = Vector3.new(1,1,1)
        dummyTouchPart.Parent = workspace
    end
    return dummyTouchPart
end

local function getCollectTouchParts()
    local parts = {}
    local plot = getPlotModel()
    if not plot then return parts end

    local floors = {"Floor1", "Floor2", "Floor3"}
    for _, floorName in ipairs(floors) do
        local floor = plot:FindFirstChild(floorName)
        if floor then
            local slots = floor:FindFirstChild("Slots")
            if slots then
                for _, slot in ipairs(slots:GetChildren()) do
                    local collectTouch = slot:FindFirstChild("CollectTouch")
                    if collectTouch and collectTouch:IsA("BasePart") then
                        table.insert(parts, collectTouch)
                    end
                end
            end
        end
    end
    return parts
end

local function startCollectCash()
    if collectCashLoop then collectCashLoop:Disconnect() end
    local dummy = createDummyTouchPart()
    collectCashLoop = runService.Heartbeat:Connect(function()
        if not toggleStates.AutoCollectCash then
            collectCashLoop:Disconnect()
            collectCashLoop = nil
            return
        end
        local parts = getCollectTouchParts()
        for _, part in ipairs(parts) do
            if part and part.Parent and part.TouchInterest then
                pcall(function()
                    -- Fire the TouchInterest with the dummy part as the touching part
                    part.TouchInterest:Fire(dummy)
                end)
            end
        end
        task.wait(0.1) -- delay to avoid overloading
    end)
end

local function stopCollectCash()
    if collectCashLoop then
        collectCashLoop:Disconnect()
        collectCashLoop = nil
    end
    if dummyTouchPart then
        dummyTouchPart:Destroy()
        dummyTouchPart = nil
    end
end

-- =============================================
-- Auto Upgrade All (Fixed with Click simulation)
-- =============================================
local upgradeLoop = nil

local function getUpgradeButtons()
    local buttons = {}
    local plot = getPlotModel()
    if not plot then return buttons end

    local floors = {"Floor1", "Floor2", "Floor3"}
    for _, floorName in ipairs(floors) do
        local floor = plot:FindFirstChild(floorName)
        if floor then
            local slots = floor:FindFirstChild("Slots")
            if slots then
                for _, slot in ipairs(slots:GetChildren()) do
                    local upgradePart = slot:FindFirstChild("UpgradePart")
                    if upgradePart then
                        local upgradeGUI = upgradePart:FindFirstChild("UpgradeGUI")
                        if upgradeGUI then
                            local upgradeButton = upgradeGUI:FindFirstChild("UpgradeButton")
                            if upgradeButton and upgradeButton:IsA("TextButton") then
                                table.insert(buttons, upgradeButton)
                            end
                        end
                    end
                end
            end
        end
    end
    return buttons
end

local function startUpgradeAll()
    if upgradeLoop then upgradeLoop:Disconnect() end
    upgradeLoop = runService.Heartbeat:Connect(function()
        if not toggleStates.AutoUpgradeAll then
            upgradeLoop:Disconnect()
            upgradeLoop = nil
            return
        end
        local buttons = getUpgradeButtons()
        for _, btn in ipairs(buttons) do
            pcall(function()
                -- Click the button
                btn:Click()
            end)
        end
        task.wait(0.5) -- delay between clicks
    end)
end

local function stopUpgradeAll()
    if upgradeLoop then
        upgradeLoop:Disconnect()
        upgradeLoop = nil
    end
end

-- =============================================
-- Auto Celestial & Secret (with priority logic)
-- =============================================
local priorityRunning = false
local priorityLoop = nil

-- Signals from auto scripts to priority
local celestialDone = Instance.new("BindableEvent")
local secretDone = Instance.new("BindableEvent")

-- Functions to perform one collection
local function doCelestialCollection()
    local spawners = workspace:FindFirstChild("ItemSpawners")
    if not spawners then return end
    local celestial = spawners:FindFirstChild("Celestial")
    if not celestial then return end

    local models = celestial:GetChildren()
    if #models == 0 then return end

    local target = models[1]
    local rootPart = target:FindFirstChild("RootPart")
    if not rootPart then return end
    local prompt = rootPart:FindFirstChild("ProximityPrompt")
    if not prompt then return end

    teleportToCFrame(rootPart.CFrame * CFrame.new(0, 2, 0))
    task.wait(0.5)

    prompt:InputHoldBegin()
    task.wait(1.05)
    prompt:InputHoldEnd()

    teleportToPosition(100.107, 19.415, -451.556)
    task.wait(0.5)

    celestialDone:Fire()
end

local function doSecretCollection()
    local spawners = workspace:FindFirstChild("ItemSpawners")
    if not spawners then return end
    local secret = spawners:FindFirstChild("Secret")
    if not secret then return end

    local models = secret:GetChildren()
    if #models == 0 then return end

    local target = models[1]
    local rootPart = target:FindFirstChild("RootPart")
    if not rootPart then return end
    local prompt = rootPart:FindFirstChild("ProximityPrompt")
    if not prompt then return end

    teleportToCFrame(rootPart.CFrame * CFrame.new(0, 2, 0))
    task.wait(0.5)

    prompt:InputHoldBegin()
    task.wait(1.05)
    prompt:InputHoldEnd()

    teleportToPosition(100.107, 19.415, -451.556)
    task.wait(0.5)

    secretDone:Fire()
end

-- Priority logic
local function runPriority()
    while priorityRunning do
        if not (toggleStates.AutoCelestial or toggleStates.AutoSecret) then
            task.wait(1)
            continue
        end

        if toggleStates.AutoCelestial and toggleStates.AutoSecret then
            teleportToPosition(3.149, 20, 4181.083)
            task.wait(1)
            local spawners = workspace:FindFirstChild("ItemSpawners")
            if spawners then
                local celestial = spawners:FindFirstChild("Celestial")
                if celestial and #celestial:GetChildren() > 0 then
                    coroutine.wrap(doCelestialCollection)()
                    celestialDone.Event:Wait()
                else
                    teleportToPosition(0.697, 20, 3334.632)
                    task.wait(1)
                    local secret = spawners:FindFirstChild("Secret")
                    if secret and #secret:GetChildren() > 0 then
                        coroutine.wrap(doSecretCollection)()
                        secretDone.Event:Wait()
                    else
                        task.wait(2)
                    end
                end
            end
        elseif toggleStates.AutoCelestial then
            teleportToPosition(3.149, 20, 4181.083)
            task.wait(1)
            local spawners = workspace:FindFirstChild("ItemSpawners")
            if spawners then
                local celestial = spawners:FindFirstChild("Celestial")
                if celestial and #celestial:GetChildren() > 0 then
                    coroutine.wrap(doCelestialCollection)()
                    celestialDone.Event:Wait()
                else
                    task.wait(2)
                end
            end
        elseif toggleStates.AutoSecret then
            teleportToPosition(0.697, 20, 3334.632)
            task.wait(1)
            local spawners = workspace:FindFirstChild("ItemSpawners")
            if spawners then
                local secret = spawners:FindFirstChild("Secret")
                if secret and #secret:GetChildren() > 0 then
                    coroutine.wrap(doSecretCollection)()
                    secretDone.Event:Wait()
                else
                    task.wait(2)
                end
            end
        end
        task.wait(0.5)
    end
end

local function startPriority()
    if priorityRunning then return end
    priorityRunning = true
    priorityLoop = coroutine.wrap(runPriority)()
end

local function stopPriority()
    priorityRunning = false
    if priorityLoop then
        priorityLoop = nil
    end
end

-- =============================================
-- UI Elements Creation
-- =============================================
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Parent = buttonContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

local function createCheckbox(text, stateVar)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = switchContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Checkbox button (the clickable area)
    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 30, 0, 30)
    checkBtn.Position = UDim2.new(1, -35, 0, 0)
    checkBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- abu-abu saat off
    checkBtn.Text = ""
    checkBtn.BorderSizePixel = 0
    checkBtn.Parent = frame

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 5)
    checkCorner.Parent = checkBtn

    -- Checkmark (ImageLabel or TextLabel)
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkmark.TextSize = 20
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Visible = false
    checkmark.Parent = checkBtn

    local function updateCheckbox()
        if toggleStates[stateVar] then
            checkBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            checkmark.Visible = true
        else
            checkBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            checkmark.Visible = false
        end
    end

    checkBtn.MouseButton1Click:Connect(function()
        local newState = not toggleStates[stateVar]
        
        -- Special handling for features with warnings
        if stateVar == "AutoCollectCash" and newState and not warningsShown.CollectCash then
            -- Show warning
            showWarning(
                "CollectCash",
                "Only useful if the player is close to the Plot because the plot must be loaded by the client from the server.",
                function() -- Next
                    warningsShown.CollectCash = true
                    toggleStates[stateVar] = true
                    updateCheckbox()
                    startCollectCash()
                end,
                function() -- Close
                    toggleStates[stateVar] = false
                    updateCheckbox()
                    -- Do nothing else
                end
            )
            return
        elseif stateVar == "AutoUpgradeAll" and newState and not warningsShown.UpgradeAll then
            showWarning(
                "UpgradeAll",
                "Only useful if the player is close to the Plot because the plot must be loaded by the client from the server.",
                function()
                    warningsShown.UpgradeAll = true
                    toggleStates[stateVar] = true
                    updateCheckbox()
                    startUpgradeAll()
                end,
                function()
                    toggleStates[stateVar] = false
                    updateCheckbox()
                end
            )
            return
        end

        -- Normal toggle without warning or warning already shown
        toggleStates[stateVar] = newState
        updateCheckbox()

        -- Handle specific toggles
        if stateVar == "AlwaysGround" then
            updateGroundPart()
        elseif stateVar == "AutoCollectCash" then
            if toggleStates.AutoCollectCash then
                startCollectCash()
            else
                stopCollectCash()
            end
        elseif stateVar == "AutoUpgradeAll" then
            if toggleStates.AutoUpgradeAll then
                startUpgradeAll()
            else
                stopUpgradeAll()
            end
        elseif stateVar == "AutoCelestial" or stateVar == "AutoSecret" then
            if toggleStates.AutoCelestial or toggleStates.AutoSecret then
                startPriority()
            else
                stopPriority()
            end
        end
    end)

    updateCheckbox()
end

-- Add Buttons
createButton("Go To Plot", function()
    -- Teleport ke koordinat awal
    teleportToPosition(12.525, 20, -478.31)
    task.wait(0.5)
    -- Cari plot player
    local plot = getPlotModel()
    if plot then
        local spawn = plot:FindFirstChild("Spawn")
        if spawn then
            teleportToCFrame(spawn.CFrame)
        else
            warn("Spawn not found in plot")
        end
    else
        warn("Plot not found")
    end
end)

createButton("Celestial Zone", function()
    teleportToPosition(3.149, 20, 4181.083)
end)

createButton("Secret Zone", function()
    teleportToPosition(0.697, 20, 3334.632)
end)

createButton("Manual Collect", function()
    local root = getHumanoidRootPart()
    if not root then return end
    local savedPos = root.Position
    teleportToPosition(100.107, 19.415, -451.556)
    task.wait(1)
    teleportToCFrame(CFrame.new(savedPos))
end)

-- Add Checkboxes
createCheckbox("Always Ground", "AlwaysGround")
createCheckbox("Auto Celestial", "AutoCelestial")
createCheckbox("Auto Secret", "AutoSecret")
createCheckbox("Auto Collect Cash", "AutoCollectCash")
createCheckbox("Auto Upgrade All", "AutoUpgradeAll")

-- Expose UI globally if needed
_G[guiName] = { toggleStates = toggleStates }
