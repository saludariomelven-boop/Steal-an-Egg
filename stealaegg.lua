local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "StealEggLoaderTest"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 360, 0, 80)
label.Position = UDim2.new(0.5, -180, 0.15, 0)
label.BackgroundTransparency = 0.15
label.TextScaled = true
label.Text = "STEAL AN EGG LOADER WORKED!"
label.Parent = gui
