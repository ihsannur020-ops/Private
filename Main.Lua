--[[
	Script BY Azka - Ultimate Controller (Final + TP UI tanpa minimize)
	- WalkSpeed slider (1-200) dengan nilai di pojok kanan
	- Boost slider (0-500) dengan nilai di pojok kanan
	- Inf Jump, Noclip toggle
	- Fly UI toggle (munculkan/sembunyikan panel fly)
	- TP UI toggle (munculkan/sembunyikan panel teleport)
	- Semua UI dapat di-drag, close
	- Fly UI memiliki minimize internal sendiri
	- Main menu menyesuaikan tinggi konten
	- Toggle bekerja benar: ON = tampil, OFF = sembunyi
	- Teleport UI: tanpa minimize, hanya close, layout: Save button, label, list, pagination
]]

-- Hapus GUI lama jika ada
local CoreGui = game:GetService("CoreGui")
local guiName = "ScriptBYAzka"
local flyGUIName = "AzkaFlyUI"
local tpGUIName = "AzkaTeleportUI"
local fpsGUIName = "AzkaFPSUI"
local settingsGUIName = "AzkaSettingsUI"
for _, name in ipairs({guiName, flyGUIName, tpGUIName, fpsGUIName, settingsGUIName}) do
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

-- Draggable function
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

-- Shared variables for linked toggles
local infiniteZoomEnabled = false

-- ========== MAIN MENU ==========
local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

-- Main panel (size diperbesar)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(450, 0)
panel.Position = UDim2.new(0.5, -225, 0.4, -100)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
panel.Parent = gui
panel.AutomaticSize = Enum.AutomaticSize.Y

local corner = Instance.new("UICorner", panel)
corner.CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", panel)
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(80, 120, 255)
stroke.Transparency = 0.25

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
titleBar.Parent = panel
titleBar.AutomaticSize = Enum.AutomaticSize.None
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(230, 235, 255)
title.Text = "Script BY Azka"
title.Parent = titleBar

-- Gear button (⚙)
local gearBtn = Instance.new("TextButton")
gearBtn.Name = "Gear"
gearBtn.Size = UDim2.fromOffset(36, 24)
gearBtn.Position = UDim2.new(1, -84, 0.5, -12)
gearBtn.Text = "⚙"
gearBtn.Font = Enum.Font.GothamBold
gearBtn.TextSize = 18
gearBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
gearBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0, 8)
gearBtn.Parent = titleBar

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Name = "Minimize"
minBtn.Size = UDim2.fromOffset(36, 24)
minBtn.Position = UDim2.new(1, -124, 0.5, -12)
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
minBtn.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.fromOffset(36, 24)
closeBtn.Position = UDim2.new(1, -44, 0.5, -12)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.Parent = titleBar

-- Body container
local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, -24, 1, -36)
body.Position = UDim2.new(0, 12, 0, 34)
body.BackgroundTransparency = 1
body.Parent = panel
body.AutomaticSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", body)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 12)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ===== WalkSpeed Slider =====
local wsContainer = Instance.new("Frame")
wsContainer.Size = UDim2.new(1, 0, 0, 40)
wsContainer.BackgroundTransparency = 1
wsContainer.Parent = body

local wsLabelIn = Instance.new("TextLabel")
wsLabelIn.BackgroundTransparency = 1
wsLabelIn.Size = UDim2.new(0.5, 0, 0, 24)
wsLabelIn.TextXAlignment = Enum.TextXAlignment.Left
wsLabelIn.Font = Enum.Font.Gotham
wsLabelIn.TextSize = 14
wsLabelIn.TextColor3 = Color3.fromRGB(210, 215, 230)
wsLabelIn.Text = "WalkSpeed"
wsLabelIn.Parent = wsContainer

local wsValueIn = Instance.new("TextLabel")
wsValueIn.BackgroundTransparency = 1
wsValueIn.Size = UDim2.new(0.5, 0, 0, 24)
wsValueIn.Position = UDim2.new(0.5, 0, 0, 0)
wsValueIn.TextXAlignment = Enum.TextXAlignment.Right
wsValueIn.Font = Enum.Font.GothamMedium
wsValueIn.TextSize = 14
wsValueIn.TextColor3 = Color3.fromRGB(180, 220, 255)
wsValueIn.Text = "30"
wsValueIn.Parent = wsContainer

local wsTrack = Instance.new("Frame")
wsTrack.Name = "WSTrack"
wsTrack.Size = UDim2.new(1, 0, 0, 8)
wsTrack.Position = UDim2.new(0, 0, 0, 28)
wsTrack.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
Instance.new("UICorner", wsTrack).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", wsTrack).Color = Color3.fromRGB(80, 120, 255)
wsTrack.Parent = wsContainer

local wsFill = Instance.new("Frame")
wsFill.Name = "WSFill"
wsFill.Size = UDim2.new(0, 0, 1, 0)
wsFill.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
Instance.new("UICorner", wsFill).CornerRadius = UDim.new(0, 6)
wsFill.Parent = wsTrack

local wsKnob = Instance.new("Frame")
wsKnob.Name = "WSKnob"
wsKnob.Size = UDim2.fromOffset(16, 16)
wsKnob.Position = UDim2.new(0, -8, 0.5, -8)
wsKnob.BackgroundColor3 = Color3.fromRGB(220, 230, 255)
Instance.new("UICorner", wsKnob).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", wsKnob).Color = Color3.fromRGB(40, 70, 160)
wsKnob.Parent = wsTrack

-- ===== Boost Slider =====
local boostContainer = Instance.new("Frame")
boostContainer.Size = UDim2.new(1, 0, 0, 40)
boostContainer.BackgroundTransparency = 1
boostContainer.Parent = body

local boostLabelIn = Instance.new("TextLabel")
boostLabelIn.BackgroundTransparency = 1
boostLabelIn.Size = UDim2.new(0.5, 0, 0, 24)
boostLabelIn.TextXAlignment = Enum.TextXAlignment.Left
boostLabelIn.Font = Enum.Font.Gotham
boostLabelIn.TextSize = 14
boostLabelIn.TextColor3 = Color3.fromRGB(210, 215, 230)
boostLabelIn.Text = "Boost"
boostLabelIn.Parent = boostContainer

