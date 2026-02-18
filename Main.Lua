-- Remote Console untuk Delta Executor (Versi Aman)
-- Menampilkan data yang dikirim dan diterima oleh RemoteFunction

-- Gunakan pcall untuk menangkap error di seluruh skrip
local success, err = pcall(function()

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
local MAX_LOG_COUNT = 100
local EVENTS_FOLDER_PATH = "Events"

-- ================== FUNGSI SERIALIZE ==================
local function serialize(val, depth)
    depth = depth or 0
    if depth > 3 then return "{...}" end

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
        local success, className = pcall(function() return val.ClassName end)
        if success and className then
            local name = pcall(function() return val.Name end) and val.Name or "?"
            return string.format("Instance[%s: '%s']", className, name)
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
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Tempatkan di CoreGui jika memungkinkan, fallback ke PlayerGui
local parentGui = CoreGui
local setParentSuccess = pcall(function() gui.Parent = parentGui end)
if not setParentSuccess or not gui.Parent then
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
title.Text = "Remote Console (Delta)"
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

-- Panel kiri (daftar remote)
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 150, 1, -40)
leftPanel.Position = UDim2.new(0, 5, 0, 35)
leftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
leftPanel.BackgroundTransparency = 0.2
leftPanel.BorderSizePixel = 1
leftPanel.BorderColor3 = Color3.fromRGB(100, 100, 100)
leftPanel.Parent = mainFrame

local leftTitle = Instance.new("TextLabel")
leftTitle.Size = UDim2.new(1, 0, 0, 25)
leftTitle.BackgroundTransparency = 1
leftTitle.Text = "Remote List"
leftTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
leftTitle.Font = Enum.Font.SourceSansBold
leftTitle.TextSize = 16
leftTitle.Parent = leftPanel

local remoteList = Instance.new("ScrollingFrame")
remoteList.Size = UDim2.new(1, -10, 1, -30)
remoteList.Position = UDim2.new(0, 5, 0, 25)
remoteList.BackgroundTransparency = 1
remoteList.ScrollBarThickness = 8
remoteList.CanvasSize = UDim2.new(0, 0, 0, 0)
remoteList.Parent = leftPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = remoteList

local function updateRemoteListCanvas()
    remoteList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRemoteListCanvas)

-- Panel kanan (log console)
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -165, 1, -40)
rightPanel.Position = UDim2.new(0, 160, 0, 35)
rightPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightPanel.BackgroundTransparency = 0.2
rightPanel.BorderSizePixel = 1
rightPanel.BorderColor3 = Color3.fromRGB(100, 100, 100)
rightPanel.Parent = mainFrame

local logScroller = Instance.new("ScrollingFrame")
logScroller.Size = UDim2.new(1, -10, 1, -10)
logScroller.Position = UDim2.new(0, 5, 0, 5)
logScroller.BackgroundTransparency = 1
logScroller.ScrollBarThickness = 8
logScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroller.Parent = rightPanel

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 3)
logLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logScroller

local function updateLogCanvas()
    logScroller.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 10)
end
logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLogCanvas)

-- ================== DATA LOG DAN FILTER ==================
local logs = {}
local filterRemote = nil  -- nil = semua, string = nama remote

local function addLog(remoteName, argsStr, resultStr, isError, timeStr)
    local logEntry = {
        name = remoteName,
        time = timeStr,
        args = argsStr,
        result = resultStr,
        isError = isError
    }
    table.insert(logs, logEntry)
    if #logs > MAX_LOG_COUNT then
        table.remove(logs, 1)
    end
    refreshDisplay()
end

function refreshDisplay()
    for _, child in ipairs(logScroller:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for _, log in ipairs(logs) do
        if filterRemote == nil or log.name == filterRemote then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 0)
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
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.Parent = logScroller
        end
    end
    updateLogCanvas()
end

-- ================== MEMBUAT TOMBOL REMOTE ==================
local buttons = {}

local function createRemoteButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = remoteList

    btn.MouseEnter:Connect(function()
        if filterRemote ~= name then
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
    btn.MouseLeave:Connect(function()
        if filterRemote == name then
            btn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if filterRemote == name then
            filterRemote = nil
            for _, b in pairs(buttons) do
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
            allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
        else
            filterRemote = name
            for _, b in pairs(buttons) do
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
            btn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
            allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
        refreshDisplay()
    end)

    buttons[name] = btn
end

-- Tombol "Semua"
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

for _, name in ipairs(REMOTE_NAMES) do
    createRemoteButton(name)
end

-- ================== HOOK REMOTEFUNCTION DENGAN AMAN ==================
local eventsFolder = ReplicatedStorage:FindFirstChild(EVENTS_FOLDER_PATH)
if not eventsFolder then
    addLog("SYSTEM", "", "Folder Events tidak ditemukan! Pastikan path benar.", true, os.date("%H:%M:%S"))
else
    for _, name in ipairs(REMOTE_NAMES) do
        local remote = eventsFolder:FindFirstChild(name)
        if remote and remote:IsA("RemoteFunction") then
            -- Cegah hook ganda
            if remote._hooked then continue end
            remote._hooked = true

            local oldInvoke = remote.Invoke
            remote.Invoke = function(self, ...)
                local args = {...}
                local timeStr = os.date("%H:%M:%S")
                
                -- Serialisasi argumen dengan aman
                local argsStr = ""
                for i, arg in ipairs(args) do
                    if i > 1 then argsStr = argsStr .. ", " end
                    local serialized = pcall(serialize, arg) and serialize(arg) or tostring(arg)
                    argsStr = argsStr .. serialized
                end
                if #args == 0 then argsStr = "(no args)" end

                -- Panggil fungsi asli dengan pcall
                local success, result = pcall(function()
                    return oldInvoke(self, unpack(args))
                end)
                
                if success then
                    local resultStr = pcall(serialize, result) and serialize(result) or tostring(result)
                    addLog(name, argsStr, resultStr, false, timeStr)
                    return result
                else
                    -- result adalah error message
                    addLog(name, argsStr, tostring(result), true, timeStr)
                    error(result)  -- Lempar ulang error
                end
            end
        else
            addLog("SYSTEM", "", "RemoteFunction " .. name .. " tidak ditemukan atau bukan RemoteFunction", true, os.date("%H:%M:%S"))
        end
    end
end

addLog("SYSTEM", "", "Console siap. Menunggu aktivitas RemoteFunction...", false, os.date("%H:%M:%S"))

print("Remote Console berhasil dijalankan (versi aman)")

end) -- penutup pcall

if not success then
    warn("Terjadi error saat menjalankan Remote Console: " .. tostring(err))
    -- Tampilkan UI sederhana untuk memberi tahu error
    local gui = Instance.new("ScreenGui")
    gui.Name = "ErrorNotification"
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then
        gui.Parent = Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    if gui.Parent then
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 400, 0, 100)
        frame.Position = UDim2.new(0.5, -200, 0.5, -50)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        frame.Parent = gui
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, -20)
        label.Position = UDim2.new(0, 10, 0, 10)
        label.BackgroundTransparency = 1
        label.Text = "Error: " .. tostring(err) .. "\n\nCek apakah game mendukung dan coba jalankan ulang."
        label.TextColor3 = Color3.fromRGB(255, 100, 100)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextWrapped = true
        label.Parent = frame
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 60, 0, 25)
        closeBtn.Position = UDim2.new(0.5, -30, 1, -30)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.Text = "Tutup"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.SourceSans
        closeBtn.TextSize = 16
        closeBtn.Parent = frame
        closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    end
end
