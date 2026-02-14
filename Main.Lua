--[[
    Azka UI - Custom UI seperti Kavo untuk Delta Executor
    Fitur: Drag, Minimize (emoji), Close, Menu Slide dengan konten WalkSpeed, Inf Jump, Noclip
    Dibuat oleh Azka
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if not Drawing or not UserInputService then
    warn("Drawing atau UserInputService tidak tersedia. Pastikan menggunakan executor yang mendukung.")
    return
end

local player = Players.LocalPlayer

-- Variabel global untuk menyimpan state UI dan mencegah duplikasi
_G.AzkaUI = _G.AzkaUI or {}
if _G.AzkaUI.Cleanup then
    _G.AzkaUI.Cleanup()
end

-- State window
local winX, winY = 200, 100
local winW, winH = 600, 450
local isMinimized = false
local isDragging = false
local dragOffsetX, dragOffsetY
local currentMenu = 1 -- 1: Main, 2: Teleport, 3: Setting

-- Ukuran minimize
local minW, minH = 200, 100

-- Tabel untuk menyimpan semua drawing objects
local objects = {}
local buttons = {} -- untuk deteksi klik

-- Variabel fitur
local currentWS = 30
local MIN_WS = 30
local MAX_WS = 100
local infJumpEnabled = false
local noclipEnabled = false
local draggingSlider = false

-- Fungsi untuk membersihkan semua objek dan event
local function Cleanup()
    for _, obj in ipairs(objects) do
        pcall(function() obj:Remove() end)
    end
    objects = {}
    buttons = {}
    if _G.AzkaUI.Connections then
        for _, conn in ipairs(_G.AzkaUI.Connections) do
            pcall(function() conn:Disconnect() end)
        end
    end
    _G.AzkaUI = nil
end

-- Fungsi untuk membuat objek Drawing dengan properti dasar
local function NewDrawing(objType, props)
    local obj = Drawing.new(objType)
    for k, v in pairs(props) do
        obj[k] = v
    end
    table.insert(objects, obj)
    return obj
end

-- Fungsi untuk membuat tombol (area klik)
local function NewButton(areaObj, callback)
    table.insert(buttons, {area = areaObj, callback = callback})
end

-- Fungsi untuk memperbarui posisi semua objek berdasarkan winX, winY
local function UpdatePositions()
    -- Background utama (solid)
    objects.bg.Position = Vector2.new(winX, winY)
    objects.bg.Size = Vector2.new(winW, winH)

    -- Title bar (untuk drag)
    objects.titleBar.Position = Vector2.new(winX, winY)
    objects.titleBar.Size = Vector2.new(winW, 30)

    -- Title text (Bold)
    objects.titleText.Position = Vector2.new(winX + 10, winY + 5)

    -- Tombol Close (X)
    objects.closeBtn.Position = Vector2.new(winX + winW - 40, winY + 5)
    objects.closeBtn.Size = Vector2.new(25, 20)
    objects.closeText.Position = Vector2.new(winX + winW - 33, winY + 5)

    -- Tombol Minimize (-)
    objects.minBtn.Position = Vector2.new(winX + winW - 70, winY + 5)
    objects.minBtn.Size = Vector2.new(25, 20)
    objects.minText.Position = Vector2.new(winX + winW - 63, winY + 5)

    -- Panel kiri (background menu)
    objects.leftPanel.Position = Vector2.new(winX + 5, winY + 35)
    objects.leftPanel.Size = Vector2.new(125, winH - 70)

    -- Menu buttons (di dalam panel kiri)
    local btnX = winX + 15
    local btnW = 105
    local btnH = 40
    local spacing = 10
    local firstY = winY + 45

    objects.mainBtn.Position = Vector2.new(btnX, firstY)
    objects.mainBtn.Size = Vector2.new(btnW, btnH)
    objects.mainText.Position = Vector2.new(btnX + 10, firstY + 10)

    objects.tpBtn.Position = Vector2.new(btnX, firstY + btnH + spacing)
    objects.tpBtn.Size = Vector2.new(btnW, btnH)
    objects.tpText.Position = Vector2.new(btnX + 10, firstY + btnH + spacing + 10)

    objects.settingBtn.Position = Vector2.new(btnX, firstY + 2 * (btnH + spacing))
    objects.settingBtn.Size = Vector2.new(btnW, btnH)
    objects.settingText.Position = Vector2.new(btnX + 10, firstY + 2 * (btnH + spacing) + 10)

    -- Garis pemisah vertikal (batas antara menu dan konten)
    objects.divider.Visible = not isMinimized
    if not isMinimized then
        objects.divider.From = Vector2.new(winX + 135, winY + 35)
        objects.divider.To = Vector2.new(winX + 135, winY + winH - 35)
    end

    -- Area konten (kanan)
    objects.contentArea.Position = Vector2.new(winX + 145, winY + 35)
    objects.contentArea.Size = Vector2.new(winW - 155, winH - 70)

    -- Elemen untuk menu Main
    if objects.wsLabel then
        objects.wsLabel.Position = Vector2.new(winX + 155, winY + 55)
        objects.wsValue.Position = Vector2.new(winX + winW - 175, winY + 55)
        
        -- Slider track
        objects.sliderTrack.Position = Vector2.new(winX + 155, winY + 90)
        objects.sliderTrack.Size = Vector2.new(winW - 300, 8)
        
        -- Slider fill (ukuran proporsional)
        local alpha = (currentWS - MIN_WS) / (MAX_WS - MIN_WS)
        local fillWidth = (winW - 300) * alpha
        objects.sliderFill.Position = Vector2.new(winX + 155, winY + 90)
        objects.sliderFill.Size = Vector2.new(fillWidth, 8)
        
        -- Slider knob
        local knobX = winX + 155 + fillWidth - 8
        objects.sliderKnob.Position = Vector2.new(knobX, winY + 86)
        objects.sliderKnob.Size = Vector2.new(16, 16)
        
        -- Tombol Inf Jump
        objects.infJumpBtn.Position = Vector2.new(winX + 155, winY + 115)
        objects.infJumpBtn.Size = Vector2.new(130, 30)
        objects.infJumpText.Position = Vector2.new(winX + 165, winY + 120)
        
        -- Tombol Noclip
        objects.noclipBtn.Position = Vector2.new(winX + 155 + 140, winY + 115)
        objects.noclipBtn.Size = Vector2.new(130, 30)
        objects.noclipText.Position = Vector2.new(winX + 165 + 140, winY + 120)
    end

    -- Minimize box (jika di-minimize) dengan emoji
    objects.minimizeBox.Position = Vector2.new(winX, winY)
    objects.minimizeBox.Size = Vector2.new(minW, minH)
    objects.minimizeText.Position = Vector2.new(winX + (minW/2) - 25, winY + (minH/2) - 10)
end

-- Fungsi untuk mengatur visibilitas elemen menu
local function SetMenu(menuIndex)
    currentMenu = menuIndex

    -- Sembunyikan semua konten spesifik menu
    if objects.wsLabel then
        objects.wsLabel.Visible = (menuIndex == 1)
        objects.wsValue.Visible = (menuIndex == 1)
        objects.sliderTrack.Visible = (menuIndex == 1)
        objects.sliderFill.Visible = (menuIndex == 1)
        objects.sliderKnob.Visible = (menuIndex == 1)
        objects.infJumpBtn.Visible = (menuIndex == 1)
        objects.infJumpText.Visible = (menuIndex == 1)
        objects.noclipBtn.Visible = (menuIndex == 1)
        objects.noclipText.Visible = (menuIndex == 1)
    end

    -- Untuk menu lain (Teleport, Setting) bisa ditambahkan nanti
    if menuIndex == 1 then
        objects.contentText.Text = "" -- kosong karena sudah ada elemen sendiri
    elseif menuIndex == 2 then
        objects.contentText.Text = "Menu Teleport\n(Coming Soon)"
    elseif menuIndex == 3 then
        objects.contentText.Text = "Menu Setting\n(Coming Soon)"
    end
end

-- Fungsi untuk memperbarui slider berdasarkan nilai
local function UpdateSliderFromValue(value)
    currentWS = math.clamp(value, MIN_WS, MAX_WS)
    local alpha = (currentWS - MIN_WS) / (MAX_WS - MIN_WS)
    local trackWidth = winW - 300
    local fillWidth = trackWidth * alpha
    objects.sliderFill.Size = Vector2.new(fillWidth, 8)
    local knobX = winX + 155 + fillWidth - 8
    objects.sliderKnob.Position = Vector2.new(knobX, winY + 86)
    objects.wsValue.Text = tostring(currentWS)
end

-- Fungsi untuk memperbarui slider berdasarkan posisi mouse
local function UpdateSliderFromMouse(mouseX)
    local trackX = winX + 155
    local trackWidth = winW - 300
    local relX = math.clamp(mouseX - trackX, 0, trackWidth)
    local alpha = relX / trackWidth
    local newValue = MIN_WS + alpha * (MAX_WS - MIN_WS)
    UpdateSliderFromValue(newValue)
end

-- Fungsi untuk toggle minimize
local function ToggleMinimize()
    isMinimized = not isMinimized

    -- Sembunyikan/tampilkan elemen
    objects.bg.Visible = not isMinimized
    objects.titleBar.Visible = not isMinimized
    objects.titleText.Visible = not isMinimized
    objects.closeBtn.Visible = not isMinimized
    objects.closeText.Visible = not isMinimized
    objects.minBtn.Visible = not isMinimized
    objects.minText.Visible = not isMinimized
    objects.leftPanel.Visible = not isMinimized
    objects.mainBtn.Visible = not isMinimized
    objects.mainText.Visible = not isMinimized
    objects.tpBtn.Visible = not isMinimized
    objects.tpText.Visible = not isMinimized
    objects.settingBtn.Visible = not isMinimized
    objects.settingText.Visible = not isMinimized
    objects.divider.Visible = not isMinimized
    objects.contentArea.Visible = not isMinimized
    objects.contentText.Visible = not isMinimized

    -- Konten menu Main
    if objects.wsLabel then
        objects.wsLabel.Visible = (not isMinimized and currentMenu == 1)
        objects.wsValue.Visible = (not isMinimized and currentMenu == 1)
        objects.sliderTrack.Visible = (not isMinimized and currentMenu == 1)
        objects.sliderFill.Visible = (not isMinimized and currentMenu == 1)
        objects.sliderKnob.Visible = (not isMinimized and currentMenu == 1)
        objects.infJumpBtn.Visible = (not isMinimized and currentMenu == 1)
        objects.infJumpText.Visible = (not isMinimized and currentMenu == 1)
        objects.noclipBtn.Visible = (not isMinimized and currentMenu == 1)
        objects.noclipText.Visible = (not isMinimized and currentMenu == 1)
    end

    objects.minimizeBox.Visible = isMinimized
    objects.minimizeText.Visible = isMinimized
end

-- Fungsi untuk membuat UI
local function CreateUI()
    -- Buat objek-objek utama
    objects.bg = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.1, 0.1, 0.1), -- Hitam pekat
        Transparency = 0,
        Visible = true,
        ZIndex = 1
    })

    objects.titleBar = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.3, 0.3, 0.3),
        Transparency = 0,
        Visible = true,
        ZIndex = 2
    })

    objects.titleText = NewDrawing("Text", {
        Text = "Script BY Azka",
        Color = Color3.new(1, 1, 1),
        Size = 18,
        Center = false,
        Outline = false,
        Font = 2, -- Bold
        Visible = true,
        ZIndex = 4
    })

    -- Tombol Close (X)
    objects.closeBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(1, 0.3, 0.3),
        Transparency = 0,
        Visible = true,
        ZIndex = 3
    })
    objects.closeText = NewDrawing("Text", {
        Text = "X",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = true,
        Font = 2,
        Visible = true,
        ZIndex = 4
    })
    NewButton(objects.closeBtn, function()
        Cleanup()
    end)

    -- Tombol Minimize (-)
    objects.minBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.3, 0.3, 1),
        Transparency = 0,
        Visible = true,
        ZIndex = 3
    })
    objects.minText = NewDrawing("Text", {
        Text = "-",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = true,
        Font = 2,
        Visible = true,
        ZIndex = 4
    })
    NewButton(objects.minBtn, function()
        ToggleMinimize()
    end)

    -- Minimize box (awalnya hidden) dengan emoji
    objects.minimizeBox = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.2, 0.2, 0.2),
        Transparency = 0,
        Visible = false,
        ZIndex = 1
    })
    objects.minimizeText = NewDrawing("Text", {
        Text = "✌︎㋡",
        Color = Color3.new(1, 1, 1),
        Size = 30,
        Center = true,
        Font = 2,
        Visible = false,
        ZIndex = 2
    })
    NewButton(objects.minimizeBox, function()
        -- Klik pada minimize box akan membuka kembali (toggle)
        ToggleMinimize()
    end)

    -- Panel kiri (background menu)
    objects.leftPanel = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.15, 0.15, 0.15),
        Transparency = 0,
        Visible = true,
        ZIndex = 2
    })

    -- Menu buttons (dengan background sendiri)
    objects.mainBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.25, 0.25, 0.25),
        Transparency = 0,
        Visible = true,
        ZIndex = 3
    })
    objects.mainText = NewDrawing("Text", {
        Text = "Main",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = false,
        Font = 2,
        Visible = true,
        ZIndex = 4
    })
    NewButton(objects.mainBtn, function() SetMenu(1) end)

    objects.tpBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.25, 0.25, 0.25),
        Transparency = 0,
        Visible = true,
        ZIndex = 3
    })
    objects.tpText = NewDrawing("Text", {
        Text = "Teleport",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = false,
        Font = 2,
        Visible = true,
        ZIndex = 4
    })
    NewButton(objects.tpBtn, function() SetMenu(2) end)

    objects.settingBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.25, 0.25, 0.25),
        Transparency = 0,
        Visible = true,
        ZIndex = 3
    })
    objects.settingText = NewDrawing("Text", {
        Text = "Setting",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = false,
        Font = 2,
        Visible = true,
        ZIndex = 4
    })
    NewButton(objects.settingBtn, function() SetMenu(3) end)

    -- Garis pemisah vertikal (putih)
    objects.divider = NewDrawing("Line", {
        Thickness = 2,
        Color = Color3.new(1, 1, 1),
        Transparency = 0,
        Visible = true,
        ZIndex = 3
    })

    -- Area konten
    objects.contentArea = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.12, 0.12, 0.12),
        Transparency = 0,
        Visible = true,
        ZIndex = 2
    })
    objects.contentText = NewDrawing("Text", {
        Text = "Selamat datang di Script BY Azka",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = true,
        Font = 2,
        Visible = true,
        ZIndex = 3
    })

    -- Elemen untuk menu Main (akan disembunyikan jika menu lain)
    objects.wsLabel = NewDrawing("Text", {
        Text = "WalkSpeed",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Font = 2,
        Visible = false,
        ZIndex = 3
    })
    objects.wsValue = NewDrawing("Text", {
        Text = "30",
        Color = Color3.new(0.8, 0.8, 1),
        Size = 16,
        Font = 2,
        Visible = false,
        ZIndex = 3
    })

    -- Slider track
    objects.sliderTrack = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.3, 0.3, 0.3),
        Transparency = 0,
        Visible = false,
        ZIndex = 3
    })
    -- Slider fill
    objects.sliderFill = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.2, 0.6, 1),
        Transparency = 0,
        Visible = false,
        ZIndex = 4
    })
    -- Slider knob
    objects.sliderKnob = NewDrawing("Circle", {
        Filled = true,
        Color = Color3.new(1, 1, 1),
        Radius = 8,
        Visible = false,
        ZIndex = 5
    })

    -- Tombol Inf Jump
    objects.infJumpBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.25, 0.25, 0.25),
        Transparency = 0,
        Visible = false,
        ZIndex = 3
    })
    objects.infJumpText = NewDrawing("Text", {
        Text = "Inf Jump: OFF",
        Color = Color3.new(1, 1, 1),
        Size = 14,
        Font = 2,
        Visible = false,
        ZIndex = 4
    })
    NewButton(objects.infJumpBtn, function()
        infJumpEnabled = not infJumpEnabled
        local status = infJumpEnabled and "ON" or "OFF"
        local color = infJumpEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.25, 0.25, 0.25)
        objects.infJumpBtn.Color = color
        objects.infJumpText.Text = "Inf Jump: " .. status
    end)

    -- Tombol Noclip
    objects.noclipBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.25, 0.25, 0.25),
        Transparency = 0,
        Visible = false,
        ZIndex = 3
    })
    objects.noclipText = NewDrawing("Text", {
        Text = "Noclip: OFF",
        Color = Color3.new(1, 1, 1),
        Size = 14,
        Font = 2,
        Visible = false,
        ZIndex = 4
    })
    NewButton(objects.noclipBtn, function()
        noclipEnabled = not noclipEnabled
        local status = noclipEnabled and "ON" or "OFF"
        local color = noclipEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.25, 0.25, 0.25)
        objects.noclipBtn.Color = color
        objects.noclipText.Text = "Noclip: " .. status
    end)

    -- Set posisi awal
    UpdatePositions()

    -- Set menu awal
    SetMenu(1)