local boostValueIn = Instance.new("TextLabel")
boostValueIn.BackgroundTransparency = 1
boostValueIn.Size = UDim2.new(0.5, 0, 0, 24)
boostValueIn.Position = UDim2.new(0.5, 0, 0, 0)
boostValueIn.TextXAlignment = Enum.TextXAlignment.Right
boostValueIn.Font = Enum.Font.GothamMedium
boostValueIn.TextSize = 14
boostValueIn.TextColor3 = Color3.fromRGB(180, 220, 255)
boostValueIn.Text = "0"
boostValueIn.Parent = boostContainer

local boostTrack = Instance.new("Frame")
boostTrack.Name = "BoostTrack"
boostTrack.Size = UDim2.new(1, 0, 0, 8)
boostTrack.Position = UDim2.new(0, 0, 0, 28)
boostTrack.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
Instance.new("UICorner", boostTrack).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", boostTrack).Color = Color3.fromRGB(80, 120, 255)
boostTrack.Parent = boostContainer

local boostFill = Instance.new("Frame")
boostFill.Name = "BoostFill"
boostFill.Size = UDim2.new(0, 0, 1, 0)
boostFill.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
Instance.new("UICorner", boostFill).CornerRadius = UDim.new(0, 6)
boostFill.Parent = boostTrack

local boostKnob = Instance.new("Frame")
boostKnob.Name = "BoostKnob"
boostKnob.Size = UDim2.fromOffset(16, 16)
boostKnob.Position = UDim2.new(0, -8, 0.5, -8)
boostKnob.BackgroundColor3 = Color3.fromRGB(220, 230, 255)
Instance.new("UICorner", boostKnob).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", boostKnob).Color = Color3.fromRGB(40, 70, 160)
boostKnob.Parent = boostTrack

-- ===== Slider Logic =====
local MIN_WS = 1
local MAX_WS = 200
local MIN_BOOST = 0
local MAX_BOOST = 500
local currentWS = 30
local currentBoost = 0

local draggingWS = false
local draggingBoost = false

local function setWSFromX(x)
	local absX = math.clamp(x - wsTrack.AbsolutePosition.X, 0, wsTrack.AbsoluteSize.X)
	local alpha = absX / wsTrack.AbsoluteSize.X
	local val = math.floor(MIN_WS + alpha * (MAX_WS - MIN_WS) + 0.5)
	currentWS = math.clamp(val, MIN_WS, MAX_WS)
	wsValueIn.Text = tostring(currentWS)
	wsFill.Size = UDim2.new(alpha, 0, 1, 0)
	wsKnob.Position = UDim2.new(alpha, -8, 0.5, -8)
end

local function setBoostFromX(x)
	local absX = math.clamp(x - boostTrack.AbsolutePosition.X, 0, boostTrack.AbsoluteSize.X)
	local alpha = absX / boostTrack.AbsoluteSize.X
	local val = math.floor(MIN_BOOST + alpha * (MAX_BOOST - MIN_BOOST) + 0.5)
	currentBoost = math.clamp(val, MIN_BOOST, MAX_BOOST)
	boostValueIn.Text = tostring(currentBoost)
	boostFill.Size = UDim2.new(alpha, 0, 1, 0)
	boostKnob.Position = UDim2.new(alpha, -8, 0.5, -8)
end

wsTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		draggingWS = true
		setWSFromX(input.Position.X)
	end
end)

wsKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		draggingWS = true
	end
end)

boostTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		draggingBoost = true
		setBoostFromX(input.Position.X)
	end
end)

boostKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		draggingBoost = true
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingWS and (input.UserInputType == Enum.UserInputType.MouseMovement or
	                   input.UserInputType == Enum.UserInputType.Touch) then
		setWSFromX(input.Position.X)
	end
	if draggingBoost and (input.UserInputType == Enum.UserInputType.MouseMovement or
	                      input.UserInputType == Enum.UserInputType.Touch) then
		setBoostFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		draggingWS = false
		draggingBoost = false
	end
end)

-- Inisialisasi slider ke default
task.wait()
setWSFromX(wsTrack.AbsolutePosition.X + (currentWS - MIN_WS) / (MAX_WS - MIN_WS) * wsTrack.AbsoluteSize.X)
setBoostFromX(boostTrack.AbsolutePosition.X)

