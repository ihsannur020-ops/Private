-- Remote Console untuk Delta Executor
-- Menampilkan data yang dikirim dan diterima oleh RemoteFunction tertentu

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

if not player then
    warn("Tidak dapat menemukan pemain lokal.")
    return
end

-- ================== KONFIGURASI ==================
local REMOTE_NAMES = {"Speed", "Rebirth", "Carry", "Brainrots", "SellDialogue", "Upgrade"}
local MAX_LOG_COUNT = 100  -- Batas maksimal log yang disimpan
local EVENTS_FOLDER_PATH = "Events"  -- Nama folder di ReplicatedStorage

-- ================== FUNGSI SERIALIZE ==================
local function serialize(val, depth)
    depth = depth or 0
    if depth > 3 then return "{...}" end  -- Batasi kedalaman untuk menghindari loop

    local t = type(val)
    if t == "string" then
        return string.format("%q", val)
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "nil" then
        return "nil"
    elseif t == "table" then
        local parts = {}
        for k, v in pairs(val) do
            local ks = serialize(k, depth + 1)
            local vs = serialize(v, depth + 1)
            table.insert(parts, string.format("[%s] = %s", ks, vs))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif t == "userdata" then
        -- Cek apakah instance Roblox
        local success, className = pcall(function() return val.ClassName end)
        if success then
            return string.format("Instance[%s: '%s']", className, val.Name)
        else
            return tostring(val)
        end
    else
        return tostring(val)
    end
end

-- ================== MEMBUAT UI CONSOLE ==================
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteConsole"
gui.ResetOnSpawn = false

-- Tempatkan di CoreGui jika memungkinkan
local parentGui = CoreGui
pcall(function() gui.Parent = parentGui end)
if not gui.Parent then
    gui.Parent = player:WaitForChild("PlayerGui")
end

-- Frame utama (dapat digeser)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 700, 0, 450)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(200, 200, 200)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- Judul UI
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Remote Console"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = mainFrame

-- Tombol tutup
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ================== PANEL KIRI (DAFTAR REMOTE) ==================
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 150, 1, -40)
leftPanel.Position = UDim2.new(0, 5, 0, 35)
leftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
leftPanel.BackgroundTransparency = 0.2
leftPanel.BorderSizePixel = 1
leftPanel.BorderColor3 = Color3.fromRGB(100, 100, 100)
leftPanel.Parent = mainFrame

-- Label panel kiri
local leftTitle = Instance.new("TextLabel")
leftTitle.Size = UDim2.new(1, 0, 0, 25)
leftTitle.BackgroundTransparency = 1
leftTitle.Text = "Remote List"
leftTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
leftTitle.Font = Enum.Font.SourceSansBold
leftTitle.TextSize = 16
leftTitle.Parent = leftPanel

-- ScrollingFrame untuk tombol remote
local remoteList = Instance.new("ScrollingFrame")
remoteList.Size = UDim2.new(1, -10, 1, -30)
remoteList.Position = UDim2.new(0, 5, 0, 25)
remoteList.BackgroundTransparency = 1
remoteList.ScrollBarThickness = 8
remoteList.CanvasSize = UDim2.new(0, 0, 0, 0)
remoteList.Parent = leftPanel

-- UIListLayout untuk mengatur tombol remote
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = remoteList

-- Fungsi untuk memperbarui CanvasSize remoteList
local function updateRemoteListCanvas()
    remoteList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRemoteListCanvas)

-- ================== PANEL KANAN (LOG CONSOLE) ==================
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -165, 1, -40)
rightPanel.Position = UDim2.new(0, 160, 0, 35)
rightPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightPanel.BackgroundTransparency = 0.2
rightPanel.BorderSizePixel = 1
rightPanel.BorderColor3 = Color3.fromRGB(100, 100, 100)
rightPanel.Parent = mainFrame

-- ScrollingFrame untuk log
local logScroller = Instance.new("ScrollingFrame")
logScroller.Size = UDim2.new(1, -10, 1, -10)
logScroller.Position = UDim2.new(0, 5, 0, 5)
logScroller.BackgroundTransparency = 1
logScroller.ScrollBarThickness = 8
logScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroller.Parent = rightPanel

-- UIListLayout untuk log
local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 3)
logLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logScroller

-- Fungsi untuk memperbarui CanvasSize logScroller
local function updateLogCanvas()
    logScroller.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 10)
end
logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLogCanvas)

-- ================== DATA LOG DAN FILTER ==================
local logs = {}  -- Menyimpan semua log
local filterRemote = nil  -- nil = semua, string = nama remote tertentu

-- Fungsi untuk menambahkan log baru
local function addLog(remoteName, argsStr, resultStr, isError, timeStr)
    -- Buat entri log
    local logEntry = {
        name = remoteName,
        time = timeStr,
        args = argsStr,
        result = resultStr,
        isError = isError
    }
    table.insert(logs, logEntry)

    -- Hapus log tertua jika melebihi batas
    if #logs > MAX_LOG_COUNT then
        table.remove(logs, 1)
    end

    -- Refresh tampilan
    refreshDisplay()