end

-- Buat UI
CreateUI()

-- Event handler untuk klik
local function OnInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()

        -- Cek tombol-tombol
        for _, btn in ipairs(buttons) do
            local area = btn.area
            if area.Visible then
                local btnPos = area.Position
                local btnSize = area.Size
                -- Untuk Circle, deteksi jarak
                if area == objects.sliderKnob then
                    local dx = mousePos.X - btnPos.X
                    local dy = mousePos.Y - btnPos.Y
                    if dx*dx + dy*dy <= 8*8 then
                        btn.callback()
                        break
                    end
                else
                    if mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                       mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y then
                        btn.callback()
                        break
                    end
                end
            end
        end

        -- Cek drag di title bar atau minimize box
        if not isMinimized then
            local titleBar = objects.titleBar
            if mousePos.X >= titleBar.Position.X and mousePos.X <= titleBar.Position.X + titleBar.Size.X and
               mousePos.Y >= titleBar.Position.Y and mousePos.Y <= titleBar.Position.Y + titleBar.Size.Y then
                isDragging = true
                dragOffsetX = mousePos.X - winX
                dragOffsetY = mousePos.Y - winY
            end
        else
            -- Jika minimized, drag dari minimize box
            local minBox = objects.minimizeBox
            if mousePos.X >= minBox.Position.X and mousePos.X <= minBox.Position.X + minBox.Size.X and
               mousePos.Y >= minBox.Position.Y and mousePos.Y <= minBox.Position.Y + minBox.Size.Y then
                isDragging = true
                dragOffsetX = mousePos.X - winX
                dragOffsetY = mousePos.Y - winY
            end
        end

        -- Cek apakah klik di slider track/knob untuk memulai drag slider
        if not isMinimized and currentMenu == 1 then
            local track = objects.sliderTrack
            local knob = objects.sliderKnob
            if track.Visible then
                -- Cek track
                if mousePos.X >= track.Position.X and mousePos.X <= track.Position.X + track.Size.X and
                   mousePos.Y >= track.Position.Y and mousePos.Y <= track.Position.Y + track.Size.Y then
                    draggingSlider = true
                    UpdateSliderFromMouse(mousePos.X)
                end
                -- Cek knob (lingkaran)
                local dx = mousePos.X - knob.Position.X
                local dy = mousePos.Y - knob.Position.Y
                if dx*dx + dy*dy <= 8*8 then
                    draggingSlider = true
                end
            end
        end
    end
