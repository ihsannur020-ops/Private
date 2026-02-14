-- Hapus folder lama jika ada
local CoreGui = game:GetService("CoreGui")
local folderName = "Main_Script_By_Azka"
local oldFolder = CoreGui:FindFirstChild(folderName)
if oldFolder then oldFolder:Destroy() end

-- Buat folder baru
local folder = Instance.new("Folder")
folder.Name = folderName
folder.Parent = CoreGui

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer

-- Utility functions
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

-- Theme
local theme = {
	SchemeColor = Color3.fromRGB(74, 99, 135),
	Background = Color3.fromRGB(36, 37, 43),
	Header = Color3.fromRGB(28, 29, 34),
	TextColor = Color3.fromRGB(255, 255, 255),
	ElementColor = Color3.fromRGB(32, 32, 38)
}

-- Library
local Library = {}
Library.Flags = {}

function Library:CreateWindow(title)
	local window = {}
	local gui = Instance.new("ScreenGui")
	gui.Name = "AzkaUI"
	gui.Parent = folder
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Parent = gui
	main.BackgroundColor3 = theme.Background
	main.BorderSizePixel = 0
	main.Position = UDim2.new(0.5, -250, 0.5, -200)
	main.Size = UDim2.new(0, 500, 0, 400)
	main.ClipsDescendants = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
	makeDraggable(main, main)

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Parent = main
	header.BackgroundColor3 = theme.Header
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BorderSizePixel = 0
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Parent = header
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -100, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.Text = title or "Script BY Azka"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = theme.TextColor
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local gear = Instance.new("TextButton")
	gear.Parent = header
	gear.BackgroundTransparency = 1
	gear.Size = UDim2.new(0, 30, 0, 30)
	gear.Position = UDim2.new(1, -90, 0, 0)
	gear.Text = "⚙"
	gear.Font = Enum.Font.GothamBold
	gear.TextSize = 20
	gear.TextColor3 = theme.TextColor
	gear.MouseButton1Click:Connect(function()
		if window.Settings then
			window.Settings.Visible = not window.Settings.Visible
		end
	end)

	local minBtn = Instance.new("TextButton")
	minBtn.Parent = header
	minBtn.BackgroundTransparency = 1
	minBtn.Size = UDim2.new(0, 30, 0, 30)
	minBtn.Position = UDim2.new(1, -60, 0, 0)
	minBtn.Text = "—"
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 20
	minBtn.TextColor3 = theme.TextColor
	minBtn.MouseButton1Click:Connect(function()
		main.Visible = false
		if window.Minimized then
			window.Minimized.Visible = true
		end
	end)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Parent = header
	closeBtn.BackgroundTransparency = 1
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -30, 0, 0)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	local minimized = Instance.new("TextButton")
	minimized.Name = "Minimized"
	minimized.Parent = gui
	minimized.BackgroundColor3 = theme.Header
	minimized.Size = UDim2.fromOffset(40, 40)
	minimized.Position = UDim2.new(0.5, -20, 0.5, -20)
	minimized.Text = "👟"
	minimized.Font = Enum.Font.GothamBold
	minimized.TextSize = 20
	minimized.TextColor3 = theme.TextColor
	minimized.Visible = false
	Instance.new("UICorner", minimized).CornerRadius = UDim.new(1, 0)
	makeDraggable(minimized, minimized)
	minimized.MouseButton1Click:Connect(function()
		minimized.Visible = false
		main.Visible = true
	end)
	window.Minimized = minimized

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Parent = main
	sidebar.BackgroundColor3 = theme.Header
	sidebar.Size = UDim2.new(0, 150, 1, -30)
	sidebar.Position = UDim2.new(0, 0, 0, 30)
	sidebar.BorderSizePixel = 0
	Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

	local tabContainer = Instance.new("Frame")
	tabContainer.Parent = sidebar
	tabContainer.BackgroundTransparency = 1
	tabContainer.Size = UDim2.new(1, -10, 1, -10)
	tabContainer.Position = UDim2.new(0, 5, 0, 5)

	local tabList = Instance.new("UIListLayout", tabContainer)
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Padding = UDim.new(0, 5)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Parent = main
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -160, 1, -40)
	content.Position = UDim2.new(0, 155, 0, 35)
	content.ClipsDescendants = true

	local pageContainer = Instance.new("Frame")
	pageContainer.Parent = content
	pageContainer.BackgroundTransparency = 1
	pageContainer.Size = UDim2.new(1, 0, 1, 0)

	local pages = {}

	function window:NewTab(name)
		local tab = {}
		local tabBtn = Instance.new("TextButton")
		tabBtn.Parent = tabContainer
		tabBtn.BackgroundColor3 = theme.SchemeColor
		tabBtn.BackgroundTransparency = 1
		tabBtn.Size = UDim2.new(1, 0, 0, 30)
		tabBtn.Text = name
		tabBtn.Font = Enum.Font.GothamMedium
		tabBtn.TextSize = 14
		tabBtn.TextColor3 = theme.TextColor
		tabBtn.AutoButtonColor = false
		Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

		local page = Instance.new("ScrollingFrame")
		page.Name = name
		page.Parent = pageContainer
		page.BackgroundColor3 = theme.Background
		page.BackgroundTransparency = 1
		page.Size = UDim2.new(1, 0, 1, 0)
		page.ScrollBarThickness = 6
		page.ScrollBarImageColor3 = theme.SchemeColor
		page.BorderSizePixel = 0
		page.Visible = false
		page.CanvasSize = UDim2.new(0, 0, 0, 0)

		local pageLayout = Instance.new("UIListLayout", page)
		pageLayout.Padding = UDim.new(0, 10)
		pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local function updateCanvas()
			local size = pageLayout.AbsoluteContentSize
			page.CanvasSize = UDim2.new(0, size.X, 0, size.Y + 10)
		end
		page.ChildAdded:Connect(updateCanvas)
		page.ChildRemoved:Connect(updateCanvas)
		pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

		tabBtn.MouseButton1Click:Connect(function()
			for _, btn in ipairs(tabContainer:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.BackgroundTransparency = 1
				end
			end
			for _, p in ipairs(pageContainer:GetChildren()) do
				if p:IsA("ScrollingFrame") then
					p.Visible = false
				end
			end
			tabBtn.BackgroundTransparency = 0
			page.Visible = true
		end

		if #tabContainer:GetChildren() == 1 then
			tabBtn.BackgroundTransparency = 0
			page.Visible = true
		end

		function tab:NewSection(sectionName)
			local section = {}

			local sectionFrame = Instance.new("Frame")
			sectionFrame.Parent = page
			sectionFrame.BackgroundColor3 = theme.Background
			sectionFrame.BorderSizePixel = 0
			sectionFrame.Size = UDim2.new(1, -10, 0, 0)
			sectionFrame.AutomaticSize = Enum.AutomaticSize.Y

			local header = Instance.new("Frame")
			header.Parent = sectionFrame
			header.BackgroundColor3 = theme.SchemeColor
			header.Size = UDim2.new(1, 0, 0, 30)
			header.BorderSizePixel = 0
			Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

			local title = Instance.new("TextLabel")
			title.Parent = header
			title.BackgroundTransparency = 1
			title.Size = UDim2.new(1, -10, 1, 0)
			title.Position = UDim2.new(0, 5, 0, 0)
			title.Text = sectionName
			title.Font = Enum.Font.GothamBold
			title.TextSize = 14
			title.TextColor3 = theme.TextColor
			title.TextXAlignment = Enum.TextXAlignment.Left

			local contentFrame = Instance.new("Frame")
			contentFrame.Parent = sectionFrame
			contentFrame.BackgroundTransparency = 1
			contentFrame.Size = UDim2.new(1, 0, 0, 0)
			contentFrame.Position = UDim2.new(0, 0, 0, 35)
			contentFrame.AutomaticSize = Enum.AutomaticSize.Y

			local contentLayout = Instance.new("UIListLayout", contentFrame)
			contentLayout.Padding = UDim.new(0, 5)
			contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

			function section:NewButton(text, tip, callback)
				local btn = Instance.new("TextButton")
				btn.Parent = contentFrame
				btn.BackgroundColor3 = theme.ElementColor
				btn.Size = UDim2.new(1, -10, 0, 35)
				btn.Text = ""
				btn.AutoButtonColor = false
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

				local label = Instance.new("TextLabel")
				label.Parent = btn
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, -10, 1, 0)
				label.Position = UDim2.new(0, 5, 0, 0)
				label.Text = text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 14
				label.TextColor3 = theme.TextColor
				label.TextXAlignment = Enum.TextXAlignment.Left

				btn.MouseButton1Click:Connect(callback)
			end

			function section:NewToggle(text, tip, default, callback)
				local toggled = default or false
				local toggleBtn = Instance.new("TextButton")
				toggleBtn.Parent = contentFrame
				toggleBtn.BackgroundColor3 = theme.ElementColor
				toggleBtn.Size = UDim2.new(1, -10, 0, 35)
				toggleBtn.Text = ""
				toggleBtn.AutoButtonColor = false
				Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

				local label = Instance.new("TextLabel")
				label.Parent = toggleBtn
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, -60, 1, 0)
				label.Position = UDim2.new(0, 5, 0, 0)
				label.Text = text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 14
				label.TextColor3 = theme.TextColor
				label.TextXAlignment = Enum.TextXAlignment.Left

				local switchBg = Instance.new("Frame")
				switchBg.Parent = toggleBtn
				switchBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
				switchBg.Size = UDim2.new(0, 40, 0, 20)
				switchBg.Position = UDim2.new(1, -45, 0.5, -10)
				Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

				local knob = Instance.new("Frame")
				knob.Parent = switchBg
				knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				knob.Size = UDim2.new(0, 18, 0, 18)
				knob.Position = UDim2.new(0, 1, 0.5, -9)
				Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

				local function updateSwitch()
					if toggled then
						switchBg.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
						knob.Position = UDim2.new(1, -19, 0.5, -9)
					else
						switchBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
						knob.Position = UDim2.new(0, 1, 0.5, -9)
					end
				end
				updateSwitch()

				toggleBtn.MouseButton1Click:Connect(function()
					toggled = not toggled
					updateSwitch()
					if callback then callback(toggled) end
				end)

				return function() return toggled end
			end

			function section:NewSlider(text, tip, min, max, default, callback)
				local value = default or min
				local sliderFrame = Instance.new("Frame")
				sliderFrame.Parent = contentFrame
				sliderFrame.BackgroundColor3 = theme.ElementColor
				sliderFrame.Size = UDim2.new(1, -10, 0, 45)
				Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 6)

				local label = Instance.new("TextLabel")
				label.Parent = sliderFrame
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, -10, 0, 20)
				label.Position = UDim2.new(0, 5, 0, 2)
				label.Text = text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 14
				label.TextColor3 = theme.TextColor
				label.TextXAlignment = Enum.TextXAlignment.Left

				local valueLabel = Instance.new("TextLabel")
				valueLabel.Parent = sliderFrame
				valueLabel.BackgroundTransparency = 1
				valueLabel.Size = UDim2.new(0, 50, 0, 20)
				valueLabel.Position = UDim2.new(1, -55, 0, 2)
				valueLabel.Text = tostring(value)
				valueLabel.Font = Enum.Font.GothamBold
				valueLabel.TextSize = 14
				valueLabel.TextColor3 = theme.SchemeColor
				valueLabel.TextXAlignment = Enum.TextXAlignment.Right

				local bar = Instance.new("Frame")
				bar.Parent = sliderFrame
				bar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
				bar.Size = UDim2.new(1, -20, 0, 10)
				bar.Position = UDim2.new(0, 10, 0, 25)
				Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

				local fill = Instance.new("Frame")
				fill.Parent = bar
				fill.BackgroundColor3 = theme.SchemeColor
				fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
				Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

				local knob = Instance.new("Frame")
				knob.Parent = bar
				knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				knob.Size = UDim2.new(0, 14, 0, 14)
				knob.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
				Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

				local dragging = false
				local function updateFromMouse(x)
					local barPos = bar.AbsolutePosition.X
					local barSize = bar.AbsoluteSize.X
					local relX = math.clamp(x - barPos, 0, barSize)
					local alpha = relX / barSize
					value = math.floor(min + alpha * (max - min) + 0.5)
					valueLabel.Text = tostring(value)
					fill.Size = UDim2.new(alpha, 0, 1, 0)
					knob.Position = UDim2.new(alpha, -7, 0.5, -7)
					if callback then callback(value) end
				end

				knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
					end
				end)
				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						updateFromMouse(input.Position.X)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
						updateFromMouse(input.Position.X)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
			end

			function section:NewLabel(text)
				local label = Instance.new("TextLabel")
				label.Parent = contentFrame
				label.BackgroundColor3 = theme.ElementColor
				label.Size = UDim2.new(1, -10, 0, 30)
				label.Text = "  " .. text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 14
				label.TextColor3 = theme.TextColor
				label.TextXAlignment = Enum.TextXAlignment.Left
				Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
			end

			return section
		end

		table.insert(pages, page)
		return tab
	end

	-- Settings panel
	local settingsFrame = Instance.new("Frame")
	settingsFrame.Name = "Settings"
	settingsFrame.Parent = gui
	settingsFrame.BackgroundColor3 = theme.Background
	settingsFrame.Size = UDim2.fromOffset(300, 200)
	settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
	settingsFrame.Visible = false
	Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 6)
	makeDraggable(settingsFrame, settingsFrame)

	local settingsHeader = Instance.new("Frame")
	settingsHeader.Parent = settingsFrame
	settingsHeader.BackgroundColor3 = theme.Header
	settingsHeader.Size = UDim2.new(1, 0, 0, 30)
	Instance.new("UICorner", settingsHeader).CornerRadius = UDim.new(0, 6)

	local settingsTitle = Instance.new("TextLabel")
	settingsTitle.Parent = settingsHeader
	settingsTitle.BackgroundTransparency = 1
	settingsTitle.Size = UDim2.new(1, -40, 1, 0)
	settingsTitle.Position = UDim2.new(0, 10, 0, 0)
	settingsTitle.Text = "Settings"
	settingsTitle.Font = Enum.Font.GothamBold
	settingsTitle.TextSize = 16
	settingsTitle.TextColor3 = theme.TextColor
	settingsTitle.TextXAlignment = Enum.TextXAlignment.Left

	local settingsClose = Instance.new("TextButton")
	settingsClose.Parent = settingsHeader
	settingsClose.BackgroundTransparency = 1
	settingsClose.Size = UDim2.new(0, 30, 0, 30)
	settingsClose.Position = UDim2.new(1, -30, 0, 0)
	settingsClose.Text = "X"
	settingsClose.Font = Enum.Font.GothamBold
	settingsClose.TextSize = 16
	settingsClose.TextColor3 = Color3.fromRGB(255, 150, 150)
	settingsClose.MouseButton1Click:Connect(function()
		settingsFrame.Visible = false
	end)

	local settingsContent = Instance.new("Frame")
	settingsContent.Parent = settingsFrame
	settingsContent.BackgroundTransparency = 1
	settingsContent.Size = UDim2.new(1, -20, 1, -40)
	settingsContent.Position = UDim2.new(0, 10, 0, 35)

	local settingsLayout = Instance.new("UIListLayout", settingsContent)
	settingsLayout.Padding = UDim.new(0, 5)
	settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- Anti-AFK
	local afkToggled = false
	local afkBtn = Instance.new("TextButton")
	afkBtn.Parent = settingsContent
	afkBtn.BackgroundColor3 = theme.ElementColor
	afkBtn.Size = UDim2.new(1, 0, 0, 35)
	afkBtn.Text = ""
	afkBtn.AutoButtonColor = false
	Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0, 6)

	local afkLabel = Instance.new("TextLabel")
	afkLabel.Parent = afkBtn
	afkLabel.BackgroundTransparency = 1
	afkLabel.Size = UDim2.new(1, -50, 1, 0)
	afkLabel.Position = UDim2.new(0, 5, 0, 0)
	afkLabel.Text = "Anti-AFK"
	afkLabel.Font = Enum.Font.GothamMedium
	afkLabel.TextSize = 14
	afkLabel.TextColor3 = theme.TextColor
	afkLabel.TextXAlignment = Enum.TextXAlignment.Left

	local afkSwitchBg = Instance.new("Frame")
	afkSwitchBg.Parent = afkBtn
	afkSwitchBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	afkSwitchBg.Size = UDim2.new(0, 40, 0, 20)
	afkSwitchBg.Position = UDim2.new(1, -45, 0.5, -10)
	Instance.new("UICorner", afkSwitchBg).CornerRadius = UDim.new(1, 0)

	local afkKnob = Instance.new("Frame")
	afkKnob.Parent = afkSwitchBg
	afkKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	afkKnob.Size = UDim2.new(0, 18, 0, 18)
	afkKnob.Position = UDim2.new(0, 1, 0.5, -9)
	Instance.new("UICorner", afkKnob).CornerRadius = UDim.new(1, 0)

	local function updateAfkSwitch()
		if afkToggled then
			afkSwitchBg.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
			afkKnob.Position = UDim2.new(1, -19, 0.5, -9)
		else
			afkSwitchBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
			afkKnob.Position = UDim2.new(0, 1, 0.5, -9)
		end
	end
	updateAfkSwitch()

	afkBtn.MouseButton1Click:Connect(function()
		afkToggled = not afkToggled
		updateAfkSwitch()
	end)

	local hopBtn = Instance.new("TextButton")
	hopBtn.Parent = settingsContent
	hopBtn.BackgroundColor3 = theme.ElementColor
	hopBtn.Size = UDim2.new(1, 0, 0, 35)
	hopBtn.Text = "Server Hop & Rejoin"
	hopBtn.Font = Enum.Font.GothamMedium
	hopBtn.TextSize = 14
	hopBtn.TextColor3 = theme.TextColor
	Instance.new("UICorner", hopBtn).CornerRadius = UDim.new(0, 6)
	hopBtn.MouseButton1Click:Connect(function()
		local ts = game:GetService("TeleportService")
		ts:Teleport(game.PlaceId, player, nil, game.JobId)
	end)

	local respawnBtn = Instance.new("TextButton")
	respawnBtn.Parent = settingsContent
	respawnBtn.BackgroundColor3 = theme.ElementColor
	respawnBtn.Size = UDim2.new(1, 0, 0, 35)
	respawnBtn.Text = "Character Respawn"
	respawnBtn.Font = Enum.Font.GothamMedium
	respawnBtn.TextSize = 14
	respawnBtn.TextColor3 = theme.TextColor
	Instance.new("UICorner", respawnBtn).CornerRadius = UDim.new(0, 6)
	respawnBtn.MouseButton1Click:Connect(function()
		local char = player.Character
		if char then char:BreakJoints() end
	end)

	-- Anti-AFK loop
	task.spawn(function()
		local vu = game:GetService("VirtualUser")
		player.Idled:Connect(function()
			if afkToggled then
				vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
				task.wait(1)
				vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
			end
		end)
	end)

	window.Settings = settingsFrame
	return window
