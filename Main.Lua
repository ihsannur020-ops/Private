--[[
    Azka UI - Custom UI seperti Kavo untuk Delta Executor
    Fitur: Drag, Minimize, Close, Menu Slide (Main, Teleport, Setting)
    Dibuat oleh Azka
]]

-- Cek environment
local Drawing = Drawing
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if not Drawing or not UserInputService then
    warn("Drawing atau UserInputService tidak tersedia. Pastikan menggunakan executor yang mendukung.")
    return
end

-- Variabel global untuk menyimpan state UI dan mencegah duplikasi
_G.AzkaUI = _G.AzkaUI or {}
if _G.AzkaUI.Cleanup then
    _G.AzkaUI.Cleanup() -- Hapus UI sebelumnya jika ada
end

-- State window
local winX, winY = 200, 100
local winW, winH = 600, 400
local isMinimized = false
local isDragging = false
local dragOffsetX, dragOffsetY
local currentMenu = 1 -- 1: Main, 2: Teleport, 3: Setting

-- Ukuran minimize
local minW, minH = 200, 100

-- Tabel untuk menyimpan semua drawing objects
local objects = {}
local buttons = {} -- untuk deteksi klik

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
    -- Background utama
    objects.bg.Position = Vector2.new(winX, winY)
    objects.bg.Size = Vector2.new(winW, winH)

    -- Title bar (untuk drag)
    objects.titleBar.Position = Vector2.new(winX, winY)
    objects.titleBar.Size = Vector2.new(winW, 30)

    -- Title text
    objects.titleText.Position = Vector2.new(winX + 10, winY + 5)

    -- Tombol Close (X)
    objects.closeBtn.Position = Vector2.new(winX + winW - 40, winY + 5)
    objects.closeBtn.Size = Vector2.new(25, 20)
    objects.closeText.Position = Vector2.new(winX + winW - 33, winY + 5)

    -- Tombol Minimize (-)
    objects.minBtn.Position = Vector2.new(winX + winW - 70, winY + 5)
    objects.minBtn.Size = Vector2.new(25, 20)
    objects.minText.Position = Vector2.new(winX + winW - 63, winY + 5)

    -- Menu buttons (kiri)
    local menuY = winY + 40
    objects.mainBtn.Position = Vector2.new(winX + 10, menuY)
    objects.mainBtn.Size = Vector2.new(100, 30)
    objects.mainText.Position = Vector2.new(winX + 20, menuY + 5)

    objects.tpBtn.Position = Vector2.new(winX + 10, menuY + 40)
    objects.tpBtn.Size = Vector2.new(100, 30)
    objects.tpText.Position = Vector2.new(winX + 20, menuY + 45)

    objects.settingBtn.Position = Vector2.new(winX + 10, menuY + 80)
    objects.settingBtn.Size = Vector2.new(100, 30)
    objects.settingText.Position = Vector2.new(winX + 20, menuY + 85)

    -- Garis pemisah vertikal
    objects.divider.Visible = not isMinimized
    if not isMinimized then
        objects.divider.From = Vector2.new(winX + 130, winY + 35)
        objects.divider.To = Vector2.new(winX + 130, winY + winH - 35)
    end

    -- Area konten (kanan)
    objects.contentArea.Position = Vector2.new(winX + 140, winY + 35)
    objects.contentArea.Size = Vector2.new(winW - 150, winH - 70)

    -- Teks konten (di tengah area konten)
    local contentX = winX + 140 + (winW - 150)/2 - 50
    local contentY = winY + 35 + (winH - 70)/2 - 10
    objects.contentText.Position = Vector2.new(contentX, contentY)

    -- Minimize box (jika di-minimize)
    objects.minimizeBox.Position = Vector2.new(winX, winY)
    objects.minimizeBox.Size = Vector2.new(minW, minH)
    objects.minimizeText.Position = Vector2.new(winX + (minW/2) - 60, winY + (minH/2) - 10)
end

-- Fungsi untuk mengubah konten berdasarkan menu yang dipilih
local function SetMenu(menuIndex)
    currentMenu = menuIndex
    local menuNames = {"Main", "Teleport", "Setting"}
    objects.contentText.Text = "Ini adalah menu " .. menuNames[menuIndex] .. "\nKonten bisa ditambahkan nanti."
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
    objects.mainBtn.Visible = not isMinimized
    objects.mainText.Visible = not isMinimized
    objects.tpBtn.Visible = not isMinimized
    objects.tpText.Visible = not isMinimized
    objects.settingBtn.Visible = not isMinimized
    objects.settingText.Visible = not isMinimized
    objects.divider.Visible = not isMinimized
    objects.contentArea.Visible = not isMinimized
    objects.contentText.Visible = not isMinimized
    objects.minimizeBox.Visible = isMinimized
    objects.minimizeText.Visible = isMinimized
