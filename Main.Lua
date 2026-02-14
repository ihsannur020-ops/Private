--[[
    Azka UI - Script GUI Modern dengan Fitur WalkSpeed, Inf Jump, Noclip
    Dilengkapi dengan menu drag, minimize, dan toggle.
    Semua teks menggunakan huruf tebal (GothamBold).
    Dapat dijalankan di executor Roblox.
]]

-- Hapus GUI lama jika sudah ada
local guiName = "AzkaUI"
local coreGui = game:GetService("CoreGui")
local existing = coreGui:FindFirstChild(guiName)
if existing then
    existing:Destroy()
end

-- Layanan yang diperlukan
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") -- opsional

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Variabel global untuk cleanup
_G.AzkaUI = {}

-- Fungsi untuk membuat GUI utama
local function createUI()
    -- ScreenGui utama
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = guiName
    screenGui.Parent = coreGui
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Panel utama
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(0, 600, 0, 450)
    mainPanel.Position = UDim2.new(0.5, -300, 0.4, -225) -- tengah
    mainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- #141419
    mainPanel.BorderSizePixel = 0
    mainPanel.Parent = screenGui

    -- Sudut membulat panel utama
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainPanel

    -- Stroke biru
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(80, 128, 255) -- #5080FF
    mainStroke.Thickness = 2
    mainStroke.Parent = mainPanel

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45) -- #23232D
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainPanel

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    -- Hanya sudut atas yang membulat, tapi kita akan biarkan seperti itu karena bawahnya tertutup panel

    -- Teks judul
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Script BY Azka"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Tombol Close (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 24)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- #C83232
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- Tombol Minimize (-)
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.Size = UDim2.new(0, 30, 0, 24)
    minBtn.Position = UDim2.new(1, -70, 0.5, -12)
    minBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 180) -- #4646B4
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minBtn

    -- Panel Kiri (Menu)
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 130, 0, 380)
    leftPanel.Position = UDim2.new(0, 10, 0, 46)
    leftPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 38) -- #1E1E26
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = mainPanel

    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 10)
    leftCorner.Parent = leftPanel

    -- Tombol Main
    local mainBtn = Instance.new("TextButton")
    mainBtn.Name = "MainButton"
    mainBtn.Size = UDim2.new(1, -20, 0, 40)
    mainBtn.Position = UDim2.new(0, 10, 0, 10)
    mainBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 200) -- biru aktif
    mainBtn.Text = "Main"
    mainBtn.Font = Enum.Font.GothamBold
    mainBtn.TextSize = 16
    mainBtn.TextColor3 = Color3.new(1, 1, 1)
    mainBtn.AutoButtonColor = false
    mainBtn.Parent = leftPanel

    local mainBtnCorner = Instance.new("UICorner")
    mainBtnCorner.CornerRadius = UDim.new(0, 8)
    mainBtnCorner.Parent = mainBtn

    -- Tombol Teleport
    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Name = "TeleportButton"
    teleportBtn.Size = UDim2.new(1, -20, 0, 40)
    teleportBtn.Position = UDim2.new(0, 10, 0, 60)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60) -- abu-abu #32323C
    teleportBtn.Text = "Teleport"
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.TextSize = 16
    teleportBtn.TextColor3 = Color3.new(1, 1, 1)
    teleportBtn.AutoButtonColor = false
    teleportBtn.Parent = leftPanel

    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 8)
    teleportCorner.Parent = teleportBtn

    -- Tombol Setting
    local settingBtn = Instance.new("TextButton")
    settingBtn.Name = "SettingButton"
    settingBtn.Size = UDim2.new(1, -20, 0, 40)
    settingBtn.Position = UDim2.new(0, 10, 0, 110)
    settingBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    settingBtn.Text = "Setting"
    settingBtn.Font = Enum.Font.GothamBold
    settingBtn.TextSize = 16
    settingBtn.TextColor3 = Color3.new(1, 1, 1)
    settingBtn.AutoButtonColor = false
    settingBtn.Parent = leftPanel

    local settingCorner = Instance.new("UICorner")
    settingCorner.CornerRadius = UDim.new(0, 8)
    settingCorner.Parent = settingBtn

    -- Garis pemisah vertikal
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0, 2, 0, 350)
    divider.Position = UDim2.new(0, 145, 0, 50)
    divider.BackgroundColor3 = Color3.new(1, 1, 1)
    divider.BorderSizePixel = 0
    divider.Parent = mainPanel

    -- Panel Kanan (Konten)
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(0, 430, 0, 380)
    rightPanel.Position = UDim2.new(0, 155, 0, 46)
    rightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32) -- #191920
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = mainPanel

    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 10)
    rightCorner.Parent = rightPanel

    -- Frame konten Main
    local mainContent = Instance.new("Frame")
    mainContent.Name = "MainContent"
    mainContent.Size = UDim2.new(1, 0, 1, 0)
    mainContent.BackgroundTransparency = 1
    mainContent.Visible = true
    mainContent.Parent = rightPanel

    -- Frame konten Teleport (placeholder)
    local teleportContent = Instance.new("Frame")
    teleportContent.Name = "TeleportContent"
    teleportContent.Size = UDim2.new(1, 0, 1, 0)
    teleportContent.BackgroundTransparency = 1
    teleportContent.Visible = false
    teleportContent.Parent = rightPanel

    local teleportLabel = Instance.new("TextLabel")
    teleportLabel.Size = UDim2.new(1, 0, 1, 0)
    teleportLabel.BackgroundTransparency = 1
    teleportLabel.Text = "Menu Teleport (Coming Soon)"
    teleportLabel.Font = Enum.Font.GothamBold
    teleportLabel.TextSize = 18
    teleportLabel.TextColor3 = Color3.new(1, 1, 1)
    teleportLabel.Parent = teleportContent

    -- Frame konten Setting (placeholder)
    local settingContent = Instance.new("Frame")
    settingContent.Name = "SettingContent"
    settingContent.Size = UDim2.new(1, 0, 1, 0)
    settingContent.BackgroundTransparency = 1
    settingContent.Visible = false
    settingContent.Parent = rightPanel

    local settingLabel = Instance.new("TextLabel")
    settingLabel.Size = UDim2.new(1, 0, 1, 0)
    settingLabel.BackgroundTransparency = 1
    settingLabel.Text = "Menu Setting (Coming Soon)"
    settingLabel.Font = Enum.Font.GothamBold
    settingLabel.TextSize = 18
    settingLabel.TextColor3 = Color3.new(1, 1, 1)
    settingLabel.Parent = settingContent

    -- Konten Main: WalkSpeed Label
    local wsLabel = Instance.new("TextLabel")
    wsLabel.Name = "WSLabel"
    wsLabel.Size = UDim2.new(0, 200, 0, 30)
    wsLabel.Position = UDim2.new(0, 10, 0, 10)
    wsLabel.BackgroundTransparency = 1
    wsLabel.Text = "WalkSpeed"
    wsLabel.Font = Enum.Font.GothamBold
    wsLabel.TextSize = 18
    wsLabel.TextColor3 = Color3.new(1, 1, 1)
    wsLabel.TextXAlignment = Enum.TextXAlignment.Left
    wsLabel.Parent = mainContent

    -- Nilai WalkSpeed
    local wsValue = Instance.new("TextLabel")
    wsValue.Name = "WSValue"
    wsValue.Size = UDim2.new(0, 50, 0, 30)
    wsValue.Position = UDim2.new(1, -60, 0, 10)
    wsValue.BackgroundTransparency = 1
    wsValue.Text = "30"
    wsValue.Font = Enum.Font.GothamBold
    wsValue.TextSize = 18
    wsValue.TextColor3 = Color3.fromRGB(100, 180, 255) -- biru muda
    wsValue.TextXAlignment = Enum.TextXAlignment.Right
    wsValue.Parent = mainContent

    -- Slider Track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "SliderTrack"
    sliderTrack.Size = UDim2.new(0, 380, 0, 8)
    sliderTrack.Position = UDim2.new(0, 10, 0, 50)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70) -- #3C3C46
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = mainContent

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 4)
    trackCorner.Parent = sliderTrack

    -- Slider Fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(0, 190, 1, 0) -- 50% dari 380 (nilai awal 30 dari range 30-100 -> 0% di 30, 100% di 100, jadi untuk 30 -> 0%)
    -- Namun kita ingin slider menunjukkan nilai relatif: 30 adalah minimum, jadi fill 0%. Maka kita hitung: (nilai - min)/(max-min) * lebar
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 140, 255) -- #508CFF
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill

    -- Slider Knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "SliderKnob"
    sliderKnob.Size = UDim2.new(0, 18, 0, 18)
    sliderKnob.Position = UDim2.new(0, 190 - 9, 0, -5) -- tengah fill
    sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderTrack

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0) -- lingkaran
    knobCorner.Parent = sliderKnob

    -- Tombol Inf Jump
    local infJumpBtn = Instance.new("TextButton")
    infJumpBtn.Name = "InfJumpButton"
    infJumpBtn.Size = UDim2.new(0, 160, 0, 40)
    infJumpBtn.Position = UDim2.new(0, 10, 0, 80)
    infJumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70) -- abu-abu
    infJumpBtn.Text = "Inf Jump: OFF"
    infJumpBtn.Font = Enum.Font.GothamBold
    infJumpBtn.TextSize = 16
    infJumpBtn.TextColor3 = Color3.new(1, 1, 1)
    infJumpBtn.AutoButtonColor = false
    infJumpBtn.Parent = mainContent

    local infCorner = Instance.new("UICorner")
    infCorner.CornerRadius = UDim.new(0, 8)
    infCorner.Parent = infJumpBtn

    -- Tombol Noclip
    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Name = "NoclipButton"
    noclipBtn.Size = UDim2.new(0, 160, 0, 40)
    noclipBtn.Position = UDim2.new(0, 190, 0, 80)
    noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    noclipBtn.Text = "Noclip: OFF"
    noclipBtn.Font = Enum.Font.GothamBold
    noclipBtn.TextSize = 16
    noclipBtn.TextColor3 = Color3.new(1, 1, 1)
    noclipBtn.AutoButtonColor = false
    noclipBtn.Parent = mainContent

    local noclipCorner = Instance.new("UICorner")
    noclipCorner.CornerRadius = UDim.new(0, 8)
    noclipCorner.Parent = noclipBtn

    -- Frame kecil untuk minimize
    local miniFrame = Instance.new("Frame")
    miniFrame.Name = "MiniFrame"
    miniFrame.Size = UDim2.new(0, 40, 0, 40)
    miniFrame.Position = mainPanel.Position -- ikuti posisi panel utama
    miniFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    miniFrame.BorderSizePixel = 0
    miniFrame.Visible = false
    miniFrame.Parent = screenGui

    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 8)
    miniCorner.Parent = miniFrame

    local miniStroke = Instance.new("UIStroke")
    miniStroke.Color = Color3.fromRGB(80, 128, 255)
    miniStroke.Thickness = 2
    miniStroke.Parent = miniFrame

    local miniIcon = Instance.new("TextLabel")
    miniIcon.Name = "MiniIcon"
    miniIcon.Size = UDim2.new(1, 0, 1, 0)
    miniIcon.BackgroundTransparency = 1
    miniIcon.Text = "☰"
    miniIcon.Font = Enum.Font.GothamBold
    miniIcon.TextSize = 24
    miniIcon.TextColor3 = Color3.new(1, 1, 1)
    miniIcon.Parent = miniFrame

    -- Variabel state
    local isMinimized = false
    local dragActive = false
    local dragStartPos, dragStartMouse
    local currentMenu = "Main" -- Main, Teleport, Setting
    local infJumpEnabled = false
    local noclipEnabled = false
    local wsValueNum = 30

    -- Fungsi untuk memperbarui tampilan slider
    local function updateSliderFromValue(value)
        value = math.clamp(value, 30, 100)
        wsValueNum = value
        wsValue.Text = tostring(math.floor(value))
        -- Hitung lebar fill: (value - 30) / (100 - 30) * 380
        local fillWidth = (value - 30) / 70 * 380
        sliderFill.Size = UDim2.new(0, fillWidth, 1, 0)
        sliderKnob.Position = UDim2.new(0, fillWidth - 9, 0, -5)
    end

    updateSliderFromValue(30)

    -- Fungsi untuk mengubah WalkSpeed humanoid
    local function setWalkSpeed(speed)
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speed
            end
        end
    end

    -- Loop untuk WalkSpeed agar selalu sinkron (meskipun diubah game)
    task.spawn(function()
        while screenGui and screenGui.Parent do
            task.wait(0.1)
            if not isMinimized then
                setWalkSpeed(wsValueNum)
            end
        end
    end)

    -- Inf Jump logic
    local jumpConnection
    local function enableInfJump(enable)
        if enable then
            if jumpConnection then jumpConnection:Disconnect() end
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end

    -- Noclip logic
    local noclipLoop
    local function enableNoclip(enable)
        if enable then
            if noclipLoop then noclipLoop:Disconnect() end
            noclipLoop = RunService.Stepped:Connect(function()
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipLoop then
                noclipLoop:Disconnect()
                noclipLoop = nil
            end
        end
    end

    -- Fungsi untuk mereset saat karakter respawn
    local function onCharacterAdded(newChar)
        character = newChar
        -- Terapkan WalkSpeed
        setWalkSpeed(wsValueNum)
        -- Terapkan noclip jika aktif
        if noclipEnabled then
            enableNoclip(true)
        end
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    -- Tombol Inf Jump
    infJumpBtn.MouseButton1Click:Connect(function()
        infJumpEnabled = not infJumpEnabled
        if infJumpEnabled then
            infJumpBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30) -- hijau #1E781E
            infJumpBtn.Text = "Inf Jump: ON"
        else
            infJumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            infJumpBtn.Text = "Inf Jump: OFF"
        end
        enableInfJump(infJumpEnabled)
    end)

    -- Tombol Noclip
    noclipBtn.MouseButton1Click:Connect(function()
        noclipEnabled = not noclipEnabled
        if noclipEnabled then
            noclipBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
            noclipBtn.Text = "Noclip: ON"
        else
            noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            noclipBtn.Text = "Noclip: OFF"
        end
        enableNoclip(noclipEnabled)
    end)

    -- Fungsi untuk mengganti menu
    local function setMenu(menu)
        currentMenu = menu
        -- Update visibilitas konten
        mainContent.Visible = (menu == "Main")
        teleportContent.Visible = (menu == "Teleport")
        settingContent.Visible = (menu == "Setting")

        -- Update warna tombol
        mainBtn.BackgroundColor3 = (menu == "Main") and Color3.fromRGB(70, 100, 200) or Color3.fromRGB(50, 50, 60)
        teleportBtn.BackgroundColor3 = (menu == "Teleport") and Color3.fromRGB(70, 100, 200) or Color3.fromRGB(50, 50, 60)
        settingBtn.BackgroundColor3 = (menu == "Setting") and Color3.fromRGB(70, 100, 200) or Color3.fromRGB(50, 50, 60)
    end

    mainBtn.MouseButton1Click:Connect(function() setMenu("Main") end)
    teleportBtn.MouseButton1Click:Connect(function() setMenu("Teleport") end)
    settingBtn.MouseButton1Click:Connect(function() setMenu("Setting") end)

    -- Minimize function
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = true
        mainPanel.Visible = false
        miniFrame.Visible = true
        miniFrame.Position = mainPanel.Position
    end)

    miniFrame.MouseButton1Click:Connect(function()
        isMinimized = false
        mainPanel.Visible = true
        miniFrame.Visible = false
        mainPanel.Position = miniFrame.Position
    end)

    -- Close function
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if _G.AzkaUI and _G.AzkaUI.cleanup then
            _G.AzkaUI.cleanup()
        end
    end)

    -- Drag functionality untuk mainPanel (via title bar)
    local function startDrag(frame, hit)
        if hit and hit:IsDescendantOf(titleBar) then
            dragActive = true
            dragStartPos = frame.Position
            dragStartMouse = UserInputService:GetMouseLocation()
        end
    end

    local function updateDrag(frame)
        if dragActive then
            local mousePos = UserInputService:GetMouseLocation()
            local delta = mousePos - dragStartMouse
            local newPos = UDim2.new(
                dragStartPos.X.Scale,
                dragStartPos.X.Offset + delta.X,
                dragStartPos.Y.Scale,
                dragStartPos.Y.Offset + delta.Y
            )
            frame.Position = newPos
        end
    end

    local function stopDrag()
        dragActive = false
    end

    -- Input events
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not isMinimized then
                startDrag(mainPanel, input)
            else
                startDrag(miniFrame, input)
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if not isMinimized then
                updateDrag(mainPanel)
            else
                updateDrag(miniFrame)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stopDrag()
        end
    end)

    -- Slider logic
    local function updateSliderFromMouse(input)
        local mousePos = UserInputService:GetMouseLocation()
        local absPos = sliderTrack.AbsolutePosition
        local absSize = sliderTrack.AbsoluteSize
        local relativeX = mousePos.X - absPos.X
        relativeX = math.clamp(relativeX, 0, absSize.X)
        local value = 30 + (relativeX / absSize.X) * 70
        value = math.floor(value + 0.5) -- pembulatan ke integer terdekat
        updateSliderFromValue(value)
        setWalkSpeed(value)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSliderFromMouse(input)
        end
    end)

    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSliderFromMouse(inp)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    conn:Disconnect()
                end
            end)
        end
    end)

    -- Simpan fungsi cleanup
    function _G.AzkaUI.cleanup()
        if jumpConnection then jumpConnection:Disconnect() end
        if noclipLoop then noclipLoop:Disconnect() end
        if screenGui then screenGui:Destroy() end
    end

    return screenGui
end

-- Jalankan pembuatan GUI
local success, err = pcall(createUI)
if not success then
    warn("Gagal membuat GUI:", err)
end