end

-- FLY UI
local function createFlyUI()
	local flyGui = Instance.new("ScreenGui")
	flyGui.Name = "FlyUI"
	flyGui.Parent = folder
	flyGui.ResetOnSpawn = false

	local flyFrame = Instance.new("Frame")
	flyFrame.Name = "FlyFrame"
	flyFrame.Parent = flyGui
	flyFrame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
	flyFrame.BorderColor3 = Color3.fromRGB(103, 221, 213)
	flyFrame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
	flyFrame.Size = UDim2.new(0, 190, 0, 57)
	flyFrame.Active = true
	flyFrame.Draggable = true
	flyFrame.Visible = false

	local up = Instance.new("TextButton")
	up.Name = "up"
	up.Parent = flyFrame
	up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
	up.Size = UDim2.new(0, 44, 0, 28)
	up.Font = Enum.Font.SourceSans
	up.Text = "UP"
	up.TextColor3 = Color3.fromRGB(0, 0, 0)
	up.TextSize = 14

	local down = Instance.new("TextButton")
	down.Name = "down"
	down.Parent = flyFrame
	down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
	down.Position = UDim2.new(0, 0, 0.491228074, 0)
	down.Size = UDim2.new(0, 44, 0, 28)
	down.Font = Enum.Font.SourceSans
	down.Text = "DOWN"
	down.TextColor3 = Color3.fromRGB(0, 0, 0)
	down.TextSize = 14

	local onof = Instance.new("TextButton")
	onof.Name = "onof"
	onof.Parent = flyFrame
	onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
	onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
	onof.Size = UDim2.new(0, 56, 0, 28)
	onof.Font = Enum.Font.SourceSans
	onof.Text = "fly"
	onof.TextColor3 = Color3.fromRGB(0, 0, 0)
	onof.TextSize = 14

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Parent = flyFrame
	titleLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
	titleLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
	titleLabel.Size = UDim2.new(0, 100, 0, 28)
	titleLabel.Font = Enum.Font.SourceSans
	titleLabel.Text = "AzkaFLY"
	titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.TextScaled = true

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

	local speeds = 1
	local nowe = false

	onof.MouseButton1Click:Connect(function()
		nowe = not nowe
	end)

	local tis, dis
	up.MouseButton1Down:Connect(function()
		tis = up.MouseEnter:Connect(function()
			while tis do
				task.wait()
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, speeds, 0)
				end
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
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -speeds, 0)
				end
			end
		end)
	end)
	down.MouseLeave:Connect(function()
		if dis then dis:Disconnect() dis = nil end
	end)

	plus.MouseButton1Click:Connect(function()
		speeds = speeds + 1
		speedLabel.Text = tostring(speeds)
	end)

	mine.MouseButton1Click:Connect(function()
		if speeds > 1 then
			speeds = speeds - 1
			speedLabel.Text = tostring(speeds)
		else
			speedLabel.Text = "min 1"
			task.wait(0.5)
			speedLabel.Text = "1"
		end
	end)

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

	closeFly.MouseButton1Click:Connect(function()
		flyFrame.Visible = false
	end)

	return flyFrame
