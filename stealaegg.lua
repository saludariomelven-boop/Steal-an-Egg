local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "EggScanner"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.75, 0)
frame.Position = UDim2.new(0.05, 0, 0.12, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Steal an Egg - Relevant Prompts"
title.TextScaled = true
title.Parent = frame

local copy = Instance.new("TextButton")
copy.Size = UDim2.new(0.45, 0, 0, 40)
copy.Position = UDim2.new(0.025, 0, 0, 48)
copy.Text = "COPY RESULTS"
copy.TextScaled = true
copy.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0.45, 0, 0, 40)
close.Position = UDim2.new(0.525, 0, 0, 48)
close.Text = "CLOSE"
close.TextScaled = true
close.Parent = frame

local box = Instance.new("TextBox")
box.Position = UDim2.new(0.025, 0, 0, 98)
box.Size = UDim2.new(0.95, 0, 0.84, 0)
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = true
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextWrapped = false
box.TextSize = 14
box.Parent = frame

local results = {}

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("ProximityPrompt") then

		local searchText = (
			obj.Name .. " " ..
			obj.ActionText .. " " ..
			obj.ObjectText .. " " ..
			obj.Parent.Name
		):lower()

		if searchText:find("egg")
		or searchText:find("steal")
		or searchText:find("claim")
		or searchText:find("deposit")
		or searchText:find("pen")
		or searchText:find("base")
		or searchText:find("carry") then

			table.insert(results,
				"NAME: " .. obj.Name ..
				"\nACTION: " .. obj.ActionText ..
				"\nOBJECT: " .. obj.ObjectText ..
				"\nPATH: " .. obj:GetFullName() ..
				"\n--------------------------"
			)
		end
	end
end

local resultText =
	"FOUND " .. #results .. " RELEVANT PROMPTS\n\n" ..
	table.concat(results, "\n")

box.Text = resultText

-- Try the clipboard functions supported by different environments.
local function copyToClipboard(text)
	if typeof(setclipboard) == "function" then
		setclipboard(text)
		return true
	end

	if typeof(toclipboard) == "function" then
		toclipboard(text)
		return true
	end

	if typeof(set_clipboard) == "function" then
		set_clipboard(text)
		return true
	end

	return false
end

copy.MouseButton1Click:Connect(function()
	local success = pcall(function()
		return copyToClipboard(resultText)
	end)

	if success then
		copy.Text = "COPIED!"
	else
		copy.Text = "SELECT TEXT + COPY"
	end

	task.wait(2)
	copy.Text = "COPY RESULTS"
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
