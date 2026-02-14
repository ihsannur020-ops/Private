-- Script untuk Delta Executor - GUI Panel "AzkaUI" dengan fitur Cleanup
-- Ditempatkan di CoreGui, dengan nama "AzkaUI"
-- Menyediakan _G.AzkaUI.Cleanup() untuk menghancurkan GUI dan membersihkan koneksi

-- =====================================================
-- 1. Inisialisasi dan Cleanup GUI lama
-- =====================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Hapus GUI lama jika ada
local existingGui = CoreGui:FindFirstChild("AzkaUI")
if existingGui then
    existingGui:Destroy()
end

-- Jika sudah ada _G.AzkaUI, hapus (cleanup lama)
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

-- Variabel global untuk menyimpan state dan koneksi
local isMinimized = false
local mainFrame
local miniFrame
local currentMenu = "Main"
local walkSpeedValue = 16
local infJumpEnabled = false
local noclipEnabled = false

-- Tabel untuk menyimpan semua koneksi agar bisa dibersihkan
local connections = {}

-- Fungsi untuk menambah koneksi ke tabel
local function addConnection(conn)
    table.insert(connections, conn)
end

-- =====================================================
-- 3. Fungsi untuk membuat frame utama
-- =====================================================
local function createMainFrame()
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 600, 0, 450)
    frame.Position = UDim2.new(0.5, -300, 0.5, -225)
    frame.BackgroundColor3 = Color3.fromHex("#141419")
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromHex("#5080FF")
    frame.ClipsDescendants = false
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromHex("#23232D")
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

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

    -- Tombol close
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

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    -- Tombol minimize
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -70, 0.5, -15)
    minBtn.BackgroundColor3 = Color3.fromHex("#4646B4")
    minBtn.Text = "-"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.TextSize = 24
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minBtn

    -- Panel kiri
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 130, 0, 380)
    leftPanel.Position = UDim2.new(0, 10, 0, 50)
    leftPanel.BackgroundColor3 = Color3.fromHex("#1E1E26")
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = frame

    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 10)
    leftCorner.Parent = leftPanel

    -- Tombol Main
    local btnMain = Instance.new("TextButton")
    btnMain.Name = "MenuMain"
    btnMain.Size = UDim2.new(0, 110, 0, 40)
    btnMain.Position = UDim2.new(0, 10, 0, 10)
    btnMain.BackgroundColor3 = Color3.fromHex("#4664C8")
    btnMain.Text = "Main"
    btnMain.TextColor3 = Color3.new(1, 1, 1)
    btnMain.TextSize = 16
    btnMain.Font = Enum.Font.GothamBold
    btnMain.AutoButtonColor = false
    btnMain.Parent = leftPanel

    local btnMainCorner = Instance.new("UICorner")
    btnMainCorner.CornerRadius = UDim.new(0, 6)
    btnMainCorner.Parent = btnMain

    -- Tombol Teleport
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

    local btnTeleCorner = Instance.new("UICorner")
    btnTeleCorner.CornerRadius = UDim.new(0, 6)
    btnTeleCorner.Parent = btnTele

    -- Tombol Setting
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

    local btnSetCorner = Instance.new("UICorner")
    btnSetCorner.CornerRadius = UDim.new(0, 6)
    btnSetCorner.Parent = btnSet

    -- Garis pemisah
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(0, 2, 0, 350)
    separator.Position = UDim2.new(0, 145, 0, 50)
    separator.BackgroundColor3 = Color3.new(1, 1, 1)
    separator.BorderSizePixel = 0
    separator.Parent = frame

    -- Panel kanan
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(0, 430, 0, 380)
    rightPanel.Position = UDim2.new(0, 155, 0, 50)
    rightPanel.BackgroundColor3 = Color3.fromHex("#191920")
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = frame

    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 10)
    rightCorner.Parent = rightPanel

    -- Konten Main
    local contentMain = Instance.new("Frame")
    contentMain.Name = "ContentMain"
    contentMain.Size = UDim2.new(1, -20, 1, -20)
    contentMain.Position = UDim2.new(0, 10, 0, 10)
    contentMain.BackgroundTransparency = 1
    contentMain.Visible = (currentMenu == "Main")
    contentMain.Parent = rightPanel

    local wsLabel = Instance.new("TextLabel")
    wsLabel.Name = "WSLabel"
    wsLabel.Size = UDim2.new(0, 150, 0, 30)
    wsLabel.Position = UDim2.new(0, 0, 0, 0)
    wsLabel.BackgroundTransparency = 1
    wsLabel.Text = "WalkSpeed"
    wsLabel.TextColor3 = Color3.new(1, 1, 1)
    wsLabel.TextSize = 18
    wsLabel.Font = Enum.Font.GothamBold
    wsLabel.TextXAlignment = Enum.TextXAlignment.Left
    wsLabel.Parent = contentMain

    local wsValue = Instance.new("TextLabel")
    wsValue.Name = "WSValue"
    wsValue.Size = UDim2.new(0, 50, 0, 30)
    wsValue.Position = UDim2.new(1, -60, 0, 0)
    wsValue.BackgroundTransparency = 1
    wsValue.Text = tostring(walkSpeedValue)
    wsValue.TextColor3 = Color3.fromHex("#508CFF")
    wsValue.TextSize = 18
    wsValue.Font = Enum.Font.GothamBold
    wsValue.TextXAlignment = Enum.TextXAlignment.Right
    wsValue.Parent = contentMain

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "SliderTrack"
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 40)
    sliderTrack.BackgroundColor3 = Color3.fromHex("#3C3C46")
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = contentMain

    local sliderTrackCorner = Instance.new("UICorner")
    sliderTrackCorner.CornerRadius = UDim.new(1, 0)
    sliderTrackCorner.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((walkSpeedValue - 16) / (100 - 16), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromHex("#508CFF")
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local knob = Instance.new("ImageButton")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((walkSpeedValue - 16) / (100 - 16), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    knob.ImageTransparency = 1
    knob.BorderSizePixel = 0
    knob.Parent = sliderTrack

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local infBtn = Instance.new("TextButton")
    infBtn.Name = "InfJumpBtn"
    infBtn.Size = UDim2.new(0, 160, 0, 40)
    infBtn.Position = UDim2.new(0, 0, 0, 80)
    infBtn.BackgroundColor3 = Color3.fromHex("#32323C")
    infBtn.Text = "Inf Jump: OFF"
    infBtn.TextColor3 = Color3.new(1, 1, 1)
    infBtn.TextSize = 16
    infBtn.Font = Enum.Font.GothamBold
    infBtn.AutoButtonColor = false
    infBtn.Parent = contentMain

    local infCorner = Instance.new("UICorner")
    infCorner.CornerRadius = UDim.new(0, 8)
    infCorner.Parent = infBtn

    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Name = "NoclipBtn"
    noclipBtn.Size = UDim2.new(0, 160, 0, 40)
    noclipBtn.Position = UDim2.new(0, 190, 0, 80)
    noclipBtn.BackgroundColor3 = Color3.fromHex("#32323C")
    noclipBtn.Text = "Noclip: OFF"
    noclipBtn.TextColor3 = Color3.new(1, 1, 1)
    noclipBtn.TextSize = 16
    noclipBtn.Font = Enum.Font.GothamBold
    noclipBtn.AutoButtonColor = false
    noclipBtn.Parent = contentMain

    local noclipCorner = Instance.new("UICorner")
    noclipCorner.CornerRadius = UDim.new(0, 8)
    noclipCorner.Parent = noclipBtn

    -- Konten Teleport (placeholder)
    local contentTele = Instance.new("Frame")
    contentTele.Name = "ContentTeleport"
    contentTele.Size = UDim2.new(1, -20, 1, -20)
    contentTele.Position = UDim2.new(0, 10, 0, 10)
    contentTele.BackgroundTransparency = 1
    contentTele.Visible = (currentMenu == "Teleport")
    contentTele.Parent = rightPanel

    local teleLabel = Instance.new("TextLabel")
    teleLabel.Size = UDim2.new(1, 0, 1, 0)
    teleLabel.BackgroundTransparency = 1
    teleLabel.Text = "Coming Soon"
    teleLabel.TextColor3 = Color3.new(1, 1, 1)
    teleLabel.TextSize = 24
    teleLabel.Font = Enum.Font.GothamBold
    teleLabel.Parent = contentTele

    -- Konten Setting (placeholder)
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
    -- Fungsi internal dan koneksi
    -- =====================================================
    local function setActiveMenu(menuName)
        currentMenu = menuName
        btnMain.BackgroundColor3 = (menuName == "Main") and Color3.fromHex("#4664C8") or Color3.fromHex("#32323C")
        btnTele.BackgroundColor3 = (menuName == "Teleport") and Color3.fromHex("#4664C8") or Color3.fromHex("#32323C")
        btnSet.BackgroundColor3 = (menuName == "Setting") and Color3.fromHex("#4664C8") or Color3.fromHex("#32323C")
        contentMain.Visible = (menuName == "Main")
        contentTele.Visible = (menuName == "Teleport")
        contentSet.Visible = (menuName == "Setting")
    end

    -- Koneksi tombol menu
    addConnection(btnMain.MouseButton1Click:Connect(function() setActiveMenu("Main") end))
    addConnection(btnTele.MouseButton1Click:Connect(function() setActiveMenu("Teleport") end))
    addConnection(btnSet.MouseButton1Click:Connect(function() setActiveMenu("Setting") end))

    -- Fungsi slider
    local function updateSlider(value)
        value = math.clamp(value, 16, 100)
        walkSpeedValue = value
        wsValue.Text = tostring(math.floor(value))
        local percent = (value - 16) / (100 - 16)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, -8)
        -- Terapkan ke player jika ada
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end

    -- Drag slider
    local dragging = false
    addConnection(knob.MouseButton1Down:Connect(function()
        dragging = true
    end))
    addConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    addConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local localPos = sliderTrack.AbsolutePosition
            local sizeX = sliderTrack.AbsoluteSize.X
            local mouseX = mouse.X
            local relX = math.clamp(mouseX - localPos.X, 0, sizeX)
            local newVal = 16 + (relX / sizeX) * (100 - 16)
            updateSlider(newVal)
        end
    end))

    updateSlider(walkSpeedValue)

    -- Inf Jump
    local jumpConn
    addConnection(infBtn.MouseButton1Click:Connect(function()
        infJumpEnabled = not infJumpEnabled
        if infJumpEnabled then
            infBtn.BackgroundColor3 = Color3.fromHex("#1E781E")
            infBtn.Text = "Inf Jump: ON"
            if not jumpConn then
                jumpConn = UserInputService.JumpRequest:Connect(function()
                    if infJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid:ChangeState("Jumping")
                    end
                end)
                addConnection(jumpConn)
            end
        else
            infBtn.BackgroundColor3 = Color3.fromHex("#32323C")
            infBtn.Text = "Inf Jump: OFF"
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
                -- Hapus dari tabel connections jika ada
                for i, conn in ipairs(connections) do
                    if conn == jumpConn then
                        table.remove(connections, i)
                        break
                    end
                end
            end
        end
    end))

    -- Noclip
    local noclipSteppedConn
    addConnection(noclipBtn.MouseButton1Click:Connect(function()
        noclipEnabled = not noclipEnabled
        if noclipEnabled then
            noclipBtn.BackgroundColor3 = Color3.fromHex("#1E781E")
            noclipBtn.Text = "Noclip: ON"
            if not noclipSteppedConn then
                noclipSteppedConn = game:GetService("RunService").Stepped:Connect(function()
                    if noclipEnabled and player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                addConnection(noclipSteppedConn)
            end
        else
            noclipBtn.BackgroundColor3 = Color3.fromHex("#32323C")
            noclipBtn.Text = "Noclip: OFF"
            if noclipSteppedConn then
                noclipSteppedConn:Disconnect()
                noclipSteppedConn = nil
                for i, conn in ipairs(connections) do
                    if conn == noclipSteppedConn then
                        table.remove(connections, i)
                        break
                    end
                end
            end
        end
    end))

    -- Drag utama pada title bar
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
            local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            frame.Position = newPos
        end
    end

    addConnection(titleBar.InputBegan:Connect(startDrag))
    addConnection(UserInputService.InputChanged:Connect(updateDrag))

    -- Tombol close
    addConnection(closeBtn.MouseButton1Click:Connect(function()
        _G.AzkaUI.Cleanup() -- panggil cleanup global
    end))

    -- Tombol minimize
    addConnection(minBtn.MouseButton1Click:Connect(function()
        isMinimized = true
        frame.Visible = false
        createMiniFrame()
    end))

    return frame
end

-- =====================================================
-- 4. Fungsi untuk membuat frame kecil (minimized)
-- =====================================================
local function createMiniFrame()
    if miniFrame and miniFrame.Parent then
        miniFrame:Destroy()
    end
    miniFrame = Instance.new("Frame")
    miniFrame.Name = "MiniFrame"
    miniFrame.Size = UDim2.new(0, 40, 0, 40)
    miniFrame.Position = UDim2.new(1, -50, 0, 50)
    miniFrame.BackgroundColor3 = Color3.fromHex("#141419")
    miniFrame.BorderSizePixel = 2
    miniFrame.BorderColor3 = Color3.fromHex("#5080FF")
    miniFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = miniFrame

    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
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
            local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            miniFrame.Position = newPos
        end
    end

    addConnection(miniFrame.InputBegan:Connect(startDrag))
    addConnection(UserInputService.InputChanged:Connect(updateDrag))

    -- Klik untuk restore (dengan deteksi bukan drag)
    addConnection(miniFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.wait(0.2)
            if not dragToggle then
                isMinimized = false
                miniFrame:Destroy()
                if mainFrame then
                    mainFrame.Visible = true
                end
            end
        end
    end))
end

-- =====================================================
-- 5. Membuat GUI dan mendefinisikan Cleanup
-- =====================================================
mainFrame = createMainFrame()

-- Definisikan _G.AzkaUI dengan fungsi Cleanup
_G.AzkaUI = {
    Cleanup = function()
        -- Hancurkan semua koneksi
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        connections = {}
        -- Hancurkan GUI
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        -- Hapus referensi
        mainFrame = nil
        miniFrame = nil
        _G.AzkaUI = nil
    end
}
