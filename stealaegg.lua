--==================================================
-- STEAL AN EGG - DISCOVERY SCANNER V3
-- READ ONLY / MOBILE
-- COMPACT SINGLE-CLIPBOARD OUTPUT
--==================================================

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local results = {}
local seen = {}

local MAX_OUTPUT = 8500

local function add(text)
    text = tostring(text)

    if #table.concat(results, "\n") + #text + 1 <= MAX_OUTPUT then
        table.insert(results, text)
        print(text)
    end
end

local function addUnique(text)
    if not seen[text] then
        seen[text] = true
        add(text)
    end
end

local function lower(v)
    return string.lower(tostring(v or ""))
end

local function interesting(text)
    text = lower(text)

    local words = {
        "egg",
        "rarity",
        "rare",
        "mutation",
        "mutated",
        "value",
        "worth",
        "price",
        "size",
        "steal",
        "carry",
        "deposit",
        "return",
        "place",
        "base",
        "plot",
        "pen",
        "pet"
    }

    for _, word in ipairs(words) do
        if string.find(text, word, 1, true) then
            return true
        end
    end

    return false
end

local function metadata(obj)
    local pieces = {}

    for name, value in pairs(obj:GetAttributes()) do
        if interesting(name) or interesting(value) then
            table.insert(
                pieces,
                "A:" .. name .. "=" .. tostring(value)
            )
        end
    end

    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("NumberValue")
            or child:IsA("IntValue")
            or child:IsA("StringValue")
            or child:IsA("BoolValue") then

            if interesting(child.Name) or interesting(child.Value) then
                table.insert(
                    pieces,
                    "V:" .. child.Name .. "=" .. tostring(child.Value)
                )
            end
        end
    end

    return table.concat(pieces, " | ")
end

add("STEAL AN EGG DISCOVERY V3")
add("PLAYER=" .. player.Name)

--==================================================
-- ACTIVE PROMPTS
--==================================================

add("")
add("[PROMPTS]")

local promptCount = 0

