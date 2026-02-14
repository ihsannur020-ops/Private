--[[
	Script BY Azka - Ultimate Controller (Final + Kavo Style)
	- Menggunakan library Kavo yang dimodifikasi untuk multiple window
	- WalkSpeed slider (1-200) dengan nilai di pojok kanan
	- Boost slider (0-500) dengan nilai di pojok kanan
	- Inf Jump, Noclip, God Mode, Instant Proximity, Infinite Zoom, Freecam
	- Teleport UI dengan Live Players dan TP Camera
	- Semua UI dapat di-drag, close, minimize (icon bulat)
	- Settings UI dengan Anti-AFK, Server Hop, Respawn
]]

-- Hapus GUI lama
local CoreGui = game:GetService("CoreGui")
for _, name in ipairs({"ScriptBYAzka", "AzkaFlyUI", "AzkaTeleportUI", "AzkaFPSUI", "AzkaScriptLibUI", "AzkaSettingsUI"}) do
	local existing = CoreGui:FindFirstChild(name)
	if existing then existing:Destroy() end
end

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- ==================== LIBRARY KAVO (MODIFIED FOR MULTIPLE WINDOWS) ====================
local Kavo = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

local Utility = {}
local Objects = {}

function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

-- Tema default
local defaultTheme = {
    SchemeColor = Color3.fromRGB(74, 99, 135),
    Background = Color3.fromRGB(36, 37, 43),
    Header = Color3.fromRGB(28, 29, 34),
    TextColor = Color3.fromRGB(255,255,255),
    ElementColor = Color3.fromRGB(32, 32, 38)
}

