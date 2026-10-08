--==================================================
-- STEAL AN EGG - FORENSIC SCANNER V2
-- READ ONLY
--==================================================

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local results = {}

local function add(text)
    table.insert(results, tostring(text))
    print(text)
end

local function safeValue(v)
    if typeof(v) == "string" then
        return v
    end

    if typeof(v) == "Instance" then
        return v:GetFullName()
    end

    return tostring(v)
end

local function dumpMetadata(obj, indent)
    indent = indent or ""

    local attrs = obj:GetAttributes()

    for name, value in pairs(attrs) do
        add(
            indent ..
            "ATTRIBUTE " ..
            name ..
            " = " ..
            safeValue(value)
        )
    end

    local tags = obj:GetTags()

    if #tags > 0 then
        add(
            indent ..
            "TAGS = " ..
            table.concat(tags, ", ")
        )
    end

    for _, child in ipairs(obj:GetChildren()) do

        if child:IsA("NumberValue")
            or child:IsA("IntValue")
            or child:IsA("StringValue")
            or child:IsA("BoolValue") then

            add(
                indent ..
                "VALUE " ..
                child.ClassName ..
                " " ..
                child.Name ..
                " = " ..
                safeValue(child.Value)
            )
        end
    end
end

local function looksInteresting(name)

    name = string.lower(name)

    local words = {
        "egg",
        "steal",
        "carry",
        "deposit",
        "place",
        "return",
        "drop",
        "pet",
        "rarity",
        "mutation",
        "worth",
        "value",
        "price",
        "base",
        "plot",
        "pen"
    }

    for _, word in ipairs(words) do
        if string.find(name, word, 1, true) then
            return true
        end
    end

    return false
end

add("========================================")
add("STEAL AN EGG FORENSIC SCAN V2")
add("READ ONLY")
add("========================================")

--==================================================
-- 1. ACTIVE STEAL PROMPTS
--==================================================

add("")
add("========== ACTIVE STEAL PROMPTS ==========")

local activeCount = 0

for _, obj in ipairs(workspace:GetDescendants()) do

    if obj:IsA("ProximityPrompt") then

        local action = string.lower(obj.ActionText or "")
        local objectText = string.lower(obj.ObjectText or "")

        if obj.Enabled
            and (
                obj.Name == "CarryAreaEgg"
                or (
                    action == "steal"
                    and string.find(objectText, "egg", 1, true)
                )
            ) then

            activeCount += 1

            add("")
            add("ACTIVE PROMPT #" .. activeCount)
            add("PATH: " .. obj:GetFullName())
            add("PARENT: " .. obj.Parent:GetFullName())
            add("ACTION: " .. obj.ActionText)
            add("OBJECT: " .. obj.ObjectText)
            add("HOLD: " .. tostring(obj.HoldDuration))
            add("DISTANCE: " .. tostring(obj.MaxActivationDistance))

            dumpMetadata(obj, "  ")
            dumpMetadata(obj.Parent, "  ")
        end
    end
end

add("")
add("ACTIVE STEAL PROMPTS FOUND: " .. activeCount)

--==================================================
-- 2. EGG-LIKE OBJECTS IN WORKSPACE
--==================================================

add("")
add("========== WORKSPACE EGG OBJECTS ==========")

local eggCount = 0

for _, obj in ipairs(workspace:GetDescendants()) do

    if looksInteresting(obj.Name) then

        if obj:IsA("Model")
            or obj:IsA("Folder")
            or obj:IsA("BasePart")
            or obj:IsA("Attachment") then

            eggCount += 1

            if eggCount <= 150 then

                add("")
                add("OBJECT #" .. eggCount)
                add("NAME: " .. obj.Name)
                add("CLASS: " .. obj.ClassName)
                add("PATH: " .. obj:GetFullName())

                dumpMetadata(obj, "  ")
            end
        end
    end
end

add("")
add("INTERESTING WORKSPACE OBJECTS: " .. eggCount)

--==================================================
-- 3. REPLICATED STORAGE
--==================================================

add("")
add("========== REPLICATED STORAGE ==========")

local replicated = game:GetService("ReplicatedStorage")

local repCount = 0

for _, obj in ipairs(replicated:GetDescendants()) do

    local interesting =
        looksInteresting(obj.Name)
        or obj:IsA("RemoteEvent")
        or obj:IsA("RemoteFunction")

    if interesting then

        repCount += 1

        if repCount <= 200 then

            add("")
            add("REPLICATED #" .. repCount)
            add("NAME: " .. obj.Name)
            add("CLASS: " .. obj.ClassName)
            add("PATH: " .. obj:GetFullName())

            dumpMetadata(obj, "  ")
        end
    end
end

add("")
add("REPLICATED INTERESTING OBJECTS: " .. repCount)

--==================================================
-- 4. LOCAL PLAYER
--==================================================

add("")
add("========== LOCAL PLAYER DATA ==========")

local playerCount = 0

for _, obj in ipairs(player:GetDescendants()) do

    if looksInteresting(obj.Name) then

        playerCount += 1

        if playerCount <= 100 then

            add("")
            add("PLAYER OBJECT #" .. playerCount)
            add("NAME: " .. obj.Name)
            add("CLASS: " .. obj.ClassName)
            add("PATH: " .. obj:GetFullName())

            dumpMetadata(obj, "  ")
        end
    end
end

add("")
add("PLAYER INTERESTING OBJECTS: " .. playerCount)

--==================================================
-- 5. COLLECTION TAGS
--==================================================

add("")
add("========== COLLECTION TAGS ==========")

local allTags = CollectionService:GetAllTags()

add("TOTAL TAGS: " .. tostring(#allTags))

for _, tag in ipairs(allTags) do

    local lower = string.lower(tag)

    if looksInteresting(lower) then

        add("")
        add("TAG: " .. tag)

        local tagged = CollectionService:GetTagged(tag)

        add("INSTANCES: " .. tostring(#tagged))

        for i, instance in ipairs(tagged) do

            if i <= 50 then
                add(
                    "  " ..
                    tostring(instance:GetFullName()) ..
                    " [" ..
                    instance.ClassName ..
                    "]"
                )
            end
        end
    end
end

--==================================================
-- COMPLETE
--==================================================

add("")
add("========================================")
add("SCAN COMPLETE")
add("========================================")

print("Results stored:", #results)

--==================================================
-- COPY GUI
--==================================================

local PlayerGui = player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("EggForensicV2")

if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "EggForensicV2"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 310, 0, 145)
frame.Position = UDim2.new(0.5, -155, 0.1, 0)
frame.BackgroundTransparency = 0.1
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "STEAL AN EGG — FORENSIC V2"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 25)
info.Position = UDim2.new(0, 10, 0, 42)
info.BackgroundTransparency = 1
info.Text = "Scan complete — copy the results"
info.TextSize = 12
info.Font = Enum.Font.Gotham
info.TextColor3 = Color3.new(1, 1, 1)
info.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 190, 0, 42)
button.Position = UDim2.new(0.5, -95, 1, -52)
button.Text = "COPY RESULTS"
button.TextSize = 15
button.Font = Enum.Font.GothamBold
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = button

button.Activated:Connect(function()

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
        button.Text = "COPIED!"
        task.wait(1.5)
        button.Text = "COPY RESULTS"
    else
        button.Text = "CLIPBOARD UNSUPPORTED"
        task.wait(1.5)
        button.Text = "COPY RESULTS"
    end
end)