for _, prompt in ipairs(workspace:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") then

        local text =
            tostring(prompt.Name) .. " " ..
            tostring(prompt.ActionText) .. " " ..
            tostring(prompt.ObjectText)

        if prompt.Enabled or interesting(text) then

            if interesting(text) then
                promptCount += 1

                add(
                    "P" ..
                    promptCount ..
                    "|" ..
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

                local meta = metadata(prompt)

                if meta ~= "" then
                    add("M|" .. meta)
                end

                local parentMeta = metadata(prompt.Parent)

                if parentMeta ~= "" then
                    add("PM|" .. parentMeta)
                end
            end
        end
    end
end

add("PROMPTS=" .. promptCount)

--==================================================
-- CURRENTLY VISIBLE UI
--==================================================

add("")
add("[UI]")

local uiCount = 0

local function scanUI(root)

    for _, obj in ipairs(root:GetDescendants()) do

        if obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox") then

            local text = tostring(obj.Text or "")

            if text ~= "" and interesting(text) then

                local cleaned = string.gsub(text, "\n", " ")

                if #cleaned > 180 then
                    cleaned = string.sub(cleaned, 1, 180)
                end

                addUnique("UI|" .. obj:GetFullName() .. "|" .. cleaned)

                uiCount += 1

                if uiCount >= 80 then
                    return
                end
            end
        end
    end
end

scanUI(player:WaitForChild("PlayerGui"))

--==================================================
-- TAGS
--==================================================

add("")
add("[TAGS]")

local tagCount = 0

for _, tag in ipairs(CollectionService:GetAllTags()) do

    if interesting(tag) then

        local tagged = CollectionService:GetTagged(tag)

        addUnique(
            "TAG|" ..
            tag ..
            "|COUNT=" ..
            tostring(#tagged)
        )

        local shown = 0

        for _, instance in ipairs(tagged) do

            if shown < 8 then
                addUnique(
                    "TAGOBJ|" ..
                    tag ..
                    "|" ..
                    instance:GetFullName()
                )

                shown += 1
            end
        end

        tagCount += 1
    end
end

add("TAGS=" .. tagCount)

--==================================================
-- REPLICATED OBJECT NAMES
--==================================================

add("")
add("[REPLICATED]")

local replicated = game:GetService("ReplicatedStorage")
local remoteCount = 0

for _, obj in ipairs(replicated:GetDescendants()) do

    if obj:IsA("RemoteEvent")
        or obj:IsA("RemoteFunction")
        or obj:IsA("ModuleScript") then

        if interesting(obj.Name) then

            addUnique(
                "R|" ..
                obj.ClassName ..
                "|" ..
                obj:GetFullName()
            )

            remoteCount += 1

            if remoteCount >= 80 then
                break
            end
        end
    end
end

add("REPLICATED_MATCHES=" .. remoteCount)

--==================================================
-- WORLD OBJECTS WITH RELEVANT METADATA
--==================================================

add("")
add("[WORLD-META]")

local worldCount = 0

for _, obj in ipairs(workspace:GetDescendants()) do

    local meta = metadata(obj)

    if meta ~= "" then

        addUnique(
            "W|" ..
            obj:GetFullName() ..
            "|" ..
            meta
        )

        worldCount += 1

        if worldCount >= 70 then
            break
        end
    end
end

add("WORLD_META=" .. worldCount)

--==================================================
-- PLAYER METADATA
--==================================================

add("")
add("[PLAYER-META]")

local playerMetaCount = 0

local function scanPlayerMeta(root)

    local meta = metadata(root)

    if meta ~= "" then
        addUnique(
            "P-META|" ..
            root:GetFullName() ..
            "|" ..
            meta
        )

        playerMetaCount += 1
    end

    for _, child in ipairs(root:GetChildren()) do

        if playerMetaCount >= 40 then
            break
        end

        local childMeta = metadata(child)

        if childMeta ~= "" then
            addUnique(
                "P-META|" ..
                child:GetFullName() ..
                "|" ..
                childMeta
            )

            playerMetaCount += 1
        end
    end
end

scanPlayerMeta(player)

--==================================================
-- PROMPTS THAT BECOME VISIBLE
--==================================================

local shownConnections = 0

local function onPromptShown(prompt)

    if prompt and prompt:IsA("ProximityPrompt") then

        local text =
            tostring(prompt.Name) .. " " ..
            tostring(prompt.ActionText) .. " " ..
            tostring(prompt.ObjectText)

        if interesting(text) then

            addUnique(
                "SHOWN|" ..
                prompt:GetFullName() ..
                "|" ..
                tostring(prompt.ActionText) ..
                "|" ..
                tostring(prompt.ObjectText) ..
                "|H=" ..
                tostring(prompt.HoldDuration) ..
                "|D=" ..
                tostring(prompt.MaxActivationDistance)
            )

            shownConnections += 1
        end
    end
end

ProximityPromptService.PromptShown:Connect(onPromptShown)

--==================================================
-- COPY GUI
--==================================================

local guiParent = player:WaitForChild("PlayerGui")

local old = guiParent:FindFirstChild("EggDiscoveryV3")

if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "EggDiscoveryV3"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 170)
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
title.Text = "EGG DISCOVERY V3"
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 42)
info.Position = UDim2.new(0, 10, 0, 45)
info.BackgroundTransparency = 1
info.Text =
    "Compact scan complete\n" ..
    "Output: " .. tostring(#table.concat(results, "\n")) .. " chars"
info.TextSize = 12
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.TextColor3 = Color3.new(1,1,1)
info.Parent = frame

local copy = Instance.new("TextButton")
copy.Size = UDim2.new(0, 210, 0, 45)
copy.Position = UDim2.new(0.5, -105, 1, -58)
copy.Text = "COPY ALL RESULTS"
copy.TextSize = 15
copy.Font = Enum.Font.GothamBold
copy.TextColor3 = Color3.new(1,1,1)
copy.Parent = frame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copy

copy.Activated:Connect(function()

    local finalText = table.concat(results, "\n")
    local success = false

    if typeof(setclipboard) == "function" then

        success = pcall(function()
            setclipboard(finalText)
        end)

    elseif typeof(toclipboard) == "function" then

        success = pcall(function()
            toclipboard(finalText)
        end)
    end

    if success then
        copy.Text = "COPIED ALL!"
        task.wait(1.5)
        copy.Text = "COPY ALL RESULTS"
    else
        copy.Text = "CLIPBOARD FAILED"
        task.wait(1.5)
        copy.Text = "COPY ALL RESULTS"
    end
end)

add("")
add("OUTPUT_CHARS=" .. tostring(#table.concat(results, "\n")))
add("READY=YES")
