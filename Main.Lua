-- ==================================================
-- 10. DRAG HEADER (VERSI ROBUST, TIDAK ERROR)
-- ==================================================
local dragging = false
local dragStart, startPos

-- Mulai drag saat header diklik (selain tombol minimize/close)
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = input.Target
        if target ~= minimizeBtn and target ~= closeBtn then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end
end)

-- Update posisi GUI selama drag
userInput.InputChanged:Connect(function(input)
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

-- Hentikan drag saat tombol mouse dilepas (di mana pun)
userInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
