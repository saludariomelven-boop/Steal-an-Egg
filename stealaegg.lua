--==================================================
-- STEAL AN EGG - OBSERVER V5
-- READ ONLY
-- EVENT DRIVEN
-- COMPACT CLIPBOARD OUTPUT
--==================================================

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local results = {}
local seen = {}

local MAX_OUTPUT = 8000
local MAX_EVENTS = 120

--==================================================
-- OUTPUT
--==================================================

local function add(text)
    text = tostring(text)

    local current = table.concat(results, "\n")

    if #current + #text + 1 <= MAX_OUTPUT then
        table.insert(results, text)
        print(text)
    end
end

local function unique(text)
    if not seen[text] then
        seen[text] = true
        add(text)
    end
end

local function clean(text)
    text = tostring(text or "")
    text = string.gsub(text, "\n", " ")
    text = string.gsub(text, "%s+", " ")

    if #text > 180 then
        text = string.sub(text, 1, 180) .. "..."
    end

    return text
end

local function interesting(text)
    text = string.lower(tostring(text or ""))

    local words = {
        "egg",
        "kg",
        "common",
        "uncommon",
        "rare",
        "epic",
        "legendary",
        "mythic",
        "cosmic",
        "secret",
        "eternal",
        "mutation",
        "mutated",
        "value",
        "worth",
        "price",
        "sell",
        "carry",
        "steal",
        "return",
        "deposit",
        "place"
    }

    for _, word in ipairs(words) do
        if string.find(text, word, 1, true) then
            return true
        end
    end

    return false
end

--==================================================
-- HEADER
--==================================================

add("========================================")
add("STEAL AN EGG - OBSERVER V5")
add("PLAYER=" .. player.Name)
add("READ ONLY")
add("========================================")

--==================================================
-- TARGET UI OBJECTS
--==================================================

local watchedRoots = {
    "AssetEggData",
    "AssetHoverData",
    "BackpackGui",
    "AreaGui",
    "AutoSell"
}

local watched = {}
local connections = {}

local function registerObject(obj)

    if watched[obj] then
        return
    end

    watched[obj] = true

    if obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox") then

        local function capture()

            local text = clean(obj.Text)

            if text ~= "" and interesting(text) then

                unique(
                    "TEXT|" ..
                    obj:GetFullName() ..
                    "|" ..
                    text
                )
            end
        end

        capture()

        local connection = obj:GetPropertyChangedSignal("Text")
            :Connect(capture)

        table.insert(connections, connection)
    end
end

local function scanRoot(root)

    if not root then
        return
    end

    registerObject(root)

    for _, obj in ipairs(root:GetDescendants()) do
        registerObject(obj)
    end
end

for _, rootName in ipairs(watchedRoots) do
    local root = PlayerGui:FindFirstChild(rootName, true)

    if root then
        add("WATCH|" .. root:GetFullName())
        scanRoot(root)
    else
        add("MISSING|" .. rootName)
    end
end

--==================================================
-- DYNAMIC GUI OBJECTS
--==================================================

local childConnection = PlayerGui.DescendantAdded:Connect(function(obj)

    local fullName = obj:GetFullName()
    local lowerName = string.lower(fullName)

    for _, rootName in ipairs(watchedRoots) do

        if string.find(
            lowerName,
            string.lower(rootName),
            1,
            true
        ) then

            registerObject(obj)
            break
        end
    end
end)

table.insert(connections, childConnection)

--==================================================
-- PROMPT OBSERVER
--==================================================

local promptConnection =
    ProximityPromptService.PromptShown:Connect(
        function(prompt)

            local text =
                tostring(prompt.Name) ..
                " " ..
                tostring(prompt.ActionText) ..
                " " ..
                tostring(prompt.ObjectText)

            if interesting(text) then

                unique(
                    "PROMPT|" ..
                    prompt:GetFullName() ..
                    "|" ..
                    tostring(prompt.ActionText) ..
                    "|" ..
                    tostring(prompt.ObjectText) ..
                    "|E=" ..
                    tostring(prompt.Enabled) ..
                    "|H=" ..
                    tostring(prompt.HoldDuration) ..
                    "|D=" ..
                    tostring(prompt.MaxActivationDistance)
                )
            end
        end
    )

table.insert(connections, promptConnection)

--==================================================
-- CHARACTER OBSERVER
--==================================================

local function observeCharacter(character)

    if not character then
        return
    end

    add("CHARACTER|" .. character:GetFullName())

    for _, obj in ipairs(character:GetDescendants()) do

        if obj:IsA("Tool")
            or obj:IsA("StringValue")
            or obj:IsA("NumberValue")
            or obj:IsA("IntValue")
            or obj:IsA("BoolValue") then

            local line =
                "CHAR|" ..
                obj:GetFullName()

            if obj:IsA("StringValue")
                or obj:IsA("NumberValue")
                or obj:IsA("IntValue")
                or obj:IsA("BoolValue") then

                line =
                    line ..
                    "|VALUE=" ..
                    tostring(obj.Value)
            end

            unique(line)
        end
    end
end

observeCharacter(player.Character)

local characterConnection =
    player.CharacterAdded:Connect(observeCharacter)

table.insert(connections, characterConnection)

--==================================================
-- COUNTDOWN GUI
--==================================================

local old = PlayerGui:FindFirstChild("EggObserverV5")

if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "EggObserverV5"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 190)
frame.Position = UDim2.new(0.5, -160, 0.08, 0)
frame.BackgroundTransparency = 0.08
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "EGG OBSERVER V5"
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 55)
status.Position = UDim2.new(0, 10, 0, 45)
status.BackgroundTransparency = 1
status.Text = "Watching egg / hover / backpack data..."
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.TextWrapped = true
status.TextColor3 = Color3.new(1,1,1)
status.Parent = frame

local copy = Instance.new("TextButton")
copy.Size = UDim2.new(0, 215, 0, 45)
copy.Position = UDim2.new(0.5, -107, 1, -58)
copy.Text = "COPY ALL RESULTS"
copy.TextSize = 15
copy.Font = Enum.Font.GothamBold
copy.TextColor3 = Color3.new(1,1,1)
copy.Parent = frame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copy

--==================================================
-- OBSERVE FOR 15 SECONDS
--==================================================

for remaining = 15, 1, -1 do

    status.Text =
        "Watching for UI/state changes...\n" ..
        "Time remaining: " ..
        tostring(remaining) ..
        "s"

    task.wait(1)
end

--==================================================
-- STOP
--==================================================

for _, connection in ipairs(connections) do

    pcall(function()
        connection:Disconnect()
    end)
end

add("")
add("========================================")
add("OBSERVATION COMPLETE")
add("EVENTS=" .. tostring(#results))
add("========================================")

status.Text =
    "Observation complete.\n" ..
    "Captured: " ..
    tostring(#results) ..
    " records."

--==================================================
-- COPY
--==================================================

copy.Activated:Connect(function()

    local text = table.concat(results, "\n")
    local success = false

    if typeof(setclipboard) == "function" then

        success = pcall(function()
            setclipboard(text)
        end)

    elseif typeof(toclipboard) == "function" then

        success = pcall(function()
            toclipboard(text)
        end)
    end

    if success then

        copy.Text = "COPIED!"
        task.wait(1.5)
        copy.Text = "COPY ALL RESULTS"

    else

        copy.Text = "CLIPBOARD FAILED"
        task.wait(1.5)
        copy.Text = "COPY ALL RESULTS"

    end
end)

print("========================================")
print("V5 COMPLETE")
print("Tap COPY ALL RESULTS")
print("========================================")
