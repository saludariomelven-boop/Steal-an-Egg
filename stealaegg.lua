local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "StealEggTester"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 300)
frame.Position = UDim2.new(0.5, -210, 0.2, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Steal an Egg - Interaction Scanner"
title.TextScaled = true
title.Parent = frame

local output = Instance.new("TextLabel")
output.Position = UDim2.new(0, 10, 0, 50)
output.Size = UDim2.new(1, -20, 1, -60)
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.TextWrapped = true
output.TextSize = 16
output.Text = "Scanning..."
output.Parent = frame

local found = {}

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        local parent = obj.Parent

        table.insert(found,
            "PROMPT: " ..
            obj.Name ..
            " | Parent: " ..
            (parent and parent:GetFullName() or "nil") ..
            " | Action: " ..
            obj.ActionText ..
            " | Object: " ..
            obj.ObjectText
        )
    end
end

output.Text =
    "Found " .. #found .. " ProximityPrompt(s)\n\n" ..
    table.concat(found, "\n")
