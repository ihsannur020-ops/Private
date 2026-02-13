--[[
	Speed Control Universal - Delta Executor Ready (FIXED V3)
	Oleh: Azka
	Desain: Modern Minimalis seperti referensi gambar
--]]

task.spawn(function()
	local success, err = pcall(function()
		-- ========== SERVICES ==========
		local Players = game:GetService("Players")
		local UserInputService = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")
		local TweenService = game:GetService("TweenService")
		
		local player = Players.LocalPlayer
		if not player then
			player = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		end

		-- ========== LOADING SCREEN ==========
		local loadingGui = Instance.new("ScreenGui")
		loadingGui.Name = "LoadingScreen"
		loadingGui.Parent = player:WaitForChild("PlayerGui")
		loadingGui.ResetOnSpawn = false
		loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		loadingGui.DisplayOrder = 999

		local blackFrame = Instance.new("Frame")
		blackFrame.Size = UDim2.new(1, 0, 1, 0)
		blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
		blackFrame.BackgroundTransparency = 0.4
		blackFrame.BorderSizePixel = 0
		blackFrame.Parent = loadingGui

		local loadingText = Instance.new("TextLabel")
		loadingText.Size = UDim2.new(0, 400, 0, 100)
		loadingText.Position = UDim2.new(0.5, -200, 0.5, -50)
		loadingText.BackgroundTransparency = 1
		loadingText.Text = "Speed Control By Azka"
		loadingText.TextColor3 = Color3.new(1, 1, 1)
		loadingText.Font = Enum.Font.GothamBold
		loadingText.TextSize = 48
		loadingText.TextTransparency = 1
		loadingText.Parent = blackFrame

		local fadeIn = TweenService:Create(loadingText, TweenInfo.new(0.5), {TextTransparency = 0})
		fadeIn:Play()
		fadeIn.Completed:Wait()

		-- ========== GLOBAL VARIABLES ==========
		if _G.SpeedControlLoaded then loadingGui:Destroy(); return end
		_G.SpeedControlLoaded = true

		local flyEnabled = false
		local flySpeed = 1
		local flyConnection = nil
		local flyBodyVelocity = nil
		local flyGui = nil
		local isFlying = false

		local noclipEnabled = false
		local noclipConnection = nil

		local infJumpEnabled = false
		local infJumpConnection = nil

		local lastWalkSpeed = 30

		-- ========== GUI UTAMA ==========
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "SpeedControlGUI"
		screenGui.Parent = player:WaitForChild("PlayerGui")
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

		-- ========== FUNGSI DRAG (HANYA HEADER) ==========
		local function makeDraggable(frame, handle)
			handle = handle or frame
			local dragging = false
			local dragStart, startPos

			handle.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = frame.Position
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local delta = input.Position - dragStart
					frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
		end

		-- ========== KOMPONEN UI ==========
		local function createModernSwitch(parent, defaultOn, callback)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(0, 44, 0, 24)
			container.BackgroundTransparency = 1

			local bg = Instance.new("Frame")
			bg.Name = "Background"
			bg.Size = UDim2.new(1, 0, 1, 0)
			bg.BackgroundColor3 = defaultOn and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(60, 60, 60)
			bg.BorderSizePixel = 0
			bg.Parent = container

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = bg

			local knob = Instance.new("Frame")
			knob.Name = "Knob"
			knob.Size = UDim2.new(0, 18, 0, 18)
			knob.Position = defaultOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
			knob.BackgroundColor3 = Color3.new(1, 1, 1)
			knob.BorderSizePixel = 0
			knob.Parent = bg

			local knobCorner = Instance.new("UICorner")
			knobCorner.CornerRadius = UDim.new(1, 0)
			knobCorner.Parent = knob

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.Parent = container

			local state = defaultOn

			btn.MouseButton1Click:Connect(function()
				state = not state
				local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
				local targetColor = state and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(60, 60, 60)
				
				TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
				TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
				
				if callback then task.spawn(callback, state) end
			end)

			container.Parent = parent
			return container
		end

		local function createSlider(parent, min, max, default, callback)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, 0, 0, 45)
			container.BackgroundTransparency = 1
			container.ClipsDescendants = true -- Prevent drag from affecting parent

			local valueLabel = Instance.new("TextLabel")
			valueLabel.Size = UDim2.new(0, 50, 0, 20)
			valueLabel.BackgroundTransparency = 1
			valueLabel.Text = tostring(math.floor(default))
			valueLabel.TextColor3 = Color3.new(1, 1, 1)
			valueLabel.Font = Enum.Font.GothamBold
			valueLabel.TextSize = 18
			valueLabel.TextXAlignment = Enum.TextXAlignment.Left
			valueLabel.Parent = container

			local track = Instance.new("Frame")
			track.Name = "Track"
			track.Size = UDim2.new(1, 0, 0, 6)
			track.Position = UDim2.new(0, 0, 0, 28)
			track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			track.BorderSizePixel = 0
			track.Parent = container

			local trackCorner = Instance.new("UICorner")
			trackCorner.CornerRadius = UDim.new(1, 0)
			trackCorner.Parent = track

			local fill = Instance.new("Frame")
			fill.Name = "Fill"
			fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
			fill.BorderSizePixel = 0
			fill.Parent = track

			local fillCorner = Instance.new("UICorner")
			fillCorner.CornerRadius = UDim.new(1, 0)
			fillCorner.Parent = fill

			local knob = Instance.new("TextButton")
			knob.Name = "Knob"
			knob.Size = UDim2.new(0, 16, 0, 16)
			knob.Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8)
			knob.BackgroundColor3 = Color3.new(1, 1, 1)
			knob.BorderSizePixel = 0
			knob.Text = ""
			knob.AutoButtonColor = false
			knob.Parent = track

			local knobCorner = Instance.new("UICorner")
			knobCorner.CornerRadius = UDim.new(1, 0)
			knobCorner.Parent = knob

			local currentValue = default
			local dragging = false

			local function updateFromInput(input)
				local absPos = track.AbsolutePosition.X
				local absSize = track.AbsoluteSize.X
				local mouseX = input.Position.X
				local percent = math.clamp((mouseX - absPos) / absSize, 0, 1)
				currentValue = math.floor(min + percent * (max - min) + 0.5)
				
				fill.Size = UDim2.new(percent, 0, 1, 0)
				knob.Position = UDim2.new(percent, -8, 0.5, -8)
				valueLabel.Text = tostring(currentValue)
				
				if callback then callback(currentValue) end
			end

			knob.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					TweenService:Create(knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 20, 0, 20)}):Play()
				end
			end)

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					updateFromInput(input)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateFromInput(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
					TweenService:Create(knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 16, 0, 16)}):Play()
				end
			end)

			container.Parent = parent
			return container
		end

		-- ========== FLY MENU (DENGAN TOMBOL FLY) ==========
		local function createFlyMenu()
			if flyGui then flyGui:Destroy() end
			
			flyGui = Instance.new("Frame")
			flyGui.Name = "FlyMenu"
			flyGui.Size = UDim2.new(0, 240, 0, 160)
			flyGui.Position = UDim2.new(0.5, -120, 0.7, -80)
			flyGui.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			flyGui.BorderSizePixel = 0
			flyGui.Parent = screenGui
			makeDraggable(flyGui)

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = flyGui

			-- Header
			local header = Instance.new("Frame")
			header.Size = UDim2.new(1, 0, 0, 36)
			header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			header.BorderSizePixel = 0
			header.Parent = flyGui
			makeDraggable(flyGui, header)

			local headerCorner = Instance.new("UICorner")
			headerCorner.CornerRadius = UDim.new(0, 8)
			headerCorner.Parent = header

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, 0, 1, 0)
			title.BackgroundTransparency = 1
			title.Text = "[ FLY V3 ]"
			title.TextColor3 = Color3.new(1, 1, 1)
			title.Font = Enum.Font.GothamBold
			title.TextSize = 16
			title.Parent = header

			-- Body
			local body = Instance.new("Frame")
			body.Size = UDim2.new(1, -20, 1, -46)
			body.Position = UDim2.new(0, 10, 0, 41)
			body.BackgroundTransparency = 1
			body.Parent = flyGui

			-- Speed Control
			local speedRow = Instance.new("Frame")
			speedRow.Size = UDim2.new(1, 0, 0, 40)
			speedRow.BackgroundTransparency = 1
			speedRow.Parent = body

			-- Tombol Minus
			local minusBtn = Instance.new("TextButton")
			minusBtn.Size = UDim2.new(0, 40, 0, 40)
			minusBtn.Position = UDim2.new(0, 0, 0, 0)
			minusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			minusBtn.BorderSizePixel = 0
			minusBtn.Text = "-"
			minusBtn.TextColor3 = Color3.new(1, 1, 1)
			minusBtn.Font = Enum.Font.GothamBold
			minusBtn.TextSize = 24
			minusBtn.Parent = speedRow

			local minusCorner = Instance.new("UICorner")
			minusCorner.CornerRadius = UDim.new(0, 6)
			minusCorner.Parent = minusBtn

			-- Label Speed
			local speedLabel = Instance.new("TextLabel")
			speedLabel.Size = UDim2.new(0, 80, 0, 40)
			speedLabel.Position = UDim2.new(0.5, -40, 0, 0)
			speedLabel.BackgroundTransparency = 1
			speedLabel.Text = tostring(flySpeed)
			speedLabel.TextColor3 = Color3.new(1, 1, 1)
			speedLabel.Font = Enum.Font.GothamBold
			speedLabel.TextSize = 28
			speedLabel.Parent = speedRow

			-- Tombol Plus
			local plusBtn = Instance.new("TextButton")
			plusBtn.Size = UDim2.new(0, 40, 0, 40)
			plusBtn.Position = UDim2.new(1, -40, 0, 0)
			plusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			plusBtn.BorderSizePixel = 0
			plusBtn.Text = "+"
			plusBtn.TextColor3 = Color3.new(1, 1, 1)
			plusBtn.Font = Enum.Font.GothamBold
			plusBtn.TextSize = 24
			plusBtn.Parent = speedRow

			local plusCorner = Instance.new("UICorner")
			plusCorner.CornerRadius = UDim.new(0, 6)
			plusCorner.Parent = plusBtn

			-- Tombol FLY (INI YANG HILANG!)
			local flyBtn = Instance.new("TextButton")
			flyBtn.Size = UDim2.new(1, 0, 0, 40)
			flyBtn.Position = UDim2.new(0, 0, 1, -40)
			flyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
			flyBtn.BorderSizePixel = 0
			flyBtn.Text = "FLY"
			flyBtn.TextColor3 = Color3.new(1, 1, 1)
			flyBtn.Font = Enum.Font.GothamBold
			flyBtn.TextSize = 16
			flyBtn.Parent = body

			local flyBtnCorner = Instance.new("UICorner")
			flyBtnCorner.CornerRadius = UDim.new(0, 6)
			flyBtnCorner.Parent = flyBtn

			-- Update label
			local function updateDisplay()
				speedLabel.Text = tostring(flySpeed)
			end

			-- Logic Minus
			minusBtn.MouseButton1Click:Connect(function()
				if flySpeed > 1 then
					flySpeed = flySpeed - 1
					updateDisplay()
					-- Visual feedback
					TweenService:Create(minusBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
					task.delay(0.1, function()
						TweenService:Create(minusBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
					end)
				end
			end)

			-- Logic Plus
			plusBtn.MouseButton1Click:Connect(function()
				if flySpeed < 255 then
					flySpeed = flySpeed + 1
					updateDisplay()
					-- Visual feedback
					TweenService:Create(plusBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
					task.delay(0.1, function()
						TweenService:Create(plusBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
					end)
				end
			end)

			-- Logic FLY Toggle
			flyBtn.MouseButton1Click:Connect(function()
				isFlying = not isFlying
				
				if isFlying then
					flyBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
					flyBtn.Text = "STOP"
					
					local char = player.Character
					if not char then isFlying = false; return end
					local root = char:FindFirstChild("HumanoidRootPart")
					if not root then isFlying = false; return end

					flyBodyVelocity = Instance.new("BodyVelocity")
					flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
					flyBodyVelocity.P = 1250
					flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
					flyBodyVelocity.Parent = root

					flyConnection = RunService.Heartbeat:Connect(function()
						if not isFlying or not char or not char.Parent then
							if flyConnection then flyConnection:Disconnect() end
							if flyBodyVelocity then flyBodyVelocity:Destroy() end
							flyConnection = nil
							flyBodyVelocity = nil
							return
						end
						
						local camera = workspace.CurrentCamera
						local move = Vector3.new(0, 0, 0)
						
						if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
						if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
						if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
						if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
						if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
						if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0, -1, 0) end

						if move.Magnitude > 0 then
							move = move.Unit * (flySpeed * 16)
						end
						flyBodyVelocity.Velocity = move
					end)

					-- Handle death
					if char:FindFirstChild("Humanoid") then
						char.Humanoid.Died:Connect(function()
							if isFlying then
								isFlying = false
								if flyConnection then flyConnection:Disconnect() end
								if flyBodyVelocity then flyBodyVelocity:Destroy() end
								flyConnection = nil
								flyBodyVelocity = nil
								if flyGui then
									local btn = flyGui:FindFirstChild("FlyBtn", true)
									if btn then
										btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
										btn.Text = "FLY"
									end
								end
							end
						end)
					end
				else
					flyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
					flyBtn.Text = "FLY"
					if flyConnection then flyConnection:Disconnect() end
					if flyBodyVelocity then flyBodyVelocity:Destroy() end
					flyConnection = nil
					flyBodyVelocity = nil
				end
			end)
		end

		-- ========== MAIN MENU (STYLE BARU) ==========
		local mainFrame = nil

		local function createMainMenu()
			if mainFrame then mainFrame:Destroy() end

			mainFrame = Instance.new("Frame")
			mainFrame.Name = "MainMenu"
			mainFrame.Size = UDim2.new(0, 300, 0, 0)
			mainFrame.Position = UDim2.new(0.5, -150, 0.5, -120)
			mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			mainFrame.BorderSizePixel = 0
			mainFrame.ClipsDescendants = true
			mainFrame.Parent = screenGui
			makeDraggable(mainFrame)

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = mainFrame

			-- Header (Minimalis seperti gambar 2)
			local header = Instance.new("Frame")
			header.Name = "Header"
			header.Size = UDim2.new(1, 0, 0, 38)
			header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			header.BorderSizePixel = 0
			header.Parent = mainFrame
			makeDraggable(mainFrame, header)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, -70, 1, 0)
			title.Position = UDim2.new(0, 12, 0, 0)
			title.BackgroundTransparency = 1
			title.Text = "Kecepatan Control By Azka"
			title.TextColor3 = Color3.new(1, 1, 1)
			title.Font = Enum.Font.GothamBold
			title.TextSize = 15
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = header

			-- Tombol Minimize (-)
			local minBtn = Instance.new("TextButton")
			minBtn.Size = UDim2.new(0, 30, 0, 30)
			minBtn.Position = UDim2.new(1, -62, 0.5, -15)
			minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			minBtn.BorderSizePixel = 0
			minBtn.Text = "-"
			minBtn.TextColor3 = Color3.new(1, 1, 1)
			minBtn.Font = Enum.Font.GothamBold
			minBtn.TextSize = 18
			minBtn.Parent = header

			local minCorner = Instance.new("UICorner")
			minCorner.CornerRadius = UDim.new(0, 4)
			minCorner.Parent = minBtn

			-- Tombol Close (X)
			local closeBtn = Instance.new("TextButton")
			closeBtn.Size = UDim2.new(0, 30, 0, 30)
			closeBtn.Position = UDim2.new(1, -32, 0.5, -15)
			closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
			closeBtn.BorderSizePixel = 0
			closeBtn.Text = "X"
			closeBtn.TextColor3 = Color3.new(1, 1, 1)
			closeBtn.Font = Enum.Font.GothamBold
			closeBtn.TextSize = 14
			closeBtn.Parent = header

			local closeCorner = Instance.new("UICorner")
			closeCorner.CornerRadius = UDim.new(0, 4)
			closeCorner.Parent = closeBtn

			closeBtn.MouseButton1Click:Connect(function()
				mainFrame.Visible = false
			end)

			minBtn.MouseButton1Click:Connect(function()
				mainFrame.Visible = false
			end)

			-- Content
			local content = Instance.new("Frame")
			content.Name = "Content"
			content.Size = UDim2.new(1, -20, 0, 0)
			content.Position = UDim2.new(0, 10, 0, 48)
			content.BackgroundTransparency = 1
			content.Parent = mainFrame

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 10)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = content

			-- Walkspeed Section
			local wsLabel = Instance.new("TextLabel")
			wsLabel.Size = UDim2.new(1, 0, 0, 18)
			wsLabel.BackgroundTransparency = 1
			wsLabel.Text = "Walkspeed"
			wsLabel.TextColor3 = Color3.new(1, 1, 1)
			wsLabel.Font = Enum.Font.GothamBold
			wsLabel.TextSize = 14
			wsLabel.TextXAlignment = Enum.TextXAlignment.Left
			wsLabel.LayoutOrder = 1
			wsLabel.Parent = content

			local wsSlider = createSlider(content, 1, 500, lastWalkSpeed, function(val)
				lastWalkSpeed = val
				local char = player.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then hum.WalkSpeed = val end
				end
			end)
			wsSlider.LayoutOrder = 2

			-- Divider
			local divider = Instance.new("Frame")
			divider.Size = UDim2.new(1, 0, 0, 1)
			divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			divider.BorderSizePixel = 0
			divider.LayoutOrder = 3
			divider.Parent = content

			-- General Label
			local genLabel = Instance.new("TextLabel")
			genLabel.Size = UDim2.new(1, 0, 0, 18)
			genLabel.BackgroundTransparency = 1
			genLabel.Text = "General"
			genLabel.TextColor3 = Color3.new(1, 1, 1)
			genLabel.Font = Enum.Font.GothamBold
			textSize = 14
			genLabel.TextXAlignment = Enum.TextXAlignment.Left
			genLabel.LayoutOrder = 4
			genLabel.Parent = content

			-- No Clip Row (Switch di kanan)
			local noclipRow = Instance.new("Frame")
			noclipRow.Size = UDim2.new(1, 0, 0, 28)
			noclipRow.BackgroundTransparency = 1
			noclipRow.LayoutOrder = 5
			noclipRow.Parent = content

			local noclipText = Instance.new("TextLabel")
			noclipText.Size = UDim2.new(1, -60, 1, 0)
			noclipText.BackgroundTransparency = 1
			noclipText.Text = "No Clip"
			noclipText.TextColor3 = Color3.new(1, 1, 1)
			noclipText.Font = Enum.Font.Gotham
			noclipText.TextSize = 14
			noclipText.TextXAlignment = Enum.TextXAlignment.Left
			noclipText.Parent = noclipRow

			local noclipSwitch = createModernSwitch(noclipRow, false, function(state)
				noclipEnabled = state
				if state then
					noclipConnection = RunService.Stepped:Connect(function()
						if not noclipEnabled then return end
						local char = player.Character
						if char then
							for _, part in pairs(char:GetDescendants()) do
								if part:IsA("BasePart") then
									part.CanCollide = false
								end
							end
						end
					end)
				else
					if noclipConnection then noclipConnection:Disconnect() end
				end
			end)
			noclipSwitch.Position = UDim2.new(1, -44, 0.5, -12)

			-- Inf Jump Row (Switch di kanan)
			local infRow = Instance.new("Frame")
			infRow.Size = UDim2.new(1, 0, 0, 28)
			infRow.BackgroundTransparency = 1
			infRow.LayoutOrder = 6
			infRow.Parent = content

			local infText = Instance.new("TextLabel")
			infText.Size = UDim2.new(1, -60, 1, 0)
			infText.BackgroundTransparency = 1
			infText.Text = "Inf Jump"
			infText.TextColor3 = Color3.new(1, 1, 1)
			infText.Font = Enum.Font.Gotham
			infText.TextSize = 14
			infText.TextXAlignment = Enum.TextXAlignment.Left
			infText.Parent = infRow

			local infSwitch = createModernSwitch(infRow, false, function(state)
				infJumpEnabled = state
				if state then
					infJumpConnection = UserInputService.JumpRequest:Connect(function()
						if infJumpEnabled then
							local char = player.Character
							if char then
								local hum = char:FindFirstChildOfClass("Humanoid")
								if hum then
									hum:ChangeState(Enum.HumanoidStateType.Jumping)
								end
							end
						end
					end)
				else
					if infJumpConnection then infJumpConnection:Disconnect() end
				end
			end)
			infSwitch.Position = UDim2.new(1, -44, 0.5, -12)

			-- Fly V3 Row (Switch di kanan)
			local flyRow = Instance.new("Frame")
			flyRow.Size = UDim2.new(1, 0, 0, 28)
			flyRow.BackgroundTransparency = 1
			flyRow.LayoutOrder = 7
			flyRow.Parent = content

			local flyText = Instance.new("TextLabel")
			flyText.Size = UDim2.new(1, -60, 1, 0)
			flyText.BackgroundTransparency = 1
			flyText.Text = "Fly V3"
			flyText.TextColor3 = Color3.new(1, 1, 1)
			flyText.Font = Enum.Font.Gotham
			flyText.TextSize = 14
			flyText.TextXAlignment = Enum.TextXAlignment.Left
			flyText.Parent = flyRow

			local flySwitch = createModernSwitch(flyRow, false, function(state)
				flyEnabled = state
				if state then
					createFlyMenu()
				else
					if flyGui then flyGui:Destroy() end
					if flyConnection then flyConnection:Disconnect() end
					if flyBodyVelocity then flyBodyVelocity:Destroy() end
					flyConnection = nil
					flyBodyVelocity = nil
					isFlying = false
				end
			end)
			flySwitch.Position = UDim2.new(1, -44, 0.5, -12)

			-- Update size
			task.wait()
			local contentHeight = layout.AbsoluteContentSize.Y
			content.Size = UDim2.new(1, -20, 0, contentHeight)
			mainFrame.Size = UDim2.new(0, 300, 0, contentHeight + 58)
		end

		-- ========== TOMBOL BULAT (1.5x LEBIH BESAR = 38x38) ==========
		local mainButton = Instance.new("TextButton")
		mainButton.Name = "MainButton"
		mainButton.Size = UDim2.new(0, 38, 0, 38) -- 25 * 1.5 = 37.5 → 38
		mainButton.Position = UDim2.new(0, 15, 0.5, -19)
		mainButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		mainButton.BorderSizePixel = 0
		mainButton.Text = "👟"
		mainButton.TextColor3 = Color3.new(1, 1, 1)
		mainButton.Font = Enum.Font.GothamBold
		mainButton.TextSize = 20
		mainButton.Parent = screenGui
		makeDraggable(mainButton)

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(1, 0)
		btnCorner.Parent = mainButton

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Color3.fromRGB(0, 120, 255)
		btnStroke.Thickness = 2
		btnStroke.Parent = mainButton

		mainButton.MouseEnter:Connect(function()
			TweenService:Create(mainButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 255)}):Play()
		end)

		mainButton.MouseLeave:Connect(function()
			TweenService:Create(mainButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
		end)

		mainButton.MouseButton1Click:Connect(function()
			if not mainFrame or not mainFrame.Parent then
				createMainMenu()
			else
				mainFrame.Visible = not mainFrame.Visible
				if mainFrame.Visible then
					-- Recalculate height
					local content = mainFrame:FindFirstChild("Content")
					if content then
						local layout = content:FindFirstChildOfClass("UIListLayout")
						if layout then
							local contentHeight = layout.AbsoluteContentSize.Y
							content.Size = UDim2.new(1, -20, 0, contentHeight)
							mainFrame.Size = UDim2.new(0, 300, 0, contentHeight + 58)
						end
					end
				end
			end
		end)

		-- ========== CHARACTER HANDLING ==========
		local function onCharacterAdded(char)
			local hum = char:WaitForChild("Humanoid")
			hum.WalkSpeed = lastWalkSpeed
			
			if flyEnabled then
				task.wait(0.5)
				createFlyMenu()
			end
		end

		player.CharacterAdded:Connect(onCharacterAdded)
		if player.Character then
			onCharacterAdded(player.Character)
		end

		-- ========== CLEANUP ==========
		screenGui.Destroying:Connect(function()
			_G.SpeedControlLoaded = nil
			if flyConnection then flyConnection:Disconnect() end
			if noclipConnection then noclipConnection:Disconnect() end
			if infJumpConnection then infJumpConnection:Disconnect() end
		end)

		-- ========== FINISH ==========
		TweenService:Create(loadingText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
		TweenService:Create(blackFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
		task.wait(0.5)
		loadingGui:Destroy()
		
		print("✅ Speed Control By Azka loaded!")
	end)

	if not success then
		warn("⚠️ Error: " .. tostring(err))
	end
end)
