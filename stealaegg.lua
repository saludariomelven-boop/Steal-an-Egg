local Players = game:GetService("Players")
local player = Players.LocalPlayer

local results = {}

local function valueString(v)
    if typeof(v) == "Instance" then
        return v:GetFullName()
    end
    return tostring(v)
end

local function add(text)
    table.insert(results, text)
    print(text)
end

local function dumpObject(obj)
    add("========================================")
    add("OBJECT: " .. obj:GetFullName())
    add("CLASS: " .. obj.ClassName)

    add("--- ATTRIBUTES ---")

    for name, value in pairs(obj:GetAttributes()) do
        add(name .. " = " .. valueString(value))
    end

    add("--- VALUES ---")

    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("NumberValue")
            or child:IsA("IntValue")
            or child:IsA("StringValue")
            or child:IsA("BoolValue") then

            add(
                child.ClassName ..
                " " ..
                child:GetFullName() ..
                " = " ..
                valueString(child.Value)
            )
        end
    end
end

add("========== STEAL AN EGG FORENSIC SCAN ==========")

local count = 0

for _, obj in ipairs(workspace:GetDescendants()) do

    if obj:IsA("ProximityPrompt") then

        local action = string.lower(obj.ActionText or "")
        local objectText = string.lower(obj.ObjectText or "")

        if obj.Name == "CarryAreaEgg"
            or (action == "steal" and string.find(objectText, "egg", 1, true)) then

            count += 1

            add("")
            add("EGG #" .. count)

            add("Prompt: " .. obj:GetFullName())
            add("ActionText: " .. obj.ActionText)
            add("ObjectText: " .. obj.ObjectText)
            add("HoldDuration: " .. tostring(obj.HoldDuration))
            add("MaxActivationDistance: " .. tostring(obj.MaxActivationDistance))
            add("Enabled: " .. tostring(obj.Enabled))

            dumpObject(obj)

            local p = obj.Parent

            for i = 1, 5 do

                if not p then
                    break
                end

                add(
                    "ANCESTOR " ..
                    i ..
                    ": " ..
                    p:GetFullName() ..
                    " [" ..
                    p.ClassName ..
                    "]"
                )

                for name, value in pairs(p:GetAttributes()) do
                    add(
                        "  ATTRIBUTE: " ..
                        name ..
                        " = " ..
                        valueString(value)
                    )
                end

                p = p.Parent
            end
        end
    end
end

add("")
add("========== TOTAL EGGS: " .. count .. " ==========")

--==================================================
-- COPY GUI
--==================================================

local PlayerGui = player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("EggScannerCopy")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "EggScannerCopy"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 125)
frame.Position = UDim2.new(0.5, -150, 0.12, 0)
frame.BackgroundTransparency = 0.1
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "EGG FORENSIC SCANNER"
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 25)
info.Position = UDim2.new(0, 10, 0, 43)
info.BackgroundTransparency = 1
info.Text = "Found " .. count .. " egg prompts"
info.TextSize = 13
info.Font = Enum.Font.Gotham
info.TextColor3 = Color3.new(1, 1, 1)
info.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 180, 0, 40)
copyButton.Position = UDim2.new(0.5, -90, 1, -48)
copyButton.Text = "COPY RESULTS"
copyButton.TextSize = 15
copyButton.Font = Enum.Font.GothamBold
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = copyButton

copyButton.Activated:Connect(function()

    local finalText = table.concat(results, "\n")

    local copied = false

    -- Executor clipboard support
    if typeof(setclipboard) == "function" then
        copied = pcall(function()
            setclipboard(finalText)
        end)
    elseif typeof(toclipboard) == "function" then
        copied = pcall(function()
            toclipboard(finalText)
        end)
    end

    if copied then
        copyButton.Text = "COPIED!"
        task.wait(1.5)
        copyButton.Text = "COPY RESULTS"
    else
        copyButton.Text = "COPY NOT SUPPORTED"
        task.wait(1.5)
        copyButton.Text = "COPY RESULTS"
    end
end)

print("")
print("========== SCAN COMPLETE ==========")
print("TOTAL EGGS:", count)
print("Use the COPY RESULTS button to copy everything.")