-- ===== Helper untuk membuat toggle button =====
local function makeToggle(parent, text, width, initialColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, width or 100, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	btn.Text = text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(210, 215, 230)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(80, 120, 255)
	btn.Parent = parent
	local enabled = false
	btn.MouseButton1Click:Connect(function()
		enabled = not enabled
		btn.Text = text .. (enabled and ": ON" or ": OFF")
		btn.BackgroundColor3 = enabled and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
	end)
	return btn, function() return enabled end
end

-- ===== ROW 1 (Noclip, Inf Jump, Fly UI, TP UI) =====
local row1 = Instance.new("Frame")
row1.Size = UDim2.new(1, 0, 0, 30)
row1.BackgroundTransparency = 1
row1.Parent = body

local layout1 = Instance.new("UIListLayout", row1)
layout1.FillDirection = Enum.FillDirection.Horizontal
layout1.Padding = UDim.new(0, 8)
layout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout1.VerticalAlignment = Enum.VerticalAlignment.Center

-- Buat ulang toggle untuk row1 (urutan baru)
local noclipBtn, getNoclip = makeToggle(row1, "Noclip", 90)
local infJumpBtn, getInfJump = makeToggle(row1, "Inf Jump", 90)
local flyUIBtn, _ = makeToggle(row1, "Fly UI", 90)
local tpUIBtn, _ = makeToggle(row1, "TP UI", 90)

-- ===== ROW 2 (God Mode, Instant Proximity, Infinite Zoom, Freecam) =====
local row2 = Instance.new("Frame")
row2.Size = UDim2.new(1, 0, 0, 30)
row2.BackgroundTransparency = 1
row2.Parent = body

local layout2 = Instance.new("UIListLayout", row2)
layout2.FillDirection = Enum.FillDirection.Horizontal
layout2.Padding = UDim.new(0, 8)
layout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout2.VerticalAlignment = Enum.VerticalAlignment.Center

local godModeBtn, getGodMode = makeToggle(row2, "God Mode", 90)
local instantProxBtn, getInstantProx = makeToggle(row2, "Inst Prox", 90)
local infZoomBtn, getInfZoom = makeToggle(row2, "Inf Zoom", 90)
-- Hubungkan infiniteZoomEnabled dengan tombol
infZoomBtn.MouseButton1Click:Connect(function()
	-- toggle state sudah di handle oleh makeToggle, kita sync variabel
	infiniteZoomEnabled = not infiniteZoomEnabled
	-- Update tampilan tombol
	infZoomBtn.Text = "Inf Zoom" .. (infiniteZoomEnabled and ": ON" or ": OFF")
	infZoomBtn.BackgroundColor3 = infiniteZoomEnabled and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
end)
-- Override getter
local function getInfZoomState() return infiniteZoomEnabled end

local freecamBtn, getFreecam = makeToggle(row2, "Freecam", 90)

-- ===== ROW 3 (FPS UI, Script Library) =====
local row3 = Instance.new("Frame")
row3.Size = UDim2.new(1, 0, 0, 30)
row3.BackgroundTransparency = 1
row3.Parent = body

local layout3 = Instance.new("UIListLayout", row3)
layout3.FillDirection = Enum.FillDirection.Horizontal
layout3.Padding = UDim.new(0, 8)
layout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout3.VerticalAlignment = Enum.VerticalAlignment.Center

local fpsUIBtn, _ = makeToggle(row3, "FPS UI", 130)
local scriptLibBtn = Instance.new("TextButton") -- bukan toggle, hanya buka UI
scriptLibBtn.Size = UDim2.new(0, 130, 0, 28)
scriptLibBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
scriptLibBtn.Text = "Script Library"
scriptLibBtn.TextColor3 = Color3.fromRGB(210, 215, 230)
scriptLibBtn.Font = Enum.Font.GothamMedium
scriptLibBtn.TextSize = 13
Instance.new("UICorner", scriptLibBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", scriptLibBtn).Color = Color3.fromRGB(80, 120, 255)
scriptLibBtn.Parent = row3
scriptLibBtn.MouseButton1Click:Connect(function()
	-- Placeholder: nanti buka UI script library
	print("Script Library button clicked")
end)

-- Minimized icon for main menu (shoe)
local shoe = Instance.new("TextButton")
shoe.Name = "ShoeIcon"
shoe.Visible = false
shoe.Text = "👟"
shoe.Font = Enum.Font.GothamBold
shoe.TextSize = 20
shoe.Size = UDim2.fromOffset(40, 40)
shoe.Position = UDim2.new(0.5, -20, 0.45, -20)
shoe.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
shoe.TextColor3 = Color3.fromRGB(220, 230, 255)
Instance.new("UICorner", shoe).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", shoe).Color = Color3.fromRGB(80, 120, 255)
shoe.Parent = gui

makeDraggable(panel, titleBar)
makeDraggable(shoe, shoe)

minBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
	shoe.Visible = true
end)

shoe.MouseButton1Click:Connect(function()
	shoe.Visible = false
	panel.Visible = true
end)

-- ===== State untuk loop =====
local running = true

-- WalkSpeed enforcer (WS + Boost)
task.spawn(function()
	local hum = waitForHumanoid()
	player.CharacterAdded:Connect(function()
		hum = waitForHumanoid()
	end)
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
task.spawn(function()
	local hum = waitForHumanoid()
	player.CharacterAdded:Connect(function()
		hum = waitForHumanoid()
	end)
	UserInputService.JumpRequest:Connect(function()
		if getInfJump() and hum and hum.Parent then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			hum.Jump = true
		end
	end)
end)

-- Noclip
task.spawn(function()
	while running do
		if getNoclip() then
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

-- God Mode (sederhana: set health to huge)
task.spawn(function()
	local hum = waitForHumanoid()
	player.CharacterAdded:Connect(function()
		hum = waitForHumanoid()
	end)
	while running do
		if getGodMode() and hum and hum.Parent then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		elseif hum and hum.Parent then
			hum.MaxHealth = 100
		end
		task.wait(0.5)
	end
end)

-- Instant Proximity (placeholder: set ProximityPrompt MaxActivationDistance besar)
task.spawn(function()
	while running do
		if getInstantProx() then
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ProximityPrompt") then
					v.MaxActivationDistance = 100
				end
			end
		end
		task.wait(2)
	end
end)

-- Infinite Zoom (sederhana: set CameraMaxZoomDistance)
task.spawn(function()
	while running do
		if infiniteZoomEnabled then
			Camera.MaxZoomDistance = 10000
		else
			Camera.MaxZoomDistance = 400
		end
		task.wait(1)
	end
end)

-- Freecam (sederhana, menggunakan script freecam biasa)
local freecamActive = false
local freecamConnection
local function enableFreecam(enable)
	if enable then
		if freecamConnection then freecamConnection:Disconnect() end
		local cam = Camera
		local focus = cam.Focus
		local cf = cam.CFrame
		local speed = 1
		freecamConnection = RunService.RenderStepped:Connect(function(dt)
			if not getFreecam() then
				freecamConnection:Disconnect()
				freecamConnection = nil
				cam.CameraType = Enum.CameraType.Custom
				return
			end
			-- simple movement
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1,0,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1,0,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move + Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0,-1,0) end
			if move.Magnitude > 0 then
				move = move.Unit * speed * dt * 50
				cf = cf + move
			end
			-- rotation
			local mouseDelta = UserInputService:GetMouseDelta()
			cf = cf * CFrame.Angles(0, -math.rad(mouseDelta.X * 0.2), 0)
			cf = cf * CFrame.Angles(-math.rad(mouseDelta.Y * 0.2), 0, 0)
			cam.CFrame = cf
		end)
	else
		if freecamConnection then freecamConnection:Disconnect() freecamConnection = nil end
		Camera.CameraType = Enum.CameraType.Custom
	end
end
-- Hubungkan freecam toggle
freecamBtn.MouseButton1Click:Connect(function()
	-- toggle sudah di handle, tapi kita perlu trigger freecam
	local enabled = getFreecam()
	enableFreecam(enabled)
end)

-- ========== FLY UI (sama seperti sebelumnya) ==========
local function createFlyUI()
	local flyGui = Instance.new("ScreenGui")
	flyGui.Name = flyGUIName
	flyGui.ResetOnSpawn = false
	flyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	flyGui.Parent = CoreGui

	local flyFrame = Instance.new("Frame")
	flyFrame.Name = "FlyFrame"
	flyFrame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
	flyFrame.BorderColor3 = Color3.fromRGB(103, 221, 213)
	flyFrame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
	flyFrame.Size = UDim2.new(0, 190, 0, 57)
	flyFrame.Active = true
	flyFrame.Draggable = true
	flyFrame.Parent = flyGui
	flyFrame.Visible = false

	-- Buttons
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

	-- Fly logic (sederhana)
	local speeds = 1
	local nowe = false
	local tpwalking = false
	local speaker = player

	onof.MouseButton1Click:Connect(function()
		if nowe then
			nowe = false
			-- matikan fly (kode asli bisa ditambahkan)
		else
			nowe = true
			-- hidupkan fly
		end
	end)

	-- Up/Down hold
	local tis, dis
	up.MouseButton1Down:Connect(function()
		tis = up.MouseEnter:Connect(function()
			while tis do
				task.wait()
				player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
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
				player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
			end
		end)
	end)
	down.MouseLeave:Connect(function()
		if dis then dis:Disconnect() dis = nil end
	end)

	-- Speed controls
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

	-- Minimize
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

	player.CharacterAdded:Connect(function()
		task.wait(0.7)
		player.Character.Humanoid.PlatformStand = false
		player.Character.Animate.Disabled = false
	end)

	return flyGui, flyFrame, closeFly
end

-- Buat fly UI
local flyGui, flyFrame, flyClose = createFlyUI()

-- Fungsi untuk mengatur visibilitas fly UI
local function setFlyUIVisible(flag)
	flyFrame.Visible = flag
	flyUIBtn.Text = "Fly UI" .. (flag and ": ON" or ": OFF")
	flyUIBtn.BackgroundColor3 = flag and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
end

-- Hubungkan tombol close fly dengan toggle
flyClose.MouseButton1Click:Connect(function()
	setFlyUIVisible(false)
end)

-- Hubungkan flyUIBtn
flyUIBtn.MouseButton1Click:Connect(function()
	local newState = not flyFrame.Visible
	setFlyUIVisible(newState)
end)

-- ========== TELEPORT UI REDESIGN ==========
_G.AzkaTeleports = _G.AzkaTeleports or {}

local function createTeleportUI()
	local tpGui = Instance.new("ScreenGui")
	tpGui.Name = tpGUIName
	tpGui.ResetOnSpawn = false
	tpGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	tpGui.Parent = CoreGui

	-- Main Teleport Panel
	local main = Instance.new("Frame")
	main.Size = UDim2.fromOffset(400, 500)
	main.Position = UDim2.new(0.5, -200, 0.3, -250)
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	main.Visible = false
	main.Parent = tpGui
	makeDraggable(main, main)
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
	Instance.new("UIStroke", main).Color = Color3.fromRGB(80, 120, 255)

	-- Title bar dengan gear dan minimize
	local tbar = Instance.new("Frame")
	tbar.Size = UDim2.new(1, 0, 0, 36)
	tbar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	tbar.Parent = main
	Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 12)

	local ttitle = Instance.new("TextLabel")
	ttitle.BackgroundTransparency = 1
	ttitle.Size = UDim2.new(1, -120, 1, 0)
	ttitle.Position = UDim2.new(0, 12, 0, 0)
	ttitle.Text = "Teleport Menu"
	ttitle.Font = Enum.Font.GothamBold
	ttitle.TextSize = 18
	ttitle.TextColor3 = Color3.fromRGB(230, 235, 255)
	ttitle.TextXAlignment = Enum.TextXAlignment.Left
	ttitle.Parent = tbar

	-- Gear button
	local tpGear = Instance.new("TextButton")
	tpGear.Size = UDim2.fromOffset(36, 24)
	tpGear.Position = UDim2.new(1, -124, 0.5, -12)
	tpGear.Text = "⚙"
	tpGear.Font = Enum.Font.GothamBold
	tpGear.TextSize = 18
	tpGear.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	tpGear.TextColor3 = Color3.fromRGB(200, 205, 220)
	Instance.new("UICorner", tpGear).CornerRadius = UDim.new(0, 8)
	tpGear.Parent = tbar

	-- Minimize button
	local tpMin = Instance.new("TextButton")
	tpMin.Size = UDim2.fromOffset(36, 24)
	tpMin.Position = UDim2.new(1, -84, 0.5, -12)
	tpMin.Text = "—"
	tpMin.Font = Enum.Font.GothamBold
	tpMin.TextSize = 20
	tpMin.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	tpMin.TextColor3 = Color3.fromRGB(200, 205, 220)
	Instance.new("UICorner", tpMin).CornerRadius = UDim.new(0, 8)
	tpMin.Parent = tbar

	-- Close button
	local tpClose = Instance.new("TextButton")
	tpClose.Size = UDim2.fromOffset(36, 24)
	tpClose.Position = UDim2.new(1, -44, 0.5, -12)
	tpClose.Text = "X"
	tpClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
	tpClose.TextColor3 = Color3.fromRGB(255, 220, 220)
	Instance.new("UICorner", tpClose).CornerRadius = UDim.new(0, 8)
	tpClose.Parent = tbar

	-- Minimized circle (TP)
	local tpCircle = Instance.new("TextButton")
	tpCircle.Name = "TPCircle"
	tpCircle.Visible = false
	tpCircle.Text = "TP"
	tpCircle.Font = Enum.Font.GothamBold
	tpCircle.TextSize = 18
	tpCircle.Size = UDim2.fromOffset(50, 50)
	tpCircle.Position = UDim2.new(0.5, -25, 0.45, -25)
	tpCircle.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	tpCircle.TextColor3 = Color3.fromRGB(220, 230, 255)
	Instance.new("UICorner", tpCircle).CornerRadius = UDim.new(1, 0)
	Instance.new("UIStroke", tpCircle).Color = Color3.fromRGB(80, 120, 255)
	tpCircle.Parent = tpGui
	makeDraggable(tpCircle, tpCircle)

	tpMin.MouseButton1Click:Connect(function()
		main.Visible = false
		tpCircle.Visible = true
	end)
	tpCircle.MouseButton1Click:Connect(function()
		tpCircle.Visible = false
		main.Visible = true
	end)

	-- Konten utama dengan tab
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -20, 0, 40)
	tabBar.Position = UDim2.new(0, 10, 0, 44)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = main

	local tabLayout = Instance.new("UIListLayout", tabBar)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 10)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local savedTab = Instance.new("TextButton")
	savedTab.Size = UDim2.new(0, 100, 0, 30)
	savedTab.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
	savedTab.Text = "Saved"
	savedTab.TextColor3 = Color3.new(1,1,1)
	savedTab.Font = Enum.Font.GothamBold
	savedTab.TextSize = 14
	Instance.new("UICorner", savedTab).CornerRadius = UDim.new(0, 8)
	savedTab.Parent = tabBar

	local playersTab = Instance.new("TextButton")
	playersTab.Size = UDim2.new(0, 100, 0, 30)
	playersTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	playersTab.Text = "Players"
	playersTab.TextColor3 = Color3.fromRGB(210, 215, 230)
	playersTab.Font = Enum.Font.GothamBold
	playersTab.TextSize = 14
	Instance.new("UICorner", playersTab).CornerRadius = UDim.new(0, 8)
	playersTab.Parent = tabBar

	-- Konten Saved
	local savedContent = Instance.new("ScrollingFrame")
	savedContent.Size = UDim2.new(1, -20, 1, -90)
	savedContent.Position = UDim2.new(0, 10, 0, 90)
	savedContent.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	savedContent.ScrollBarThickness = 6
	savedContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	Instance.new("UICorner", savedContent).CornerRadius = UDim.new(0, 8)
	savedContent.Parent = main
	savedContent.Visible = true

	local savedLayout = Instance.new("UIListLayout", savedContent)
	savedLayout.Padding = UDim.new(0, 8)
	savedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- Konten Players
	local playersContent = Instance.new("ScrollingFrame")
	playersContent.Size = UDim2.new(1, -20, 1, -90)
	playersContent.Position = UDim2.new(0, 10, 0, 90)
	playersContent.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	playersContent.ScrollBarThickness = 6
	playersContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	Instance.new("UICorner", playersContent).CornerRadius = UDim.new(0, 8)
	playersContent.Parent = main
	playersContent.Visible = false

	local playersLayout = Instance.new("UIListLayout", playersContent)
	playersLayout.Padding = UDim.new(0, 8)
	playersLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- Tombol Save (di dalam savedContent)
	local saveBtn = Instance.new("TextButton")
	saveBtn.Size = UDim2.new(1, -10, 0, 40)
	saveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	saveBtn.Text = "Save Teleport"
	saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveBtn.Font = Enum.Font.GothamBold
	saveBtn.TextSize = 16
	Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
	saveBtn.Parent = savedContent

	-- Panel Save
	local saveSub = Instance.new("Frame")
	saveSub.Size = UDim2.fromOffset(300, 220)
	saveSub.Position = UDim2.new(0.5, -150, 0.5, -110)
	saveSub.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	saveSub.Visible = false
	saveSub.Parent = tpGui
	makeDraggable(saveSub, saveSub)
	Instance.new("UICorner", saveSub).CornerRadius = UDim.new(0, 12)
	Instance.new("UIStroke", saveSub).Color = Color3.fromRGB(80, 120, 255)

	local subTitle = Instance.new("TextLabel")
	subTitle.Size = UDim2.new(1, 0, 0, 40)
	subTitle.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	subTitle.Text = "Save Teleport"
	subTitle.Font = Enum.Font.GothamBold
	subTitle.TextSize = 18
	subTitle.TextColor3 = Color3.fromRGB(230, 235, 255)
	Instance.new("UICorner", subTitle).CornerRadius = UDim.new(0, 12)
	subTitle.Parent = saveSub

	local coord = Instance.new("TextLabel")
	coord.Size = UDim2.new(1, -20, 0, 30)
	coord.Position = UDim2.new(0, 10, 0, 50)
	coord.BackgroundTransparency = 1
	coord.Text = "Position: 0, 0, 0"
	coord.TextColor3 = Color3.fromRGB(255, 255, 255)
	coord.Font = Enum.Font.GothamBold
	coord.TextSize = 16
	coord.Parent = saveSub

	local nameBox = Instance.new("TextBox")
	nameBox.Size = UDim2.new(1, -20, 0, 36)
	nameBox.Position = UDim2.new(0, 10, 0, 90)
	nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	nameBox.PlaceholderText = "Nama"
	nameBox.Text = ""
	nameBox.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)
	nameBox.Parent = saveSub

	local saveSubBtn = Instance.new("TextButton")
	saveSubBtn.Size = UDim2.new(0, 100, 0, 40)
	saveSubBtn.Position = UDim2.new(0, 10, 0, 140)
	saveSubBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
	saveSubBtn.Text = "Save"
	saveSubBtn.TextColor3 = Color3.new(1,1,1)
	saveSubBtn.Font = Enum.Font.GothamBold
	saveSubBtn.TextSize = 16
	Instance.new("UICorner", saveSubBtn).CornerRadius = UDim.new(0, 8)
	saveSubBtn.Parent = saveSub

	local closeSubBtn = Instance.new("TextButton")
	closeSubBtn.Size = UDim2.new(0, 100, 0, 40)
	closeSubBtn.Position = UDim2.new(1, -110, 0, 140)
	closeSubBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeSubBtn.Text = "Close"
	closeSubBtn.TextColor3 = Color3.new(1,1,1)
	closeSubBtn.Font = Enum.Font.GothamBold
	closeSubBtn.TextSize = 16
	Instance.new("UICorner", closeSubBtn).CornerRadius = UDim.new(0, 8)
	closeSubBtn.Parent = saveSub

	-- Fungsi refresh saved list
	local function refreshSaved()
		for _, child in ipairs(savedContent:GetChildren()) do
			if child:IsA("Frame") and child ~= saveBtn then child:Destroy() end
		end
		local teleports = _G.AzkaTeleports
		for i, data in ipairs(teleports) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, -10, 0, 40)
			item.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
			item.Parent = savedContent

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
				refreshSaved()
			end)
		end
		-- Update canvas
		local h = 0
		for _, ch in ipairs(savedContent:GetChildren()) do
			if ch:IsA("Frame") then
				h = h + ch.Size.Y.Offset + savedLayout.Padding.Offset
			end
		end
		savedContent.CanvasSize = UDim2.new(0,0,0,h+40)
	end

	-- Fungsi refresh players list
	local function refreshPlayers()
		for _, child in ipairs(playersContent:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local item = Instance.new("Frame")
				item.Size = UDim2.new(1, -10, 0, 40)
				item.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
				Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
				item.Parent = playersContent

				local name = Instance.new("TextLabel")
				name.Size = UDim2.new(0.6, -5, 1, 0)
				name.Position = UDim2.new(0, 5, 0, 0)
				name.BackgroundTransparency = 1
				name.Text = plr.Name
				name.TextColor3 = Color3.new(1,1,1)
				name.Font = Enum.Font.GothamBold
				name.TextSize = 14
				name.TextXAlignment = Enum.TextXAlignment.Left
				name.Parent = item

				local tp = Instance.new("TextButton")
				tp.Size = UDim2.new(0, 100, 0, 30)
				tp.Position = UDim2.new(1, -105, 0.5, -15)
				tp.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
				tp.Text = "Teleport"
				tp.TextColor3 = Color3.new(1,1,1)
				tp.Font = Enum.Font.GothamMedium
				tp.TextSize = 12
				Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 6)
				tp.Parent = item
				tp.MouseButton1Click:Connect(function()
					local char = plr.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						local myChar = player.Character
						if myChar and myChar:FindFirstChild("HumanoidRootPart") then
							myChar.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
						end
					end
				end)
			end
		end
		local h = 0
		for _, ch in ipairs(playersContent:GetChildren()) do
			if ch:IsA("Frame") then
				h = h + ch.Size.Y.Offset + playersLayout.Padding.Offset
			end
		end
		playersContent.CanvasSize = UDim2.new(0,0,0,h)
	end

	-- Tab switching
	savedTab.MouseButton1Click:Connect(function()
		savedTab.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
		savedTab.TextColor3 = Color3.new(1,1,1)
		playersTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		playersTab.TextColor3 = Color3.fromRGB(210, 215, 230)
		savedContent.Visible = true
		playersContent.Visible = false
		refreshSaved()
	end)
	playersTab.MouseButton1Click:Connect(function()
		playersTab.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
		playersTab.TextColor3 = Color3.new(1,1,1)
		savedTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		savedTab.TextColor3 = Color3.fromRGB(210, 215, 230)
		savedContent.Visible = false
		playersContent.Visible = true
		refreshPlayers()
	end)

	-- Save button
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
			refreshSaved()
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

	-- Initial refresh
	refreshSaved()
	-- Auto refresh player list setiap 5 detik
	task.spawn(function()
		while running do
			task.wait(5)
			if playersContent.Visible then
				refreshPlayers()
			end
		end
	end)

	return tpGui, main, tpClose, tpGear
