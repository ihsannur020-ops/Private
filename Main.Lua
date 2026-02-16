-- ===========================================
--           INISIALISASI GUI
-- ===========================================
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyCollectorGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (dapat di-drag)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Header untuk drag
local header = Instance.new("TextButton")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
header.Text = "  CONTROL PANEL  (Drag here)"
header.TextColor3 = Color3.new(1,1,1)
header.TextXAlignment = Enum.TextXAlignment.Left
header.BorderSizePixel = 0
header.AutoButtonColor = false
header.Parent = mainFrame

-- Container untuk semua switch (fitur)
local container = Instance.new("Frame")
container.Name = "ContainerSwitch"
container.Size = UDim2.new(1, -20, 1, -40)
container.Position = UDim2.new(0, 10, 0, 35)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Layout otomatis untuk switch
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = container

-- ===========================================
--        VARIABEL GLOBAL & FUNGSI
-- ===========================================

-- Instant Proximity
local proxEnabled = false
local proxConnections = {}

local function setProxEnabled(state)
    proxEnabled = state
    if state then
        -- Set semua yang sudah ada
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end
        -- Pantau yang baru
        local conn = workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0
            end
        end)
        table.insert(proxConnections, conn)
        print("[Instant Proximity] Activated")
    else
        -- Putuskan semua koneksi
        for _, conn in ipairs(proxConnections) do
            conn:Disconnect()
        end
        proxConnections = {}
        print("[Instant Proximity] Deactivated")
    end
end

-- Collect Money
local collectMoneyEnabled = false
local collectMoneyThread = nil

local function toggleCollectMoney(state)
    collectMoneyEnabled = state
    if state then
        -- Jalankan loop di thread terpisah
        collectMoneyThread = task.spawn(function()
            while collectMoneyEnabled do
                -- Kirim sinyal touch ke SlotTriggered
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
                if remote then
                    local slotTriggered = remote:FindFirstChild("SlotTriggered")
                    if slotTriggered then
                        pcall(function()
                            slotTriggered:FireServer()  -- bisa ditambah argumen jika diperlukan
                        end)
                    else
                        warn("SlotTriggered remote tidak ditemukan!")
                    end
                else
                    warn("RemoteEvents folder tidak ditemukan!")
                end
                task.wait(0.1)  -- interval pengiriman (bisa disesuaikan)
            end
        end)
        print("[Collect Money] Activated")
    else
        -- Hentikan loop
        collectMoneyEnabled = false
        if collectMoneyThread then
            task.cancel(collectMoneyThread)
            collectMoneyThread = nil
        end
        print("[Collect Money] Deactivated")
    end
end

-- ===========================================
--          MEMBUAT SWITCH (TOGGLE)
-- ===========================================

-- Fungsi membuat toggle button
local function createToggle(buttonText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = buttonText .. " : OFF"
    btn.TextColor3 = Color3.new(1,0.5,0.5)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = container

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = buttonText .. " : " .. (active and "ON" or "OFF")
        btn.TextColor3 = active and Color3.new(0.5,1,0.5) or Color3.new(1,0.5,0.5)
        callback(active)
    end)
end

-- Tambahkan switch Instant Proximity (ASLI)
createToggle("Instant Proximity", function(state)
    setProxEnabled(state)
end)

-- Tambahkan switch Collect Money (BARU)
createToggle("Collect Money", function(state)
    toggleCollectMoney(state)
end)

-- ===========================================
--          FUNGSIONALITAS DRAG (ASLI)
-- ===========================================
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

header.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ===========================================
--            CLEANUP (opsional)
-- ===========================================
-- Jika script dihentikan, matikan semua fitur
player.OnTeleport:Connect(function()
    setProxEnabled(false)
    toggleCollectMoney(false)
    screenGui:Destroy()
end)
