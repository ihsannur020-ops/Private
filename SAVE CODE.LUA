INSTANT PROXIMITY
=================================================================
-- Instant Proximity: perbaikan agar langsung mati saat OFF
local function setProxEnabled(state)
    proxEnabled = state
    if state then
        -- Set semua yang sudah ada
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end
        -- Pantau yang baru
        local conn = workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0
            end
        end)
        table.insert(proxConnections, conn)
        print("[Instant Proximity] Activated")
    else
        -- Putuskan semua koneksi
        for _, conn in ipairs(proxConnections) do
            conn:Disconnect()
        end
        proxConnections = {}
=============================================
DRAG
-- ===========================================
-- FUNGSIONALITAS DRAG (header bisa digerakkan)
-- ===========================================
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

header.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