end

-- Buat TP UI
local tpGui, tpMain, tpClose, tpGear = createTeleportUI()

-- Fungsi untuk mengatur visibilitas TP UI
local function setTPUIVisible(flag)
	tpMain.Visible = flag
	tpUIBtn.Text = "TP UI" .. (flag and ": ON" or ": OFF")
	tpUIBtn.BackgroundColor3 = flag and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
end

-- Hubungkan tombol close TP
tpClose.MouseButton1Click:Connect(function()
	setTPUIVisible(false)
end)

-- Hubungkan tpUIBtn
tpUIBtn.MouseButton1Click:Connect(function()
	local newState = not tpMain.Visible
	setTPUIVisible(newState)
end)

-- ========== SETTINGS UI ==========
local settingsGui = Instance.new("ScreenGui")
settingsGui.Name = settingsGUIName
settingsGui.ResetOnSpawn = false
settingsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
settingsGui.Parent = CoreGui

local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.fromOffset(350, 500)
settingsFrame.Position = UDim2.new(0.5, -175, 0.3, -250)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
settingsFrame.Visible = false
settingsFrame.Parent = settingsGui
makeDraggable(settingsFrame, settingsFrame)
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", settingsFrame).Color = Color3.fromRGB(80, 120, 255)

-- Title bar
local setTitleBar = Instance.new("Frame")
setTitleBar.Size = UDim2.new(1, 0, 0, 36)
setTitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
setTitleBar.Parent = settingsFrame
Instance.new("UICorner", setTitleBar).CornerRadius = UDim.new(0, 12)