end

local inputConn = UserInputService.InputBegan:Connect(OnInputBegan)

-- Handler untuk pergerakan mouse (drag slider)
local inputChangedConn = UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or
                           input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = UserInputService:GetMouseLocation()
        UpdateSliderFromMouse(mousePos.X)
    end
end)

local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

-- Loop untuk drag window
local dragConn = RunService.RenderStepped:Connect(function()
    if isDragging then
        local mousePos = UserInputService:GetMouseLocation()
        winX = mousePos.X - dragOffsetX
        winY = mousePos.Y - dragOffsetY
        UpdatePositions()

        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            isDragging = false
        end
    end
end)

-- Fungsi untuk mendapatkan humanoid (dari contoh)
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

-- Loop untuk WalkSpeed
task.spawn(function()
    local hum = waitForHumanoid()
    player.CharacterAdded:Connect(function()
        hum = waitForHumanoid()
    end)
    while _G.AzkaUI do
        if hum and hum.Parent then
            hum.WalkSpeed = currentWS
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
    while _G.AzkaUI do
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

-- Simpan koneksi untuk cleanup
_G.AzkaUI.Cleanup = Cleanup
_G.AzkaUI.Connections = {inputConn, inputChangedConn, inputEndedConn, dragConn}

-- Notifikasi
print("Azka UI berhasil dimuat. Tekan X untuk menutup.")