end

-- TELEPORT UI
_G.AzkaTeleports = _G.AzkaTeleports or {}

local function createTeleportUI()
	local tpGui = Instance.new("ScreenGui")
	tpGui.Name = "TeleportUI"
	tpGui.Parent = folder
	tpGui.ResetOnSpawn = false

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Parent = tpGui
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	main.Size = UDim2.fromOffset(400, 500)
	main.Position = UDim2.new(0.5, -200, 0.3, -250)
	main.Visible = false
	makeDraggable(main, main)
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
	Instance.new("UIStroke", main).Color = Color3.fromRGB(80, 120, 255)

	local tbar = Instance.new("Frame")
	tbar.Size = UDim2.new(1, 0, 0, 36)
	tbar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	tbar.Parent = main
	Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 12)

	local ttitle = Instance.new("TextLabel")
	ttitle.BackgroundTransparency = 1
	ttitle.Size = UDim2.new(1, -90, 1, 0)
	ttitle.Position = UDim2.new(0, 12, 0, 0)
	ttitle.Text = "Teleport Menu"
	ttitle.Font = Enum.Font.GothamBold
	ttitle.TextSize = 18
	ttitle.TextColor3 = Color3.fromRGB(230, 235, 255)
	ttitle.TextXAlignment = Enum.TextXAlignment.Left
	ttitle.Parent = tbar

	local tpClose = Instance.new("TextButton")
	tpClose.Size = UDim2.fromOffset(36, 24)
	tpClose.Position = UDim2.new(1, -44, 0.5, -12)
	tpClose.Text = "X"
	tpClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
	tpClose.TextColor3 = Color3.fromRGB(255, 220, 220)
	Instance.new("UICorner", tpClose).CornerRadius = UDim.new(0, 8)
	tpClose.Parent = tbar

	local tabFrame = Instance.new("Frame")
	tabFrame.Size = UDim2.new(1, -20, 0, 40)
	tabFrame.Position = UDim2.new(0, 10, 0, 44)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Parent = main

	local tabLayout = Instance.new("UIListLayout", tabFrame)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 10)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local savedTab = Instance.new("TextButton")
	savedTab.Size = UDim2.new(0, 150, 0, 30)
	savedTab.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
	savedTab.Text = "Saved Teleports"
	savedTab.TextColor3 = Color3.new(1,1,1)
	savedTab.Font = Enum.Font.GothamBold
	savedTab.TextSize = 14
	Instance.new("UICorner", savedTab).CornerRadius = UDim.new(0, 8)
	savedTab.Parent = tabFrame

	local playersTab = Instance.new("TextButton")
	playersTab.Size = UDim2.new(0, 150, 0, 30)
	playersTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	playersTab.Text = "Live Players"
	playersTab.TextColor3 = Color3.new(1,1,1)
	playersTab.Font = Enum.Font.GothamBold
	playersTab.TextSize = 14
	Instance.new("UICorner", playersTab).CornerRadius = UDim.new(0, 8)
	playersTab.Parent = tabFrame

	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, -20, 0, 380)
	contentFrame.Position = UDim2.new(0, 10, 0, 90)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = main

	local savedContainer = Instance.new("ScrollingFrame")
	savedContainer.Size = UDim2.new(1, 0, 1, 0)
	savedContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	savedContainer.ScrollBarThickness = 6
	savedContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	savedContainer.Visible = true
	savedContainer.Parent = contentFrame
	Instance.new("UICorner", savedContainer).CornerRadius = UDim.new(0, 8)

	local savedLayout = Instance.new("UIListLayout", savedContainer)
	savedLayout.Padding = UDim.new(0, 8)
	savedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local saveBtn = Instance.new("TextButton")
	saveBtn.Size = UDim2.new(1, -10, 0, 40)
	saveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	saveBtn.Text = "Save Teleport"
	saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveBtn.Font = Enum.Font.GothamBold
	saveBtn.TextSize = 16
	Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
	saveBtn.Parent = savedContainer

	local listSaved = Instance.new("ScrollingFrame")
	listSaved.Size = UDim2.new(1, -10, 0, 250)
	listSaved.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	listSaved.ScrollBarThickness = 6
	listSaved.CanvasSize = UDim2.new(0, 0, 0, 0)
	listSaved.Parent = savedContainer
	Instance.new("UICorner", listSaved).CornerRadius = UDim.new(0, 8)

	local listSavedLayout = Instance.new("UIListLayout", listSaved)
	listSavedLayout.Padding = UDim.new(0, 5)
	listSavedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local savedPageFrame = Instance.new("Frame")
	savedPageFrame.Size = UDim2.new(1, -10, 0, 30)
	savedPageFrame.BackgroundTransparency = 1
	savedPageFrame.Parent = savedContainer

	local savedPageLayout = Instance.new("UIListLayout", savedPageFrame)
	savedPageLayout.FillDirection = Enum.FillDirection.Horizontal
	savedPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	savedPageLayout.Padding = UDim.new(0, 5)

	local playersContainer = Instance.new("ScrollingFrame")
	playersContainer.Size = UDim2.new(1, 0, 1, 0)
	playersContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	playersContainer.ScrollBarThickness = 6
	playersContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	playersContainer.Visible = false
	playersContainer.Parent = contentFrame
	Instance.new("UICorner", playersContainer).CornerRadius = UDim.new(0, 8)

	local playersLayout = Instance.new("UIListLayout", playersContainer)
	playersLayout.Padding = UDim.new(0, 5)
	playersLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local savedItemsPerPage = 5
	local savedCurrentPage = 1
	local savedTotalPages = 1

	local function refreshSavedList()
		for _, child in ipairs(listSaved:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
		for _, child in ipairs(savedPageFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end

		local teleports = _G.AzkaTeleports
		savedTotalPages = math.max(1, math.ceil(#teleports / savedItemsPerPage))
		savedCurrentPage = math.clamp(savedCurrentPage, 1, savedTotalPages)
		local start = (savedCurrentPage-1)*savedItemsPerPage + 1
		local finish = math.min(start + savedItemsPerPage - 1, #teleports)

		for i = start, finish do
			local data = teleports[i]
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, -10, 0, 40)
			item.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
			item.Parent = listSaved

			local name = Instance.new("TextLabel")
			name.Size = UDim2.new(0.5, -5, 1, 0)
			name.Position = UDim2.new(0, 5, 0, 0)
			name.BackgroundTransparency = 1
			name.Text = data.name
			name.TextColor3 = Color3.new(1,1,1)
			name.Font = Enum.Font.GothamBold
			name.TextSize = 14
			name.TextXAlignment = Enum.TextXAlignment.Left
			name.Parent = item

			local tp = Instance.new("TextButton")
			tp.Size = UDim2.new(0, 80, 0, 30)
			tp.Position = UDim2.new(0.5, 5, 0.5, -15)
			tp.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
			tp.Text = "Teleport"
			tp.TextColor3 = Color3.new(1,1,1)
			tp.Font = Enum.Font.GothamMedium
			tp.TextSize = 12
			Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 6)
			tp.Parent = item
			tp.MouseButton1Click:Connect(function()
				if data.pos then
					local char = player.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						char.HumanoidRootPart.CFrame = CFrame.new(data.pos)
					end
				end
			end)

			local del = Instance.new("TextButton")
			del.Size = UDim2.new(0, 60, 0, 30)
			del.Position = UDim2.new(1, -65, 0.5, -15)
			del.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
			del.Text = "Delete"
			del.TextColor3 = Color3.new(1,1,1)
			del.Font = Enum.Font.GothamMedium
			del.TextSize = 12
			Instance.new("UICorner", del).CornerRadius = UDim.new(0, 6)
			del.Parent = item
			del.MouseButton1Click:Connect(function()
				table.remove(_G.AzkaTeleports, i)
				refreshSavedList()
			end)
		end

		for p = 1, savedTotalPages do
			local pageBtn = Instance.new("TextButton")
			pageBtn.Size = UDim2.fromOffset(30, 30)
			pageBtn.BackgroundColor3 = (p == savedCurrentPage) and Color3.fromRGB(80,120,255) or Color3.fromRGB(50,50,60)
			pageBtn.Text = tostring(p)
			pageBtn.TextColor3 = Color3.new(1,1,1)
			pageBtn.Font = Enum.Font.GothamBold
			pageBtn.TextSize = 14
			Instance.new("UICorner", pageBtn).CornerRadius = UDim.new(0, 6)
			pageBtn.Parent = savedPageFrame
			pageBtn.MouseButton1Click:Connect(function()
				savedCurrentPage = p
				refreshSavedList()
			end)
		end

		local h = 0
		for _, ch in ipairs(listSaved:GetChildren()) do
			if ch:IsA("Frame") then
				h = h + ch.Size.Y.Offset + listSavedLayout.Padding.Offset
			end
		end
		listSaved.CanvasSize = UDim2.new(0,0,0,h)
	end

	local function refreshPlayersList()
		for _, child in ipairs(playersContainer:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local item = Instance.new("Frame")
				item.Size = UDim2.new(1, -10, 0, 60)
				item.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
				Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
				item.Parent = playersContainer

				local name = Instance.new("TextLabel")
				name.Size = UDim2.new(1, -10, 0, 20)
				name.Position = UDim2.new(0, 5, 0, 2)
				name.BackgroundTransparency = 1
				name.Text = plr.Name .. (plr.DisplayName ~= plr.Name and " ("..plr.DisplayName..")" or "")
				name.TextColor3 = Color3.new(1,1,1)
				name.Font = Enum.Font.GothamBold
				name.TextSize = 14
				name.TextXAlignment = Enum.TextXAlignment.Left
				name.Parent = item

				local tpCamBtn = Instance.new("TextButton")
				tpCamBtn.Size = UDim2.new(0, 100, 0, 25)
				tpCamBtn.Position = UDim2.new(0, 5, 0, 25)
				tpCamBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
				tpCamBtn.Text = "TP Camera: OFF"
				tpCamBtn.TextColor3 = Color3.new(1,1,1)
				tpCamBtn.Font = Enum.Font.GothamMedium
				tpCamBtn.TextSize = 12
				Instance.new("UICorner", tpCamBtn).CornerRadius = UDim.new(0, 6)
				tpCamBtn.Parent = item

				local tpCamActive = false
				tpCamBtn.MouseButton1Click:Connect(function()
					tpCamActive = not tpCamActive
					tpCamBtn.Text = tpCamActive and "TP Camera: ON" or "TP Camera: OFF"
					tpCamBtn.BackgroundColor3 = tpCamActive and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,90)
				end)

				local tpBtn = Instance.new("TextButton")
				tpBtn.Size = UDim2.new(0, 80, 0, 30)
				tpBtn.Position = UDim2.new(1, -85, 0.5, -15)
				tpBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
				tpBtn.Text = "Teleport"
				tpBtn.TextColor3 = Color3.new(1,1,1)
				tpBtn.Font = Enum.Font.GothamMedium
				tpBtn.TextSize = 12
				Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
				tpBtn.Parent = item
				tpBtn.MouseButton1Click:Connect(function()
					if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
						local char = player.Character
						if char and char:FindFirstChild("HumanoidRootPart") then
							char.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
						end
					end
				end)
			end
		end

		local h = 0
		for _, ch in ipairs(playersContainer:GetChildren()) do
			if ch:IsA("Frame") then
				h = h + ch.Size.Y.Offset + playersLayout.Padding.Offset
			end
		end
		playersContainer.CanvasSize = UDim2.new(0,0,0,h)
	end

	savedTab.MouseButton1Click:Connect(function()
		savedTab.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
		playersTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		savedContainer.Visible = true
		playersContainer.Visible = false
		refreshSavedList()
	end)

	playersTab.MouseButton1Click:Connect(function()
		playersTab.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
		savedTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		savedContainer.Visible = false
		playersContainer.Visible = true
		refreshPlayersList()
	end)

	local saveSub = Instance.new("Frame")
	saveSub.Size = UDim2.fromOffset(300,220)
	saveSub.Position = UDim2.new(0.5,-150,0.5,-110)
	saveSub.BackgroundColor3 = Color3.fromRGB(20,20,24)
	saveSub.Visible = false
	saveSub.Parent = tpGui
	makeDraggable(saveSub, saveSub)
	Instance.new("UICorner", saveSub).CornerRadius = UDim.new(0,12)
	Instance.new("UIStroke", saveSub).Color = Color3.fromRGB(80,120,255)

	local subTitle = Instance.new("TextLabel")
	subTitle.Size = UDim2.new(1,0,0,40)
	subTitle.BackgroundColor3 = Color3.fromRGB(28,28,34)
	subTitle.Text = "Save Teleport"
	subTitle.Font = Enum.Font.GothamBold
	subTitle.TextSize = 18
	subTitle.TextColor3 = Color3.fromRGB(230,235,255)
	Instance.new("UICorner", subTitle).CornerRadius = UDim.new(0,12)
	subTitle.Parent = saveSub

	local coord = Instance.new("TextLabel")
	coord.Size = UDim2.new(1,-20,0,30)
	coord.Position = UDim2.new(0,10,0,50)
	coord.BackgroundTransparency = 1
	coord.Text = "Position: 0, 0, 0"
	coord.TextColor3 = Color3.fromRGB(255,255,255)
	coord.Font = Enum.Font.GothamBold
	coord.TextSize = 16
	coord.Parent = saveSub

	local nameBox = Instance.new("TextBox")
	nameBox.Size = UDim2.new(1,-20,0,36)
	nameBox.Position = UDim2.new(0,10,0,90)
	nameBox.BackgroundColor3 = Color3.fromRGB(40,40,48)
	nameBox.PlaceholderText = "Nama"
	nameBox.Text = ""
	nameBox.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,8)
	nameBox.Parent = saveSub

	local saveSubBtn = Instance.new("TextButton")
	saveSubBtn.Size = UDim2.new(0,100,0,40)
	saveSubBtn.Position = UDim2.new(0,10,0,140)
	saveSubBtn.BackgroundColor3 = Color3.fromRGB(60,120,60)
	saveSubBtn.Text = "Save"
	saveSubBtn.TextColor3 = Color3.new(1,1,1)
	saveSubBtn.Font = Enum.Font.GothamBold
	saveSubBtn.TextSize = 16
	Instance.new("UICorner", saveSubBtn).CornerRadius = UDim.new(0,8)
	saveSubBtn.Parent = saveSub

	local closeSubBtn = Instance.new("TextButton")
	closeSubBtn.Size = UDim2.new(0,100,0,40)
	closeSubBtn.Position = UDim2.new(1,-110,0,140)
	closeSubBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
	closeSubBtn.Text = "Close"
	closeSubBtn.TextColor3 = Color3.new(1,1,1)
	closeSubBtn.Font = Enum.Font.GothamBold
	closeSubBtn.TextSize = 16
	Instance.new("UICorner", closeSubBtn).CornerRadius = UDim.new(0,8)
	closeSubBtn.Parent = saveSub

	saveBtn.MouseButton1Click:Connect(function()
		local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
		if pos then
			coord.Text = string.format("Position: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
		end
		main.Visible = false
		saveSub.Visible = true
	end)

	saveSubBtn.MouseButton1Click:Connect(function()
		local name = nameBox.Text
		if name == "" then
			name = "Teleport " .. (#_G.AzkaTeleports + 1)
		end
		local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
		if pos then
			table.insert(_G.AzkaTeleports, {name = name, pos = pos})
			refreshSavedList()
			saveSub.Visible = false
			main.Visible = true
			nameBox.Text = ""
		end
	end)

	closeSubBtn.MouseButton1Click:Connect(function()
		saveSub.Visible = false
		main.Visible = true
		nameBox.Text = ""
	end)

	tpClose.MouseButton1Click:Connect(function()
		main.Visible = false
	end)

	refreshSavedList()
	return main
end

-- State variables
local currentWS = 30
local currentBoost = 0
local godModeEnabled = false
local instantProxEnabled = false
local infiniteZoomEnabled = false
local freecamEnabled = false
local freecamPart = Instance.new("Part")
freecamPart.Anchored = true
freecamPart.CanCollide = false
freecamPart.Transparency = 1
freecamPart.Size = Vector3.new(1,1,1)
freecamPart.Parent = workspace

local freecamInfo = Instance.new("TextLabel")
freecamInfo.Size = UDim2.fromOffset(200, 30)
freecamInfo.Position = UDim2.new(0, 10, 0, 10)
freecamInfo.BackgroundColor3 = theme.Background
freecamInfo.TextColor3 = Color3.new(1,1,1)
freecamInfo.Text = "Freecam ON (WASD/SPACE/CTRL) - Shift to speed"
freecamInfo.Font = Enum.Font.GothamBold
freecamInfo.TextSize = 14
freecamInfo.Visible = false
freecamInfo.Parent = folder
makeDraggable(freecamInfo, freecamInfo)

-- Build Main UI
local AzkaUI = Library:CreateWindow("Script BY Azka")

-- Main Tab
local mainTab = AzkaUI:NewTab("Main")
local mainSection = mainTab:NewSection("Controls")

mainSection:NewSlider("WalkSpeed", "Kecepatan jalan", 1, 200, 30, function(val)
	currentWS = val
end)

mainSection:NewSlider("Boost", "Tambahan kecepatan", 0, 500, 0, function(val)
	currentBoost = val
end)

local noclipToggle = mainSection:NewToggle("Noclip", "Tembus dinding", false, function(state) end)
local infJumpToggle = mainSection:NewToggle("Inf Jump", "Lompat tanpa batas", false, function(state) end)
local flyUIToggle = mainSection:NewToggle("Fly UI", "Tampilkan panel fly", false, function(state)
	flyPanel.Visible = state
end)

local godModeToggle = mainSection:NewToggle("God Mode", "Tak terkalahkan", false, function(state)
	godModeEnabled = state
end)

local instantProxToggle = mainSection:NewToggle("Instant Proximity", "Interaksi instan", false, function(state)
	instantProxEnabled = state
end)

local infiniteZoomToggle = mainSection:NewToggle("Infinite Zoom", "Zoom tak terbatas", false, function(state)
	infiniteZoomEnabled = state
end)

local freecamToggle = mainSection:NewToggle("Freecam", "Kamera bebas", false, function(state)
	freecamEnabled = state
	freecamInfo.Visible = state
	if state then
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			freecamPart.CFrame = char.HumanoidRootPart.CFrame
		end
	else
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			Camera.CameraSubject = char.Humanoid
		end
	end
end)

local scriptLibToggle = mainSection:NewToggle("Script Library", "Koleksi script", false, function(state) end)

-- Teleport Tab
local tpTab = AzkaUI:NewTab("Teleport")
local tpSection = tpTab:NewSection("Teleport Manager")

tpSection:NewButton("Buka Teleport UI", "Tampilkan panel teleport", function()
	tpMain.Visible = true
end)

-- Create UI instances
local flyPanel = createFlyUI()
local tpMain = createTeleportUI()

-- Feature loops
task.spawn(function()
	local hum = waitForHumanoid()
	player.CharacterAdded:Connect(function()
		hum = waitForHumanoid()
	end)
	while true do
		if hum and hum.Parent then
			hum.WalkSpeed = currentWS + currentBoost
		end
		task.wait(0.01)
	end
end)

task.spawn(function()
	local hum = waitForHumanoid()
	player.CharacterAdded:Connect(function()
		hum = waitForHumanoid()
	end)
	UserInputService.JumpRequest:Connect(function()
		if infJumpToggle and type(infJumpToggle) == "function" and infJumpToggle() then
			if hum and hum.Parent then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
				hum.Jump = true
			end
		end
	end)
end)

task.spawn(function()
	while true do
		if noclipToggle and type(noclipToggle) == "function" and noclipToggle() then
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

task.spawn(function()
	local hum = waitForHumanoid()
	player.CharacterAdded:Connect(function()
		hum = waitForHumanoid()
	end)
	while true do
		if godModeEnabled and hum and hum.Parent then
			hum.MaxHealth = math.huge
			hum.Health = hum.MaxHealth
		end
		task.wait(0.1)
	end
end)

task.spawn(function()
	while true do
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

task.spawn(function()
	while true do
		if infiniteZoomEnabled then
			Camera.MaxAxisFieldOfView = 180
			Camera.FieldOfView = 120
		else
			Camera.MaxAxisFieldOfView = 120
		end
		task.wait(0.5)
	end
end)

local freecamSpeed = 0.5
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		freecamSpeed = 2
	end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		freecamSpeed = 0.5
	end
end)

RunService.RenderStepped:Connect(function()
	if freecamEnabled then
		local move = Vector3.new(
			(UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
			(UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
			(UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
		) * freecamSpeed
		freecamPart.CFrame = freecamPart.CFrame + move
		Camera.CFrame = CFrame.new(freecamPart.Position, freecamPart.Position + Camera.CFrame.LookVector)
	end
end)

-- Notification
local notif = Instance.new("TextLabel")
notif.Parent = folder
notif.Size = UDim2.fromOffset(200, 36)
notif.Position = UDim2.new(0.5, -100, 0, 20)
notif.BackgroundColor3 = theme.Background
notif.BackgroundTransparency = 0.2
notif.Text = "Script BY Azka - Loaded"
notif.TextColor3 = theme.TextColor
notif.Font = Enum.Font.Gotham
notif.TextSize = 14
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)

task.wait(2)
TweenService:Create(notif, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
task.wait(0.5)
notif:Destroy()