local setTitle = Instance.new("TextLabel")
setTitle.BackgroundTransparency = 1
setTitle.Size = UDim2.new(1, -44, 1, 0)
setTitle.Position = UDim2.new(0, 12, 0, 0)
setTitle.Text = "Settings"
setTitle.Font = Enum.Font.GothamBold
setTitle.TextSize = 18
setTitle.TextColor3 = Color3.fromRGB(230, 235, 255)
setTitle.TextXAlignment = Enum.TextXAlignment.Left
setTitle.Parent = setTitleBar

local setClose = Instance.new("TextButton")
setClose.Size = UDim2.fromOffset(36, 24)
setClose.Position = UDim2.new(1, -44, 0.5, -12)
setClose.Text = "X"
setClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
setClose.TextColor3 = Color3.fromRGB(255, 220, 220)
Instance.new("UICorner", setClose).CornerRadius = UDim.new(0, 8)
setClose.Parent = setTitleBar

-- Body scrolling
local setBody = Instance.new("ScrollingFrame")
setBody.Size = UDim2.new(1, -20, 1, -50)
setBody.Position = UDim2.new(0, 10, 0, 44)
setBody.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
setBody.ScrollBarThickness = 6
setBody.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", setBody).CornerRadius = UDim.new(0, 8)
setBody.Parent = settingsFrame