-- Fungsi untuk membuat window baru
function Kavo:CreateWindow(title, theme)
    theme = theme or defaultTheme
    local window = {}
    local LibName = "KavoWindow_" .. tostring(math.random(1, 100000))

    -- Buat ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = LibName
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = theme.Background
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.336503863, 0, 0.275485456, 0)
    Main.Size = UDim2.new(0, 525, 0, 318)
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)
    Kavo:DraggingEnabled(Main, Main) -- biar bisa drag dari mana saja

    -- Header
    local MainHeader = Instance.new("Frame")
    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = theme.Header
    MainHeader.Size = UDim2.new(0, 525, 0, 29)
    Instance.new("UICorner", MainHeader).CornerRadius = UDim.new(0, 4)

    local coverup = Instance.new("Frame")
    coverup.Name = "coverup"
    coverup.Parent = MainHeader
    coverup.BackgroundColor3 = theme.Header
    coverup.BorderSizePixel = 0
    coverup.Position = UDim2.new(0, 0, 0.758620679, 0)
    coverup.Size = UDim2.new(0, 525, 0, 7)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "title"
    titleLabel.Parent = MainHeader
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0.0171428565, 0, 0.344827592, 0)
    titleLabel.Size = UDim2.new(0, 204, 0, 8)
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.RichText = true
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button
    local close = Instance.new("ImageButton")
    close.Name = "close"
    close.Parent = MainHeader
    close.BackgroundTransparency = 1
    close.Position = UDim2.new(0.949999988, 0, 0.137999997, 0)
    close.Size = UDim2.new(0, 21, 0, 21)
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Side panel untuk tab
    local MainSide = Instance.new("Frame")
    MainSide.Name = "MainSide"
    MainSide.Parent = Main
    MainSide.BackgroundColor3 = theme.Header
    MainSide.Position = UDim2.new(-7.4505806e-09, 0, 0.0911949649, 0)
    MainSide.Size = UDim2.new(0, 149, 0, 289)
    Instance.new("UICorner", MainSide).CornerRadius = UDim.new(0, 4)

    local coverup_2 = Instance.new("Frame")
    coverup_2.Name = "coverup"
    coverup_2.Parent = MainSide
    coverup_2.BackgroundColor3 = theme.Header
    coverup_2.BorderSizePixel = 0
    coverup_2.Position = UDim2.new(0.949939311, 0, 0, 0)
    coverup_2.Size = UDim2.new(0, 7, 0, 289)

    local tabFrames = Instance.new("Frame")
    tabFrames.Name = "tabFrames"
    tabFrames.Parent = MainSide
    tabFrames.BackgroundTransparency = 1
    tabFrames.Position = UDim2.new(0.0438990258, 0, -0.00066378375, 0)
    tabFrames.Size = UDim2.new(0, 135, 0, 283)

    local tabListing = Instance.new("UIListLayout", tabFrames)
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder

    local pages = Instance.new("Frame")
    pages.Name = "pages"
    pages.Parent = Main
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.new(0.299047589, 0, 0.122641519, 0)
    pages.Size = UDim2.new(0, 360, 0, 269)

    local Pages = Instance.new("Folder", pages)
    Pages.Name = "Pages"

    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "infoContainer"
    infoContainer.Parent = Main
    infoContainer.BackgroundTransparency = 1
    infoContainer.ClipsDescendants = true
    infoContainer.Position = UDim2.new(0.299047619, 0, 0.874213815, 0)
    infoContainer.Size = UDim2.new(0, 368, 0, 33)

    local blurFrame = Instance.new("Frame")
    blurFrame.Name = "blurFrame"
    blurFrame.Parent = pages
    blurFrame.BackgroundColor3 = Color3.new(0,0,0)
    blurFrame.BackgroundTransparency = 1
    blurFrame.BorderSizePixel = 0
    blurFrame.Position = UDim2.new(-0.0222222228, 0, -0.0371747203, 0)
    blurFrame.Size = UDim2.new(0, 376, 0, 289)
    blurFrame.ZIndex = 999

    -- Fungsi untuk mengupdate tema (otomatis berjalan)
    coroutine.wrap(function()
        while wait() do
            Main.BackgroundColor3 = theme.Background
            MainHeader.BackgroundColor3 = theme.Header
            MainSide.BackgroundColor3 = theme.Header
            coverup_2.BackgroundColor3 = theme.Header
            coverup.BackgroundColor3 = theme.Header
        end
    end)()

    -- Tab handling
    local Tabs = {}
    local first = true

    function Tabs:NewTab(tabName)
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local page = Instance.new("ScrollingFrame")
        local pageListing = Instance.new("UIListLayout")

        local function UpdateSize()
            local cS = pageListing.AbsoluteContentSize
            game.TweenService:Create(page, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                CanvasSize = UDim2.new(0, cS.X, 0, cS.Y)
            }):Play()
        end

        page.Name = "Page"
        page.Parent = Pages
        page.Active = true
        page.BackgroundColor3 = theme.Background
        page.BorderSizePixel = 0
        page.Position = UDim2.new(0, 0, -0.00371747208, 0)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 5
        page.Visible = false
        page.ScrollBarImageColor3 = Color3.fromRGB(theme.SchemeColor.r * 255 - 16, theme.SchemeColor.g * 255 - 15, theme.SchemeColor.b * 255 - 28)

        pageListing.Name = "pageListing"
        pageListing.Parent = page
        pageListing.SortOrder = Enum.SortOrder.LayoutOrder
        pageListing.Padding = UDim.new(0, 5)

        tabButton.Name = tabName.."TabButton"
        tabButton.Parent = tabFrames
        tabButton.BackgroundColor3 = theme.SchemeColor
        tabButton.Size = UDim2.new(0, 135, 0, 28)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = tabName
        tabButton.TextColor3 = theme.TextColor
        tabButton.TextSize = 14
        tabButton.BackgroundTransparency = 1

        if first then
            first = false
            page.Visible = true
            tabButton.BackgroundTransparency = 0
            UpdateSize()
        else
            page.Visible = false
            tabButton.BackgroundTransparency = 1
        end

        UICorner.CornerRadius = UDim.new(0, 5)
        UICorner.Parent = tabButton

        UpdateSize()
        page.ChildAdded:Connect(UpdateSize)
        page.ChildRemoved:Connect(UpdateSize)

        tabButton.MouseButton1Click:Connect(function()
            UpdateSize()
            for _, v in next, Pages:GetChildren() do
                v.Visible = false
            end
            page.Visible = true
            for _, v in next, tabFrames:GetChildren() do
                if v:IsA("TextButton") then
                    Utility:TweenObject(v, {BackgroundTransparency = 1}, 0.2)
                end
            end
            Utility:TweenObject(tabButton, {BackgroundTransparency = 0}, 0.2)
        end)

        local Sections = {}

        coroutine.wrap(function()
            while wait() do
                page.BackgroundColor3 = theme.Background
                page.ScrollBarImageColor3 = Color3.fromRGB(theme.SchemeColor.r * 255 - 16, theme.SchemeColor.g * 255 - 15, theme.SchemeColor.b * 255 - 28)
                tabButton.TextColor3 = theme.TextColor
                tabButton.BackgroundColor3 = theme.SchemeColor
            end
        end)()

        function Sections:NewSection(secName, hidden)
            local sectionFunctions = {}
            local sectionFrame = Instance.new("Frame")
            local sectionlistoknvm = Instance.new("UIListLayout")
            local sectionHead = Instance.new("Frame")
            local sHeadCorner = Instance.new("UICorner")
            local sectionName = Instance.new("TextLabel")
            local sectionInners = Instance.new("Frame")
            local sectionElListing = Instance.new("UIListLayout")

            if hidden then
                sectionHead.Visible = false
            else
                sectionHead.Visible = true
            end

            sectionFrame.Name = "sectionFrame"
            sectionFrame.Parent = page
            sectionFrame.BackgroundColor3 = theme.Background
            sectionFrame.BorderSizePixel = 0

            sectionlistoknvm.Name = "sectionlistoknvm"
            sectionlistoknvm.Parent = sectionFrame
            sectionlistoknvm.SortOrder = Enum.SortOrder.LayoutOrder
            sectionlistoknvm.Padding = UDim.new(0, 5)

            sectionHead.Name = "sectionHead"
            sectionHead.Parent = sectionFrame
            sectionHead.BackgroundColor3 = theme.SchemeColor
            sectionHead.Size = UDim2.new(0, 352, 0, 33)

            sHeadCorner.CornerRadius = UDim.new(0, 4)
            sHeadCorner.Parent = sectionHead

            sectionName.Name = "sectionName"
            sectionName.Parent = sectionHead
            sectionName.BackgroundTransparency = 1
            sectionName.Position = UDim2.new(0.0198863633, 0, 0, 0)
            sectionName.Size = UDim2.new(0.980113626, 0, 1, 0)
            sectionName.Font = Enum.Font.Gotham
            sectionName.Text = secName
            sectionName.RichText = true
            sectionName.TextColor3 = theme.TextColor
            sectionName.TextSize = 14
            sectionName.TextXAlignment = Enum.TextXAlignment.Left

            sectionInners.Name = "sectionInners"
            sectionInners.Parent = sectionFrame
            sectionInners.BackgroundTransparency = 1
            sectionInners.Position = UDim2.new(0, 0, 0.190751448, 0)

            sectionElListing.Name = "sectionElListing"
            sectionElListing.Parent = sectionInners
            sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionElListing.Padding = UDim.new(0, 3)

            coroutine.wrap(function()
                while wait() do
                    sectionFrame.BackgroundColor3 = theme.Background
                    sectionHead.BackgroundColor3 = theme.SchemeColor
                    sectionName.TextColor3 = theme.TextColor
                end
            end)()

            local function updateSectionFrame()
                local innerSc = sectionElListing.AbsoluteContentSize
                sectionInners.Size = UDim2.new(1, 0, 0, innerSc.Y)
                local frameSc = sectionlistoknvm.AbsoluteContentSize
                sectionFrame.Size = UDim2.new(0, 352, 0, frameSc.Y)
            end
            updateSectionFrame()
            UpdateSize()

            local Elements = {}

            -- ==================== ELEMENTS ====================
            function Elements:NewButton(bname, tip, callback)
                tip = tip or "Tip: Clicking this nothing will happen!"
                callback = callback or function() end

                local buttonElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local btnInfo = Instance.new("TextLabel")
                local viewInfo = Instance.new("ImageButton")
                local touch = Instance.new("ImageLabel")
                local Sample = Instance.new("ImageLabel")

                buttonElement.Name = bname
                buttonElement.Parent = sectionInners
                buttonElement.BackgroundColor3 = theme.ElementColor
                buttonElement.ClipsDescendants = true
                buttonElement.Size = UDim2.new(0, 352, 0, 33)
                buttonElement.AutoButtonColor = false
                buttonElement.Font = Enum.Font.SourceSans
                buttonElement.Text = ""
                buttonElement.TextColor3 = Color3.new(0,0,0)
                buttonElement.TextSize = 14

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = buttonElement

                viewInfo.Name = "viewInfo"
                viewInfo.Parent = buttonElement
                viewInfo.BackgroundTransparency = 1
                viewInfo.LayoutOrder = 9
                viewInfo.Position = UDim2.new(0.93, 0, 0.152, 0)
                viewInfo.Size = UDim2.new(0, 23, 0, 23)
                viewInfo.Image = "rbxassetid://3926305904"
                viewInfo.ImageColor3 = theme.SchemeColor
                viewInfo.ImageRectOffset = Vector2.new(764, 764)
                viewInfo.ImageRectSize = Vector2.new(36, 36)

                Sample.Name = "Sample"
                Sample.Parent = buttonElement
                Sample.BackgroundTransparency = 1
                Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
                Sample.ImageColor3 = theme.SchemeColor
                Sample.ImageTransparency = 0.6

                local moreInfo = Instance.new("TextLabel")
                local UICornerMI = Instance.new("UICorner")
                moreInfo.Name = "TipMore"
                moreInfo.Parent = infoContainer
                moreInfo.BackgroundColor3 = Color3.fromRGB(theme.SchemeColor.r * 255 - 14, theme.SchemeColor.g * 255 - 17, theme.SchemeColor.b * 255 - 13)
                moreInfo.Position = UDim2.new(0, 0, 2, 0)
                moreInfo.Size = UDim2.new(0, 353, 0, 33)
                moreInfo.ZIndex = 9
                moreInfo.Font = Enum.Font.GothamSemibold
                moreInfo.Text = "  "..tip
                moreInfo.RichText = true
                moreInfo.TextColor3 = theme.TextColor
                moreInfo.TextSize = 14
                moreInfo.TextXAlignment = Enum.TextXAlignment.Left
                UICornerMI.CornerRadius = UDim.new(0, 4)
                UICornerMI.Parent = moreInfo

                touch.Name = "touch"
                touch.Parent = buttonElement
                touch.BackgroundTransparency = 1
                touch.Position = UDim2.new(0.02, 0, 0.18, 0)
                touch.Size = UDim2.new(0, 21, 0, 21)
                touch.Image = "rbxassetid://3926305904"
                touch.ImageColor3 = theme.SchemeColor
                touch.ImageRectOffset = Vector2.new(84, 204)
                touch.ImageRectSize = Vector2.new(36, 36)

                btnInfo.Name = "btnInfo"
                btnInfo.Parent = buttonElement
                btnInfo.BackgroundTransparency = 1
                btnInfo.Position = UDim2.new(0.096704483, 0, 0.272727281, 0)
                btnInfo.Size = UDim2.new(0, 314, 0, 14)
                btnInfo.Font = Enum.Font.GothamSemibold
                btnInfo.Text = bname
                btnInfo.RichText = true
                btnInfo.TextColor3 = theme.TextColor
                btnInfo.TextSize = 14
                btnInfo.TextXAlignment = Enum.TextXAlignment.Left

                updateSectionFrame()
                UpdateSize()

                local ms = player:GetMouse()
                local btn = buttonElement
                local sample = Sample
                local focusing = false -- dari luar (untuk info)

                btn.MouseButton1Click:Connect(function()
                    callback()
                    local c = sample:Clone()
                    c.Parent = btn
                    local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
                    c.Position = UDim2.new(0, x, 0, y)
                    local len, size = 0.35, nil
                    if btn.AbsoluteSize.X >= btn.AbsoluteSize.Y then
                        size = btn.AbsoluteSize.X * 1.5
                    else
                        size = btn.AbsoluteSize.Y * 1.5
                    end
                    c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, -size/2, 0.5, -size/2), 'Out', 'Quad', len, true, nil)
                    for i = 1, 10 do
                        c.ImageTransparency = c.ImageTransparency + 0.05
                        wait(len / 12)
                    end
                    c:Destroy()
                end)

                local hovering = false
                btn.MouseEnter:Connect(function()
                    game.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(theme.ElementColor.r * 255 + 8, theme.ElementColor.g * 255 + 9, theme.ElementColor.b * 255 + 10)}):Play()
                    hovering = true
                end)
                btn.MouseLeave:Connect(function()
                    game.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.ElementColor}):Play()
                    hovering = false
                end)

                viewInfo.MouseButton1Click:Connect(function()
                    -- tampilkan info
                    for _, v in ipairs(infoContainer:GetChildren()) do
                        if v ~= moreInfo then
                            Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                        end
                    end
                    Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,0,0)}, 0.2)
                    Utility:TweenObject(blurFrame, {BackgroundTransparency = 0.5}, 0.2)
                    wait(1.5)
                    Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,2,0)}, 0.2)
                    Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
                end)

                coroutine.wrap(function()
                    while wait() do
                        if not hovering then
                            buttonElement.BackgroundColor3 = theme.ElementColor
                        end
                        viewInfo.ImageColor3 = theme.SchemeColor
                        Sample.ImageColor3 = theme.SchemeColor
                        moreInfo.BackgroundColor3 = Color3.fromRGB(theme.SchemeColor.r * 255 - 14, theme.SchemeColor.g * 255 - 17, theme.SchemeColor.b * 255 - 13)
                        moreInfo.TextColor3 = theme.TextColor
                        touch.ImageColor3 = theme.SchemeColor
                        btnInfo.TextColor3 = theme.TextColor
                    end
                end)()

                return {UpdateButton = function(newText) btnInfo.Text = newText end}
            end

            function Elements:NewToggle(tname, tip, callback)
                local toggled = false
                local toggleElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local toggleDisabled = Instance.new("ImageLabel")
                local toggleEnabled = Instance.new("ImageLabel")
                local togName = Instance.new("TextLabel")
                local viewInfo = Instance.new("ImageButton")
                local Sample = Instance.new("ImageLabel")

                toggleElement.Name = "toggleElement"
                toggleElement.Parent = sectionInners
                toggleElement.BackgroundColor3 = theme.ElementColor
                toggleElement.ClipsDescendants = true
                toggleElement.Size = UDim2.new(0, 352, 0, 33)
                toggleElement.AutoButtonColor = false
                toggleElement.Font = Enum.Font.SourceSans
                toggleElement.Text = ""
                toggleElement.TextColor3 = Color3.new(0,0,0)
                toggleElement.TextSize = 14

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = toggleElement

                toggleDisabled.Name = "toggleDisabled"
                toggleDisabled.Parent = toggleElement
                toggleDisabled.BackgroundTransparency = 1
                toggleDisabled.Position = UDim2.new(0.02, 0, 0.18, 0)
                toggleDisabled.Size = UDim2.new(0, 21, 0, 21)
                toggleDisabled.Image = "rbxassetid://3926309567"
                toggleDisabled.ImageColor3 = theme.SchemeColor
                toggleDisabled.ImageRectOffset = Vector2.new(628, 420)
                toggleDisabled.ImageRectSize = Vector2.new(48, 48)

                toggleEnabled.Name = "toggleEnabled"
                toggleEnabled.Parent = toggleElement
                toggleEnabled.BackgroundTransparency = 1
                toggleEnabled.Position = UDim2.new(0.02, 0, 0.18, 0)
                toggleEnabled.Size = UDim2.new(0, 21, 0, 21)
                toggleEnabled.Image = "rbxassetid://3926309567"
                toggleEnabled.ImageColor3 = theme.SchemeColor
                toggleEnabled.ImageRectOffset = Vector2.new(784, 420)
                toggleEnabled.ImageRectSize = Vector2.new(48, 48)
                toggleEnabled.ImageTransparency = 1

                togName.Name = "togName"
                togName.Parent = toggleElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0.096704483, 0, 0.272727281, 0)
                togName.Size = UDim2.new(0, 288, 0, 14)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = tname
                togName.RichText = true
                togName.TextColor3 = theme.TextColor
                togName.TextSize = 14
                togName.TextXAlignment = Enum.TextXAlignment.Left

                viewInfo.Name = "viewInfo"
                viewInfo.Parent = toggleElement
                viewInfo.BackgroundTransparency = 1
                viewInfo.LayoutOrder = 9
                viewInfo.Position = UDim2.new(0.93, 0, 0.152, 0)
                viewInfo.Size = UDim2.new(0, 23, 0, 23)
                viewInfo.Image = "rbxassetid://3926305904"
                viewInfo.ImageColor3 = theme.SchemeColor
                viewInfo.ImageRectOffset = Vector2.new(764, 764)
                viewInfo.ImageRectSize = Vector2.new(36, 36)

                Sample.Name = "Sample"
                Sample.Parent = toggleElement
                Sample.BackgroundTransparency = 1
                Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
                Sample.ImageColor3 = theme.SchemeColor
                Sample.ImageTransparency = 0.6

                local moreInfo = Instance.new("TextLabel")
                local UICornerMI = Instance.new("UICorner")
                moreInfo.Name = "TipMore"
                moreInfo.Parent = infoContainer
                moreInfo.BackgroundColor3 = Color3.fromRGB(theme.SchemeColor.r * 255 - 14, theme.SchemeColor.g * 255 - 17, theme.SchemeColor.b * 255 - 13)
                moreInfo.Position = UDim2.new(0, 0, 2, 0)
                moreInfo.Size = UDim2.new(0, 353, 0, 33)
                moreInfo.ZIndex = 9
                moreInfo.Font = Enum.Font.GothamSemibold
                moreInfo.Text = "  "..tip
                moreInfo.RichText = true
                moreInfo.TextColor3 = theme.TextColor
                moreInfo.TextSize = 14
                moreInfo.TextXAlignment = Enum.TextXAlignment.Left
                UICornerMI.CornerRadius = UDim.new(0, 4)
                UICornerMI.Parent = moreInfo

                updateSectionFrame()
                UpdateSize()

                local ms = player:GetMouse()
                local btn = toggleElement
                local sample = Sample
                local img = toggleEnabled

                btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    if toggled then
                        game.TweenService:Create(img, TweenInfo.new(0.11), {ImageTransparency = 0}):Play()
                    else
                        game.TweenService:Create(img, TweenInfo.new(0.11), {ImageTransparency = 1}):Play()
                    end
                    callback(toggled)
                    local c = sample:Clone()
                    c.Parent = btn
                    local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
                    c.Position = UDim2.new(0, x, 0, y)
                    local len, size = 0.35, nil
                    if btn.AbsoluteSize.X >= btn.AbsoluteSize.Y then
                        size = btn.AbsoluteSize.X * 1.5
                    else
                        size = btn.AbsoluteSize.Y * 1.5
                    end
                    c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, -size/2, 0.5, -size/2), 'Out', 'Quad', len, true, nil)
                    for i = 1, 10 do
                        c.ImageTransparency = c.ImageTransparency + 0.05
                        wait(len / 12)
                    end
                    c:Destroy()
                end)

                local hovering = false
                btn.MouseEnter:Connect(function()
                    game.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(theme.ElementColor.r * 255 + 8, theme.ElementColor.g * 255 + 9, theme.ElementColor.b * 255 + 10)}):Play()
                    hovering = true
                end)
                btn.MouseLeave:Connect(function()
                    game.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.ElementColor}):Play()
                    hovering = false
                end)

                viewInfo.MouseButton1Click:Connect(function()
                    for _, v in ipairs(infoContainer:GetChildren()) do
                        if v ~= moreInfo then
                            Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                        end
                    end
                    Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,0,0)}, 0.2)
                    Utility:TweenObject(blurFrame, {BackgroundTransparency = 0.5}, 0.2)
                    wait(1.5)
                    Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,2,0)}, 0.2)
                    Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
                end)

                coroutine.wrap(function()
                    while wait() do
                        if not hovering then
                            toggleElement.BackgroundColor3 = theme.ElementColor
                        end
                        toggleDisabled.ImageColor3 = theme.SchemeColor
                        toggleEnabled.ImageColor3 = theme.SchemeColor
                        togName.TextColor3 = theme.TextColor
                        viewInfo.ImageColor3 = theme.SchemeColor
                        Sample.ImageColor3 = theme.SchemeColor
                        moreInfo.BackgroundColor3 = Color3.fromRGB(theme.SchemeColor.r * 255 - 14, theme.SchemeColor.g * 255 - 17, theme.SchemeColor.b * 255 - 13)
                        moreInfo.TextColor3 = theme.TextColor
                    end
                end)()

                return {UpdateToggle = function(newText, state)
                    if newText then togName.Text = newText end
                    if state ~= nil then
                        toggled = state
                        if toggled then
                            game.TweenService:Create(img, TweenInfo.new(0.11), {ImageTransparency = 0}):Play()
                        else
                            game.TweenService:Create(img, TweenInfo.new(0.11), {ImageTransparency = 1}):Play()
                        end
                        callback(toggled)
                    end
                end}
            end

            function Elements:NewSlider(slidInf, slidTip, maxvalue, minvalue, callback)
                local sliderElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local togName = Instance.new("TextLabel")
                local viewInfo = Instance.new("ImageButton")
                local sliderBtn = Instance.new("TextButton")
                local UICorner_2 = Instance.new("UICorner")
                local UIListLayout = Instance.new("UIListLayout")
                local sliderDrag = Instance.new("Frame")
                local UICorner_3 = Instance.new("UICorner")
                local write = Instance.new("ImageLabel")
                local val = Instance.new("TextLabel")

                sliderElement.Name = "sliderElement"
                sliderElement.Parent = sectionInners
                sliderElement.BackgroundColor3 = theme.ElementColor
                sliderElement.ClipsDescendants = true
                sliderElement.Size = UDim2.new(0, 352, 0, 33)
                sliderElement.AutoButtonColor = false
                sliderElement.Font = Enum.Font.SourceSans
                sliderElement.Text = ""
                sliderElement.TextColor3 = Color3.new(0,0,0)
                sliderElement.TextSize = 14

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = sliderElement

                togName.Name = "togName"
                togName.Parent = sliderElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0.096704483, 0, 0.272727281, 0)
                togName.Size = UDim2.new(0, 138, 0, 14)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = slidInf
                togName.RichText = true
                togName.TextColor3 = theme.TextColor
                togName.TextSize = 14
                togName.TextXAlignment = Enum.TextXAlignment.Left

                viewInfo.Name = "viewInfo"
                viewInfo.Parent = sliderElement
                viewInfo.BackgroundTransparency = 1
                viewInfo.LayoutOrder = 9
                viewInfo.Position = UDim2.new(0.93, 0, 0.152, 0)
                viewInfo.Size = UDim2.new(0, 23, 0, 23)
                viewInfo.Image = "rbxassetid://3926305904"
                viewInfo.ImageColor3 = theme.SchemeColor
                viewInfo.ImageRectOffset = Vector2.new(764, 764)
                viewInfo.ImageRectSize = Vector2.new(36, 36)

                sliderBtn.Name = "sliderBtn"
                sliderBtn.Parent = sliderElement
                sliderBtn.BackgroundColor3 = Color3.fromRGB(theme.ElementColor.r * 255 + 5, theme.ElementColor.g * 255 + 5, theme.ElementColor.b * 255 + 5)
                sliderBtn.BorderSizePixel = 0
                sliderBtn.Position = UDim2.new(0.488749951, 0, 0.393939406, 0)
                sliderBtn.Size = UDim2.new(0, 149, 0, 6)
                sliderBtn.AutoButtonColor = false
                sliderBtn.Font = Enum.Font.SourceSans
                sliderBtn.Text = ""
                sliderBtn.TextColor3 = Color3.new(0,0,0)
                sliderBtn.TextSize = 14

                UICorner_2.Parent = sliderBtn

                UIListLayout.Parent = sliderBtn
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                sliderDrag.Name = "sliderDrag"
                sliderDrag.Parent = sliderBtn
                sliderDrag.BackgroundColor3 = theme.SchemeColor
                sliderDrag.BorderSizePixel = 0
                sliderDrag.Size = UDim2.new(-0.671140969, 100, 1, 0)

                UICorner_3.Parent = sliderDrag

                write.Name = "write"
                write.Parent = sliderElement
                write.BackgroundTransparency = 1
                write.Position = UDim2.new(0.02, 0, 0.18, 0)
                write.Size = UDim2.new(0, 21, 0, 21)
                write.Image = "rbxassetid://3926307971"
                write.ImageColor3 = theme.SchemeColor
                write.ImageRectOffset = Vector2.new(404, 164)
                write.ImageRectSize = Vector2.new(36, 36)

                val.Name = "val"
                val.Parent = sliderElement
                val.BackgroundTransparency = 1
                val.Position = UDim2.new(0.352386296, 0, 0.272727281, 0)
                val.Size = UDim2.new(0, 41, 0, 14)
                val.Font = Enum.Font.GothamSemibold
                val.Text = tostring(minvalue)
                val.TextColor3 = theme.TextColor
                val.TextSize = 14
                val.TextTransparency = 1
                val.TextXAlignment = Enum.TextXAlignment.Right

                local moreInfo = Instance.new("TextLabel")
                local UICornerMI = Instance.new("UICorner")
                moreInfo.Name = "TipMore"
                moreInfo.Parent = infoContainer
                moreInfo.BackgroundColor3 = Color3.fromRGB(theme.SchemeColor.r * 255 - 14, theme.SchemeColor.g * 255 - 17, theme.SchemeColor.b * 255 - 13)
                moreInfo.Position = UDim2.new(0, 0, 2, 0)
                moreInfo.Size = UDim2.new(0, 353, 0, 33)
                moreInfo.ZIndex = 9
                moreInfo.Font = Enum.Font.GothamSemibold
                moreInfo.Text = "  "..slidTip
                moreInfo.RichText = true
                moreInfo.TextColor3 = theme.TextColor
                moreInfo.TextSize = 14
                moreInfo.TextXAlignment = Enum.TextXAlignment.Left
                UICornerMI.CornerRadius = UDim.new(0, 4)
                UICornerMI.Parent = moreInfo

                updateSectionFrame()
                UpdateSize()

                local mouse = player:GetMouse()
                local uis = UserInputService
                local btn = sliderElement
                local hovering = false

                btn.MouseEnter:Connect(function()
                    game.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(theme.ElementColor.r * 255 + 8, theme.ElementColor.g * 255 + 9, theme.ElementColor.b * 255 + 10)}):Play()
                    hovering = true
                end)
                btn.MouseLeave:Connect(function()
                    game.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.ElementColor}):Play()
                    hovering = false
                end)

                coroutine.wrap(function()
                    while wait() do
                        if not hovering then
                            sliderElement.BackgroundColor3 = theme.ElementColor
                        end
                        moreInfo.TextColor3 = theme.TextColor
                        moreInfo.BackgroundColor3 = Color3.fromRGB(theme.SchemeColor.r * 255 - 14, theme.SchemeColor.g * 255 - 17, theme.SchemeColor.b * 255 - 13)
                        val.TextColor3 = theme.TextColor
                        write.ImageColor3 = theme.SchemeColor
                        togName.TextColor3 = theme.TextColor
                        viewInfo.ImageColor3 = theme.SchemeColor
                        sliderBtn.BackgroundColor3 = Color3.fromRGB(theme.ElementColor.r * 255 + 5, theme.ElementColor.g * 255 + 5, theme.ElementColor.b * 255 + 5)
                        sliderDrag.BackgroundColor3 = theme.SchemeColor
                    end
                end)()

                local Value
                sliderBtn.MouseButton1Down:Connect(function()
                    game.TweenService:Create(val, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
                    Value = math.floor((((maxvalue - minvalue) / 149) * sliderDrag.AbsoluteSize.X) + minvalue)
                    callback(Value)
                    sliderDrag:TweenSize(UDim2.new(0, math.clamp(mouse.X - sliderDrag.AbsolutePosition.X, 0, 149), 0, 6), "InOut", "Linear", 0.05, true)
                    local moveconnection = mouse.Move:Connect(function()
                        Value = math.floor((((maxvalue - minvalue) / 149) * sliderDrag.AbsoluteSize.X) + minvalue)
                        val.Text = tostring(Value)
                        callback(Value)
                        sliderDrag:TweenSize(UDim2.new(0, math.clamp(mouse.X - sliderDrag.AbsolutePosition.X, 0, 149), 0, 6), "InOut", "Linear", 0.05, true)
                    end)
                    local releaseconnection = uis.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            Value = math.floor((((maxvalue - minvalue) / 149) * sliderDrag.AbsoluteSize.X) + minvalue)
                            callback(Value)
                            val.Text = tostring(Value)
                            game.TweenService:Create(val, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
                            sliderDrag:TweenSize(UDim2.new(0, math.clamp(mouse.X - sliderDrag.AbsolutePosition.X, 0, 149), 0, 6), "InOut", "Linear", 0.05, true)
                            moveconnection:Disconnect()
                            releaseconnection:Disconnect()
                        end
                    end)
                end)

                viewInfo.MouseButton1Click:Connect(function()
                    for _, v in ipairs(infoContainer:GetChildren()) do
                        if v ~= moreInfo then
                            Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                        end
                    end
                    Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,0,0)}, 0.2)
                    Utility:TweenObject(blurFrame, {BackgroundTransparency = 0.5}, 0.2)
                    wait(1.5)
                    Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,2,0)}, 0.2)
                    Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
                end)
            end

            function Elements:NewLabel(title)
                local label = Instance.new("TextLabel")
                local UICorner = Instance.new("UICorner")
                label.Name = "label"
                label.Parent = sectionInners
                label.BackgroundColor3 = theme.SchemeColor
                label.BorderSizePixel = 0
                label.ClipsDescendants = true
                label.Text = "  "..title
                label.Size = UDim2.new(0, 352, 0, 33)
                label.Font = Enum.Font.Gotham
                label.RichText = true
                label.TextColor3 = theme.TextColor
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = label

                coroutine.wrap(function()
                    while wait() do
                        label.BackgroundColor3 = theme.SchemeColor
                        label.TextColor3 = theme.TextColor
                    end
                end)()
                updateSectionFrame()
                UpdateSize()
                return {UpdateLabel = function(newText) label.Text = "  "..newText end}
            end

            return Elements
        end
        return Sections
    end

    window.ScreenGui = ScreenGui
    window.Main = Main
    window.Theme = theme
    window:NewTab = Tabs.NewTab
    return window