end

-- Fungsi untuk membuat UI
local function CreateUI()
    -- Buat objek-objek utama
    objects.bg = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.15, 0.15, 0.15),
        Transparency = 0.2,
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
        Font = 2, -- Bold (tergantung executor, mungkin 2 untuk bold)
        Visible = true,
        ZIndex = 3
    })

    -- Tombol Close (X)
    objects.closeBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(1, 0.3, 0.3),
        Transparency = 0,
        Visible = true,
        ZIndex = 2
    })
    objects.closeText = NewDrawing("Text", {
        Text = "X",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = true,
        Font = 2,
        Visible = true,
        ZIndex = 3
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
        ZIndex = 2
    })
    objects.minText = NewDrawing("Text", {
        Text = "-",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = true,
        Font = 2,
        Visible = true,
        ZIndex = 3
    })
    NewButton(objects.minBtn, function()
        ToggleMinimize()
    end)

    -- Minimize box (awalnya hidden)
    objects.minimizeBox = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.2, 0.2, 0.2),
        Transparency = 0,
        Visible = false,
        ZIndex = 1
    })
    objects.minimizeText = NewDrawing("Text", {
        Text = "Script BY Azka",
        Color = Color3.new(1, 1, 1),
        Size = 18,
        Center = true,
        Font = 2,
        Visible = false,
        ZIndex = 2
    })
    NewButton(objects.minimizeBox, function()
        ToggleMinimize()
    end)

    -- Menu buttons
    objects.mainBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.25, 0.25, 0.25),
        Transparency = 0,
        Visible = true,
        ZIndex = 2
    })
    objects.mainText = NewDrawing("Text", {
        Text = "Main",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = false,
        Font = 2,
        Visible = true,
        ZIndex = 3
    })
    NewButton(objects.mainBtn, function() SetMenu(1) end)

    objects.tpBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.25, 0.25, 0.25),
        Transparency = 0,
        Visible = true,
        ZIndex = 2
    })
    objects.tpText = NewDrawing("Text", {
        Text = "Teleport",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = false,
        Font = 2,
        Visible = true,
        ZIndex = 3
    })
    NewButton(objects.tpBtn, function() SetMenu(2) end)

    objects.settingBtn = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.25, 0.25, 0.25),
        Transparency = 0,
        Visible = true,
        ZIndex = 2
    })
    objects.settingText = NewDrawing("Text", {
        Text = "Setting",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = false,
        Font = 2,
        Visible = true,
        ZIndex = 3
    })
    NewButton(objects.settingBtn, function() SetMenu(3) end)

    -- Garis pemisah vertikal
    objects.divider = NewDrawing("Line", {
        Thickness = 2,
        Color = Color3.new(1, 1, 1),
        Transparency = 0,
        Visible = true,
        ZIndex = 2
    })

    -- Area konten
    objects.contentArea = NewDrawing("Square", {
        Filled = true,
        Color = Color3.new(0.1, 0.1, 0.1),
        Transparency = 0.2,
        Visible = true,
        ZIndex = 1
    })
    objects.contentText = NewDrawing("Text", {
        Text = "Selamat datang di Script BY Azka",
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = true,
        Font = 2,
        Visible = true,
        ZIndex = 2
    })

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
        for _, btn in ipairs(buttons) do
            local area = btn.area
            if area.Visible then
                local btnPos = area.Position
                local btnSize = area.Size
                if mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                   mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y then
                    btn.callback()
                    break
                end
            end
        end

        -- Cek drag di title bar (hanya jika tidak minimize)
        if not isMinimized then
            local mousePos = UserInputService:GetMouseLocation()
            local titleBar = objects.titleBar
            if mousePos.X >= titleBar.Position.X and mousePos.X <= titleBar.Position.X + titleBar.Size.X and
               mousePos.Y >= titleBar.Position.Y and mousePos.Y <= titleBar.Position.Y + titleBar.Size.Y then
                isDragging = true
                dragOffsetX = mousePos.X - winX
                dragOffsetY = mousePos.Y - winY
            end
        end
    end
end

local inputConn = UserInputService.InputBegan:Connect(OnInputBegan)

-- Loop untuk drag (RenderStepped lebih halus)
local dragConn
dragConn = RunService.RenderStepped:Connect(function()
    if isDragging then
        local mousePos = UserInputService:GetMouseLocation()
        winX = mousePos.X - dragOffsetX
        winY = mousePos.Y - dragOffsetY
        UpdatePositions()

        -- Jika mouse dilepas, stop drag
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            isDragging = false
        end
    end
end)

-- Simpan koneksi untuk cleanup
_G.AzkaUI.Cleanup = Cleanup
_G.AzkaUI.Connections = {inputConn, dragConn}

-- Notifikasi
print("Azka UI berhasil dimuat. Tekan X untuk menutup.")