local setLayout = Instance.new("UIListLayout", setBody)
setLayout.Padding = UDim.new(0, 8)
setLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Fungsi untuk menambah toggle di settings
local function addToggle(text, default)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	btn.Text = text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(210, 215, 230)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.Parent = setBody
	local enabled = false
	btn.MouseButton1Click:Connect(function()
		enabled = not enabled
		btn.Text = text .. (enabled and ": ON" or ": OFF")
		btn.BackgroundColor3 = enabled and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
	end)
	return btn, function() return enabled end
end

-- Fungsi untuk menambah tombol aksi
local function addActionButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.Parent = setBody
	btn.MouseButton1Click:Connect(callback)
end

-- Isi settings
addToggle("User Info Display", false)
addToggle("Live Character Stats", false)

-- Anti-AFK dengan timer
local antiAfkBtn, getAntiAfk = addToggle("Anti-AFK System", false)
-- Timer input
local timerFrame = Instance.new("Frame")
timerFrame.Size = UDim2.new(1, -10, 0, 40)
timerFrame.BackgroundTransparency = 1
timerFrame.Visible = false
timerFrame.Parent = setBody

local timerLayout = Instance.new("UIListLayout", timerFrame)
timerLayout.FillDirection = Enum.FillDirection.Horizontal
timerLayout.Padding = UDim.new(0, 5)
timerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local secBox = Instance.new("TextBox")
secBox.Size = UDim2.new(0, 70, 0, 30)
secBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
secBox.PlaceholderText = "Detik"
secBox.Text = "0"
secBox.TextColor3 = Color3.new(1,1,1)
secBox.Font = Enum.Font.GothamMedium
secBox.TextSize = 14
Instance.new("UICorner", secBox).CornerRadius = UDim.new(0, 8)
secBox.Parent = timerFrame