end

-- Fungsi untuk merefresh tampilan log berdasarkan filter
function refreshDisplay()
    -- Hapus semua label log
    for _, child in ipairs(logScroller:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    -- Tambahkan log yang sesuai filter
    for _, log in ipairs(logs) do
        if filterRemote == nil or log.name == filterRemote then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 0)  -- Tinggi akan otomatis
            label.BackgroundColor3 = log.isError and Color3.fromRGB(80, 30, 30) or Color3.fromRGB(40, 40, 40)
            label.BackgroundTransparency = 0.3
            label.BorderSizePixel = 1
            label.BorderColor3 = Color3.fromRGB(80, 80, 80)
            label.Text = string.format("[%s] [%s] Args: %s | Return: %s", log.time, log.name, log.args, log.result)
            label.TextColor3 = log.isError and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(220, 220, 220)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.TextWrapped = true
            label.RichText = false
            label.AutomaticSize = Enum.AutomaticSize.Y  -- Tinggi menyesuaikan konten
            label.Parent = logScroller
        end
    end

    -- Perbarui canvas
    updateLogCanvas()
end

-- ================== MEMBUAT TOMBOL REMOTE ==================
local buttons = {}  -- Menyimpan tombol untuk referensi

-- Fungsi untuk membuat tombol remote
local function createRemoteButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = remoteList

    -- Efek hover
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    btn.MouseLeave:Connect(function()
        if filterRemote == name then
            btn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end)

    -- Klik untuk mengatur filter
    btn.MouseButton1Click:Connect(function()
        if filterRemote == name then
            -- Jika sudah dipilih, reset ke semua
            filterRemote = nil
            for _, b in pairs(buttons) do
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        else
            filterRemote = name
            for _, b in pairs(buttons) do
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
            btn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
        end
        refreshDisplay()
    end)

    buttons[name] = btn
end

-- Buat tombol "Semua" untuk reset filter
local allBtn = Instance.new("TextButton")
allBtn.Size = UDim2.new(1, -10, 0, 30)
allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
allBtn.Text = "Semua"
allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
allBtn.Font = Enum.Font.SourceSansBold
allBtn.TextSize = 16
allBtn.Parent = remoteList
allBtn.MouseButton1Click:Connect(function()
    filterRemote = nil
    for _, b in pairs(buttons) do
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
    allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    refreshDisplay()
end)

-- Buat tombol untuk setiap remote
for _, name in ipairs(REMOTE_NAMES) do
    createRemoteButton(name)
end

-- Set tombol "Semua" aktif di awal
allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)

-- ================== HOOK REMOTEFUNCTION ==================
local eventsFolder = ReplicatedStorage:FindFirstChild(EVENTS_FOLDER_PATH)
if not eventsFolder then
    warn("Folder Events tidak ditemukan di ReplicatedStorage")
    -- Tampilkan pesan di console
    local warnLabel = Instance.new("TextLabel")
    warnLabel.Size = UDim2.new(1, -10, 0, 30)
    warnLabel.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
    warnLabel.Text = "Folder Events tidak ditemukan!"
    warnLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
    warnLabel.Font = Enum.Font.SourceSans
    warnLabel.TextSize = 14
    warnLabel.Parent = logScroller
else
    -- Hook setiap remote yang ada
    for _, name in ipairs(REMOTE_NAMES) do
        local remote = eventsFolder:FindFirstChild(name)
        if remote and remote:IsA("RemoteFunction") then
            -- Cegah hook ganda (optional)
            if remote._hooked then continue end
            remote._hooked = true

            local oldInvoke = remote.Invoke
            remote.Invoke = function(self, ...)
                local args = {...}
                local timeStr = os.date("%H:%M:%S")
                
                -- Serialisasi argumen
                local argsStr = ""
                for i, arg in ipairs(args) do
                    if i > 1 then argsStr = argsStr .. ", " end
                    argsStr = argsStr .. serialize(arg)
                end
                if #args == 0 then argsStr = "(no args)" end

                -- Panggil fungsi asli
                local success, result = pcall(function() return oldInvoke(self, ...) end)
                
                if success then
                    local resultStr = serialize(result)
                    addLog(name, argsStr, resultStr, false, timeStr)
                    return result
                else
                    -- result adalah error message
                    addLog(name, argsStr, serialize(result), true, timeStr)
                    error(result)  -- Lempar ulang error
                end
            end
        else
            warn("RemoteFunction " .. name .. " tidak ditemukan")
        end
    end
end

-- Pesan inisialisasi
addLog("SYSTEM", "", "Console siap. Menunggu aktivitas RemoteFunction...", false, os.date("%H:%M:%S"))

-- ================== SELESAI ==================
print("Remote Console berhasil dijalankan")
