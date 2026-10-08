print("STEAL AN EGG LOADER WORKED!")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

warn("Loaded for: " .. player.Name)

pcall(function()
    game:GetService("StarterGui"):SetCore(
        "SendNotification",
        {
            Title = "Steal an Egg",
            Text = "Test script loaded successfully!",
            Duration = 5
        }
    )
end)