local minBox = Instance.new("TextBox")
minBox.Size = UDim2.new(0, 70, 0, 30)
minBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBox.PlaceholderText = "Menit"
minBox.Text = "10"
minBox.TextColor3 = Color3.new(1,1,1)
minBox.Font = Enum.Font.GothamMedium
minBox.TextSize = 14
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0, 8)
minBox.Parent = timerFrame

local afkStatus = Instance.new("TextButton")
afkStatus.Size = UDim2.new(0, 80, 0, 30)
afkStatus.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
afkStatus.Text = "Online"
afkStatus.TextColor3 = Color3.new(1,1,1)
afkStatus.Font = Enum.Font.GothamBold
afkStatus.TextSize = 14
Instance.new("UICorner", afkStatus).CornerRadius = UDim.new(0, 8)
afkStatus.Parent = timerFrame

antiAfkBtn.MouseButton1Click:Connect(function()
	-- toggle state sudah dihandle, kita update visibility timer
	timerFrame.Visible = getAntiAfk()
end)

afkStatus.MouseButton1Click:Connect(function()
	if afkStatus.Text == "Online" then
		afkStatus.Text = "AFK"
		afkStatus.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
		-- Mulai simulasi aktivitas
	else
		afkStatus.Text = "Online"
		afkStatus.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		-- Hentikan simulasi
	end
end)

addToggle("Admin Bypass Detection", false)
addActionButton("Server Hop & Rejoin", function() print("Server Hop") end)
addActionButton("Character Respawn", function() player.Character:BreakJoints() end)
addToggle("Bypass Anticheat", false)
addActionButton("Scanner Backdoor", function() print("Scanner Backdoor") end)
addActionButton("Scanner Remote", function() print("Scanner Remote") end)
addActionButton("Dex Exploit", function() print("Dex Exploit") end)
addToggle("Anti Fling", false)
addToggle("Anti Void", false)
addActionButton("Player Avatar Copy", function() print("Avatar Copy") end)
addToggle("Fake Display Name", false)

-- Update canvas size
setBody.CanvasSize = UDim2.new(0,0,0, setLayout.AbsoluteContentSize.Y)

-- Hubungkan gear button di main menu
gearBtn.MouseButton1Click:Connect(function()
	settingsFrame.Visible = not settingsFrame.Visible
end)
tpGear.MouseButton1Click:Connect(function()
	settingsFrame.Visible = not settingsFrame.Visible
end)
-- Nanti untuk FPS UI juga akan ditambahkan gear

setClose.MouseButton1Click:Connect(function()
	settingsFrame.Visible = false
end)

-- ========== FPS UI ==========
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = fpsGUIName
fpsGui.ResetOnSpawn = false
fpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fpsGui.Parent = CoreGui

local fpsMain = Instance.new("Frame")
fpsMain.Size = UDim2.fromOffset(400, 500)
fpsMain.Position = UDim2.new(0.5, -200, 0.3, -250)
fpsMain.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
fpsMain.Visible = false
fpsMain.Parent = fpsGui
makeDraggable(fpsMain, fpsMain)
Instance.new("UICorner", fpsMain).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", fpsMain).Color = Color3.fromRGB(80, 120, 255)

-- Title bar
local fpsTitleBar = Instance.new("Frame")
fpsTitleBar.Size = UDim2.new(1, 0, 0, 36)
fpsTitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
fpsTitleBar.Parent = fpsMain
Instance.new("UICorner", fpsTitleBar).CornerRadius = UDim.new(0, 12)

local fpsTitle = Instance.new("TextLabel")
fpsTitle.BackgroundTransparency = 1
fpsTitle.Size = UDim2.new(1, -120, 1, 0)
fpsTitle.Position = UDim2.new(0, 12, 0, 0)
fpsTitle.Text = "FPS Menu"
fpsTitle.Font = Enum.Font.GothamBold
fpsTitle.TextSize = 18
fpsTitle.TextColor3 = Color3.fromRGB(230, 235, 255)
fpsTitle.TextXAlignment = Enum.TextXAlignment.Left
fpsTitle.Parent = fpsTitleBar

-- Gear
local fpsGear = Instance.new("TextButton")
fpsGear.Size = UDim2.fromOffset(36, 24)
fpsGear.Position = UDim2.new(1, -124, 0.5, -12)
fpsGear.Text = "⚙"
fpsGear.Font = Enum.Font.GothamBold
fpsGear.TextSize = 18
fpsGear.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
fpsGear.TextColor3 = Color3.fromRGB(200, 205, 220)
Instance.new("UICorner", fpsGear).CornerRadius = UDim.new(0, 8)
fpsGear.Parent = fpsTitleBar
fpsGear.MouseButton1Click:Connect(function() settingsFrame.Visible = not settingsFrame.Visible end)

-- Minimize
local fpsMin = Instance.new("TextButton")
fpsMin.Size = UDim2.fromOffset(36, 24)
fpsMin.Position = UDim2.new(1, -84, 0.5, -12)
fpsMin.Text = "—"
fpsMin.Font = Enum.Font.GothamBold
fpsMin.TextSize = 20
fpsMin.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
fpsMin.TextColor3 = Color3.fromRGB(200, 205, 220)
Instance.new("UICorner", fpsMin).CornerRadius = UDim.new(0, 8)
fpsMin.Parent = fpsTitleBar

-- Close
local fpsClose = Instance.new("TextButton")
fpsClose.Size = UDim2.fromOffset(36, 24)
fpsClose.Position = UDim2.new(1, -44, 0.5, -12)
fpsClose.Text = "X"
fpsClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
fpsClose.TextColor3 = Color3.fromRGB(255, 220, 220)
Instance.new("UICorner", fpsClose).CornerRadius = UDim.new(0, 8)
fpsClose.Parent = fpsTitleBar

