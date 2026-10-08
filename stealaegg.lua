local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "StealEggScanner"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.8, 0)
frame.Position = UDim2.new(0.05, 0, 0.1, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "Steal an Egg - Prompt Scanner"
title.TextScaled = true
title.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.45, 0, 0, 40)
copyButton.Position = UDim2.new(0.025, 0, 0, 50)
copyButton.Text = "COPY ALL"
copyButton.TextScaled = true
copyButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.45, 0, 0, 40)
closeButton.Position = UDim2.new(0.525, 0, 0, 50)
closeButton.Text = "CLOSE"
closeButton.TextScaled = true
closeButton.Parent = frame

local output = Instance.new("TextBox")
output.Position = UDim2.new(0.025, 0, 0, 100)
output.Size = UDim2.new(0.95, 0, 0.85, 0)
output.MultiLine = true
output.ClearTextOnFocus = false
output.TextEditable = true
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.TextWrapped = false
output.TextSize = 14
output.Text = "Scanning..."
output.Parent = frame

local results = {}

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("ProximityPrompt") then
		local parent = obj.Parent

		table.insert(results,
			"PROMPT: " .. obj.Name ..
			"\nPARENT: " .. (parent and parent:GetFullName() or "nil") ..
			"\nACTION: " .. obj.ActionText ..
			"\nOBJECT: " .. obj.ObjectText ..
			"\nENABLED: " .. tostring(obj.Enabled) ..
			"\n------------------------------"
		)
	end
end

local fullText =
	"FOUND " .. #results .. " PROXIMITYPROMPT(S)\n\n" ..
	table.concat(results, "\n")

output.Text = fullText

copyButton.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(fullText)
		copyButton.Text = "COPIED!"
		task.wait(1.5)
		copyButton.Text = "COPY ALL"
	else
		copyButton.Text = "SELECT TEXT & COPY"
		task.wait(1.5)
		copyButton.Text = "COPY ALL"
	end
end)

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
