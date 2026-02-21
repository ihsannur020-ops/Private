UI.AddSlider({
    Text = "Walkspeed",
    Min = 16,
    Max = 300,
    Default = 16,
    LeftMargin = 80,   -- geser lebih kanan
    Callback = function(value)
        local character = localPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = value
        end
    end
})

UI.AddSlider({
    Text = "Jump Power",
    Min = 5,
    Max = 150,
    Default = 5,
    LeftMargin = 80,
    Callback = function(value)
        local character = localPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = value
        end
    end
})