end

-- ==================== FITUR-FITUR ====================
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

-- State
local running = true
local currentWS = 30
local currentBoost = 0

-- WalkSpeed loop
task.spawn(function()
    local hum = waitForHumanoid()
    player.CharacterAdded:Connect(function() hum = waitForHumanoid() end)
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
local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local hum = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hum.Jump = true
        end
    end
end)

-- Noclip
local noclipEnabled = false
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

-- God Mode
local godModeEnabled = false
task.spawn(function()
    local hum = waitForHumanoid()
    player.CharacterAdded:Connect(function() hum = waitForHumanoid() end)
    while running do
        if godModeEnabled and hum and hum.Parent then
            hum.MaxHealth = math.huge
            hum.Health = hum.MaxHealth
        end
        task.wait(0.1)
    end
end)

-- Instant Proximity
local instantProxEnabled = false
task.spawn(function()
    while running do
        if instantProxEnabled then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end
        end
        task.wait(2)
    end
end)

-- Infinite Zoom
local infiniteZoomEnabled = false
task.spawn(function()
    while running do
        if infiniteZoomEnabled then
            Camera.MaxAxisFieldOfView = 180
            Camera.FieldOfView = 120
        else
            Camera.MaxAxisFieldOfView = 120
        end
        task.wait(0.5)
    end
end)