-- Minimized circle (FPS)
local fpsCircle = Instance.new("TextButton")
fpsCircle.Name = "FPSCircle"
fpsCircle.Visible = false
fpsCircle.Text = "FPS"
fpsCircle.Font = Enum.Font.GothamBold
fpsCircle.TextSize = 18
fpsCircle.Size = UDim2.fromOffset(50, 50)
fpsCircle.Position = UDim2.new(0.5, -25, 0.45, -25)
fpsCircle.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
fpsCircle.TextColor3 = Color3.fromRGB(220, 230, 255)
Instance.new("UICorner", fpsCircle).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", fpsCircle).Color = Color3.fromRGB(80, 120, 255)
fpsCircle.Parent = fpsGui
makeDraggable(fpsCircle, fpsCircle)

fpsMin.MouseButton1Click:Connect(function()
	fpsMain.Visible = false
	fpsCircle.Visible = true
end)
fpsCircle.MouseButton1Click:Connect(function()
	fpsCircle.Visible = false
	fpsMain.Visible = true
end)

-- Konten FPS UI (rows)
local fpsBody = Instance.new("ScrollingFrame")
fpsBody.Size = UDim2.new(1, -20, 1, -50)
fpsBody.Position = UDim2.new(0, 10, 0, 44)
fpsBody.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
fpsBody.ScrollBarThickness = 6
fpsBody.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", fpsBody).CornerRadius = UDim.new(0, 8)
fpsBody.Parent = fpsMain

local fpsLayout = Instance.new("UIListLayout", fpsBody)
fpsLayout.Padding = UDim.new(0, 12)
fpsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper untuk membuat row dengan beberapa toggle
local function makeToggleRow(parent, toggles)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundTransparency = 1
	row.Parent = parent
	local layout = Instance.new("UIListLayout", row)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local btns = {}
	for _, data in ipairs(toggles) do
		local btn, get = makeToggle(row, data.text, data.width or 90)
		btns[data.text] = {btn=btn, get=get}
	end
	return btns
end

-- Row 1: silent aim, target visualization, teamcheck, visible check
makeToggleRow(fpsBody, {
	{text="Silent Aim", width=90},
	{text="Target Vis", width=90},
	{text="Teamcheck", width=90},
	{text="Visible", width=90}
})

-- Row 2: hitchance / targetpart, Infinite Zoom, esp, esp boxes
makeToggleRow(fpsBody, {
	{text="Hitchance", width=90},
	{text="Inf Zoom", width=90},
	{text="ESP", width=90},
	{text="ESP Boxes", width=90}
})

-- Row 3: Health, show displayname, show equipped item, show distance
makeToggleRow(fpsBody, {
	{text="Health", width=90},
	{text="DispName", width=90},
	{text="Equipped", width=90},
	{text="Distance", width=90}
})

-- Row 4: show tracers, teamcheck, use team color, chams
makeToggleRow(fpsBody, {
	{text="Tracers", width=90},
	{text="Teamcheck2", width=90},
	{text="Team Color", width=90},
	{text="Chams", width=90}
})

-- Hubungkan Infinite Zoom di FPS UI dengan main menu
-- Kita akan cari toggle "Inf Zoom" di row2. Karena kita tidak menyimpan referensi, kita bisa mencari berdasarkan teks.
-- Alternatif: kita buat referensi global untuk toggle infinite zoom di FPS UI.
local infZoomFPS
for _, child in ipairs(fpsBody:GetChildren()) do
	if child:IsA("Frame") then
		for _, btn in ipairs(child:GetChildren()) do
			if btn:IsA("TextButton") and btn.Text:find("Inf Zoom") then
				infZoomFPS = btn
				break
			end
		end
	end
end
if infZoomFPS then
	-- Saat infinite zoom di main menu berubah, update FPS UI
	-- Kita override fungsi klik di main menu
	local oldClick = infZoomBtn.MouseButton1Click
	infZoomBtn.MouseButton1Click:Connect(function()
		infiniteZoomEnabled = not infiniteZoomEnabled
		infZoomBtn.Text = "Inf Zoom" .. (infiniteZoomEnabled and ": ON" or ": OFF")
		infZoomBtn.BackgroundColor3 = infiniteZoomEnabled and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
		-- Update FPS UI
		if infZoomFPS then
			local enabled = infiniteZoomEnabled
			infZoomFPS.Text = "Inf Zoom" .. (enabled and ": ON" or ": OFF")
			infZoomFPS.BackgroundColor3 = enabled and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
		end
	end)
	-- Saat infinite zoom di FPS UI diklik, update main menu
	infZoomFPS.MouseButton1Click:Connect(function()
		infiniteZoomEnabled = not infiniteZoomEnabled
		infZoomFPS.Text = "Inf Zoom" .. (infiniteZoomEnabled and ": ON" or ": OFF")
		infZoomFPS.BackgroundColor3 = infiniteZoomEnabled and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
		-- Update main menu
		infZoomBtn.Text = "Inf Zoom" .. (infiniteZoomEnabled and ": ON" or ": OFF")
		infZoomBtn.BackgroundColor3 = infiniteZoomEnabled and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
	end)
end

-- Fungsi untuk mengatur visibilitas FPS UI
local function setFPSUIVisible(flag)
	fpsMain.Visible = flag
	fpsUIBtn.Text = "FPS UI" .. (flag and ": ON" or ": OFF")
	fpsUIBtn.BackgroundColor3 = flag and Color3.fromRGB(35, 70, 45) or Color3.fromRGB(40, 40, 48)
end

fpsClose.MouseButton1Click:Connect(function()
	setFPSUIVisible(false)
end)

fpsUIBtn.MouseButton1Click:Connect(function()
	local newState = not fpsMain.Visible
	setFPSUIVisible(newState)
end)

-- Update canvas size fpsBody
fpsBody.CanvasSize = UDim2.new(0,0,0, fpsLayout.AbsoluteContentSize.Y)

-- Close main menu
closeBtn.MouseButton1Click:Connect(function()
	running = false
	gui:Destroy()
	flyGui:Destroy()
	tpGui:Destroy()
	fpsGui:Destroy()
	settingsGui:Destroy()
end)

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
notif.Parent = gui
Instance.new("UICorner", notif).CornerRadius = UDim.new(0,8)

task.wait(2)
TweenService:Create(notif, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
task.wait(0.5)
notif:Destroy()