-- Freecam
local freecamEnabled = false
local freecamPart = Instance.new("Part")
freecamPart.Anchored = true
freecamPart.CanCollide = false
freecamPart.Transparency = 1
freecamPart.Size = Vector3.new(1,1,1)
freecamPart.Parent = workspace

local freecamSpeed = 0.5
local freecamShiftMultiplier = 2

local freecamInfo = Instance.new("TextLabel")
freecamInfo.Size = UDim2.fromOffset(250, 30)
freecamInfo.Position = UDim2.new(0, 10, 0, 10)
freecamInfo.BackgroundColor3 = Color3.fromRGB(20,20,24)
freecamInfo.TextColor3 = Color3.new(1,1,1)
freecamInfo.Text = "Freecam ON (WASD/SPACE/CTRL + SHIFT to speed)"
freecamInfo.Font = Enum.Font.GothamBold
freecamInfo.TextSize = 14
freecamInfo.Visible = false
freecamInfo.Parent = CoreGui
Kavo:DraggingEnabled(freecamInfo, freecamInfo)

local function updateFreecam()
    if freecamEnabled then
        local speed = freecamSpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            speed = speed * freecamShiftMultiplier
        end
        local move = Vector3.new(
            (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
            (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
            (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
        ) * speed
        freecamPart.CFrame = freecamPart.CFrame + move
        Camera.CFrame = CFrame.new(freecamPart.Position, freecamPart.Position + Camera.CFrame.LookVector)
    end
end
RunService.RenderStepped:Connect(updateFreecam)

local function setFreecam(state)
    freecamEnabled = state
    freecamInfo.Visible = state
    if state then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            freecamPart.CFrame = char.HumanoidRootPart.CFrame
            -- Freeze character
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum.PlatformStand = true
            end
        end
    else
        -- Unfreeze
        local char = player.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum.PlatformStand = false
            end
            -- Kembalikan kamera ke karakter
            Camera.CameraSubject = hum or char
        end
    end
end

-- ==================== WINDOW UTAMA ====================
local mainWindow = Kavo:CreateWindow("Script BY Azka", "Ocean") -- Gunakan tema Ocean

-- Tab Main
local mainTab = mainWindow:NewTab("Main")
local mainSection = mainTab:NewSection("Main")

-- WalkSpeed Slider
mainSection:NewSlider("WalkSpeed", "Atur kecepatan jalan (1-200)", 200, 1, function(val)
    currentWS = val
end)

-- Boost Slider
mainSection:NewSlider("Boost", "Tambahan kecepatan sementara (0-500)", 500, 0, function(val)
    currentBoost = val
end)

-- Inf Jump Toggle
mainSection:NewToggle("Inf Jump", "Lompat tanpa batas", function(state)
    infJumpEnabled = state
end)

-- Noclip Toggle
mainSection:NewToggle("Noclip", "Tembus dinding", function(state)
    noclipEnabled = state
end)

-- God Mode Toggle
mainSection:NewToggle("God Mode", "Health tak terbatas", function(state)
    godModeEnabled = state
end)

-- Instant Proximity Toggle
mainSection:NewToggle("Instant Proximity", "Interaksi instan", function(state)
    instantProxEnabled = state
end)

-- Infinite Zoom Toggle
mainSection:NewToggle("Infinite Zoom", "Zoom tanpa batas", function(state)
    infiniteZoomEnabled = state
end)

-- Freecam Toggle
mainSection:NewToggle("Freecam", "Bebas kamera (WASD + Shift untuk cepat)", function(state)
    setFreecam(state)
end)

-- Tombol untuk membuka Teleport UI
local teleportWindow
mainSection:NewButton("Buka Teleport UI", "Membuka jendela teleport", function()
    if not teleportWindow then
        teleportWindow = createTeleportWindow()
    else
        teleportWindow.ScreenGui.Enabled = not teleportWindow.ScreenGui.Enabled
    end
end)

-- ==================== WINDOW TELEPORT ====================
function createTeleportWindow()
    local win = Kavo:CreateWindow("Teleport Menu", "Ocean")
    win.Main.Position = UDim2.new(0.5, -262, 0.3, -200) -- Atur posisi

    -- Tab Saved Teleports
    local savedTab = win:NewTab("Saved")
    local savedSection = savedTab:NewSection("Saved Teleports")

    -- Tombol Save Teleport
    savedSection:NewButton("Save Teleport", "Simpan posisi saat ini", function()
        -- Buka panel save (akan dibuat terpisah)
        showSavePanel(win)
    end)

    -- List saved teleports (akan diisi nanti)
    -- Kita perlu membuat scrolling list secara manual karena Kavo tidak punya list built-in.
    -- Alternatif: gunakan elemen button untuk setiap teleport.
    -- Untuk sederhana, kita akan buat fungsi refresh yang membersihkan section dan menambahkan button.
    local savedList = {}

    local function refreshSaved()
        -- Hapus semua elemen di section selain tombol save? Kita bisa simpan referensi.
        -- Karena kita tidak bisa dengan mudah, kita akan gunakan section baru setiap refresh.
        -- Tapi kita bisa menggunakan label dan button.
        -- Untuk demo, kita gunakan NewButton untuk setiap teleport.
        for _, child in ipairs(savedSection.sectionInners:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "Save Teleport" then
                child:Destroy()
            end
        end
        for i, data in ipairs(_G.AzkaTeleports or {}) do
            local btn = savedSection:NewButton(data.name, "Klik untuk teleport", function()
                if data.pos then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(data.pos)
                    end
                end
            end)
            -- Tambah tombol delete? Mungkin nanti.
        end
    end

    -- Inisialisasi global
    _G.AzkaTeleports = _G.AzkaTeleports or {}

    -- Tab Live Players
    local liveTab = win:NewTab("Live Players")
    local liveSection = liveTab:NewSection("Player List")

    -- Header
    liveSection:NewLabel("Player List")

    -- Fungsi refresh live players
    local function refreshLive()
        for _, child in ipairs(liveSection.sectionInners:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "Player List" then
                child:Destroy()
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                -- Buat frame untuk setiap player (menggunakan button sebagai container)
                -- Karena Kavo tidak punya frame dalam section, kita bisa buat button dengan teks dan dua tombol kecil.
                -- Alternatif: buat button utama untuk teleport, dan tambah toggle untuk TP Camera.
                -- Tapi kita perlu dua tombol. Mungkin kita buat satu button yang jika diklik teleport, dan tambah toggle terpisah.
                -- Untuk sederhana, kita buat satu button untuk teleport, dan satu toggle untuk TP Camera.
                local btn = liveSection:NewButton(plr.Name .. " - Teleport", "Teleport ke player", function()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        end
                    end
                end)
                -- Toggle TP Camera
                local tpCamToggle = liveSection:NewToggle("TP Camera "..plr.Name, "Kamera mengikuti player", function(state)
                    -- Implementasi TP Camera
                    if state then
                        -- Set kamera mengikuti player
                        Camera.CameraSubject = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")
                        -- Lock player movement
                        local char = player.Character
                        if char then
                            local hum = char:FindFirstChildWhichIsA("Humanoid")
                            if hum then
                                hum.PlatformStand = true
                            end
                        end
                    else
                        -- Kembalikan kamera ke player sendiri
                        Camera.CameraSubject = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
                        if player.Character then
                            local hum = player.Character:FindFirstChildWhichIsA("Humanoid")
                            if hum then
                                hum.PlatformStand = false
                            end
                        end
                    end
                end)
            end
        end
    end

    -- Refresh setiap beberapa detik
    task.spawn(function()
        while running do
            refreshLive()
            wait(2)
        end
    end)

    -- Panel Save (menggunakan window terpisah atau dialog)
    local savePanel
    function showSavePanel(parentWin)
        if savePanel and savePanel.ScreenGui then
            savePanel.ScreenGui.Enabled = true
            return
        end
        savePanel = Kavo:CreateWindow("Save Teleport", "Ocean")
        savePanel.Main.Size = UDim2.new(0, 300, 0, 200)
        savePanel.Main.Position = UDim2.new(0.5, -150, 0.4, -100)
        local tab = savePanel:NewTab("Save")
        local sec = tab:NewSection("Save Current Position")
        sec:NewLabel("Position: " .. tostring(player.Character and player.Character.HumanoidRootPart.Position or "N/A"))
        local nameBox = Instance.new("TextBox")
        nameBox.Size = UDim2.new(0, 280, 0, 30)
        nameBox.Position = UDim2.new(0, 10, 0, 50)
        nameBox.BackgroundColor3 = Color3.fromRGB(40,40,48)
        nameBox.TextColor3 = Color3.new(1,1,1)
        nameBox.PlaceholderText = "Nama teleport"
        nameBox.Parent = savePanel.Main
        sec:NewButton("Save", "Simpan teleport", function()
            local name = nameBox.Text
            if name == "" then name = "Teleport " .. (#_G.AzkaTeleports + 1) end
            local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
            if pos then
                table.insert(_G.AzkaTeleports, {name = name, pos = pos})
                refreshSaved()
                savePanel.ScreenGui:Destroy()
                savePanel = nil
            end
        end)
        sec:NewButton("Cancel", "Batal", function()
            savePanel.ScreenGui:Destroy()
            savePanel = nil
        end)
    end

    refreshSaved()
    return win
end

-- ==================== WINDOW SETTINGS (GEAR) ====================
local settingsWindow
function openSettings()
    if settingsWindow and settingsWindow.ScreenGui then
        settingsWindow.ScreenGui.Enabled = true
        return
    end
    settingsWindow = Kavo:CreateWindow("Settings", "Ocean")
    settingsWindow.Main.Size = UDim2.new(0, 300, 0, 200)
    settingsWindow.Main.Position = UDim2.new(0.5, -150, 0.4, -100)
    local tab = settingsWindow:NewTab("Settings")
    local sec = tab:NewSection("General")

    -- Anti-AFK
    local afkEnabled = false
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        if afkEnabled then
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
    sec:NewToggle("Anti-AFK", "Cegah AFK kick", function(state)
        afkEnabled = state
    end)

    -- Server Hop & Rejoin
    sec:NewButton("Server Hop & Rejoin", "Pindah server", function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, player, nil, game.JobId)
    end)

    -- Character Respawn
    sec:NewButton("Character Respawn", "Respawn karakter", function()
        local char = player.Character
        if char then
            char:BreakJoints()
        end
    end)
end

-- Hubungkan gear button di semua window (kita tambahkan secara manual)
-- Karena kita tidak punya gear di header, kita bisa tambahkan tombol di header masing-masing window.
-- Untuk sederhana, kita tambahkan tombol di main window saja.
local mainHeader = mainWindow.Main:FindFirstChild("MainHeader")
if mainHeader then
    local gear = Instance.new("TextButton")
    gear.Size = UDim2.fromOffset(36, 24)
    gear.Position = UDim2.new(0, 12, 0.5, -12)
    gear.Text = "⚙"
    gear.Font = Enum.Font.GothamBold
    gear.TextSize = 20
    gear.BackgroundColor3 = Color3.fromRGB(40,40,48)
    gear.TextColor3 = Color3.fromRGB(200,205,220)
    Instance.new("UICorner", gear).CornerRadius = UDim.new(0,8)
    gear.Parent = mainHeader
    gear.MouseButton1Click:Connect(openSettings)
end

-- Notifikasi
local notif = Instance.new("TextLabel")
notif.Size = UDim2.fromOffset(200,36)
notif.Position = UDim2.new(0.5,-100,0,20)
notif.BackgroundColor3 = Color3.fromRGB(28,28,34)
notif.BackgroundTransparency = 0.2
notif.Text = "Script BY Azka - Loaded"
notif.TextColor3 = Color3.fromRGB(220,230,255)
notif.Font = Enum.Font.Gotham
notif.TextSize = 14
notif.Parent = CoreGui
Instance.new("UICorner", notif).CornerRadius = UDim.new(0,8)
task.wait(2)
TweenService:Create(notif, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
task.wait(0.5)
notif:Destroy()
