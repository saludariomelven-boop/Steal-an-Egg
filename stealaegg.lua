--==================================================
-- STEAL AN EGG - TARGETED DISCOVERY V4
-- READ ONLY
--==================================================

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local results = {}
local seen = {}
local MAX_OUTPUT = 8500

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

    if #text > 220 then
        text = string.sub(text, 1, 220) .. "..."
    end

    return text
end

local function relevantText(text)
    text = string.lower(tostring(text or ""))

    local words = {
        "egg",
        "kg",
        "rarity",
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
        "stolen",
        "stole",
        "steal",
        "carry",
        "run",
        "sell",
        "return",
        "deposit",
        "place",
        "worth",
        "price",
        "value",
        "$"
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
add("STEAL AN EGG - TARGETED DISCOVERY V4")
add("PLAYER=" .. player.Name)
add("READ ONLY")
add("========================================")

--==================================================
-- TARGETED UI SCAN
--==================================================

local function scanGui(root, label)

    local count = 0

    for _, obj in ipairs(root:GetDescendants()) do

        if obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox") then

            local text = clean(obj.Text)

            if text ~= "" and relevantText(text) then

                unique(
                    label ..
                    "|" ..
                    obj:GetFullName() ..
                    "|" ..
                    text
                )

                count += 1

                if count >= 100 then
                    break
                end
            end
        end
    end

    return count
end

add("")
add("[ASSET EGG DATA]")

local assetEggData = PlayerGui:FindFirstChild("AssetEggData", true)

if assetEggData then

    add("FOUND=" .. assetEggData:GetFullName())

    local count = scanGui(
        assetEggData,
        "ASSET"
    )

    add("ASSET_TEXT_MATCHES=" .. count)

else
    add("NOT_FOUND")
end

add("")
add("[BACKPACK]")

local backpackGui = PlayerGui:FindFirstChild("BackpackGui", true)

if backpackGui then

    add("FOUND=" .. backpackGui:GetFullName())

    local count = scanGui(
        backpackGui,
        "BACKPACK"
    )

    add("BACKPACK_TEXT_MATCHES=" .. count)

else
    add("NOT_FOUND")
end

--==================================================
-- ALL PLAYER UI RELEVANT TEXT
--==================================================

add("")
add("[ALL RELEVANT UI]")

local totalUI = 0

for _, obj in ipairs(PlayerGui:GetDescendants()) do

    if obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox") then

        local text = clean(obj.Text)

        if text ~= "" and relevantText(text) then

            unique(
                "UI|" ..
                obj:GetFullName() ..
                "|" ..
                text
            )

            totalUI += 1

            if totalUI >= 150 then
                break
            end
        end
    end
end

add("UI_MATCHES=" .. totalUI)

--==================================================
-- PROMPTS RELATED TO SELL / RETURN / CARRY
--==================================================

add("")
add("[SELL / RETURN PROMPTS]")

local promptCount = 0

for _, prompt in ipairs(workspace:GetDescendants()) do

    if prompt:IsA("ProximityPrompt") then

        local combined =
            tostring(prompt.Name) ..
            " " ..
            tostring(prompt.ActionText) ..
            " " ..
            tostring(prompt.ObjectText)

        if relevantText(combined) then

            local lowerCombined = string.lower(combined)

            if string.find(lowerCombined, "sell", 1, true)
                or string.find(lowerCombined, "return", 1, true)
                or string.find(lowerCombined, "deposit", 1, true)
                or string.find(lowerCombined, "place", 1, true)
                or string.find(lowerCombined, "carry", 1, true)
                or string.find(lowerCombined, "steal", 1, true) then

                unique(
                    "PROMPT|" ..
                    prompt:GetFullName() ..
                    "|" ..
                    tostring(prompt.ActionText) ..
                    "|" ..
                    tostring(prompt.ObjectText) ..
                    "|Enabled=" ..
                    tostring(prompt.Enabled) ..
                    "|Hold=" ..
                    tostring(prompt.HoldDuration) ..
                    "|Distance=" ..
                    tostring(prompt.MaxActivationDistance)
                )

                promptCount += 1

                if promptCount >= 120 then
                    break
                end
            end
        end
    end
end

add("RELATED_PROMPTS=" .. promptCount)

--==================================================
-- CURRENT CHARACTER STATE
--==================================================

add("")
add("[CHARACTER]")

local character = player.Character

if character then

    add("CHARACTER=" .. character:GetFullName())

    for _, obj in ipairs(character:GetDescendants()) do

        if obj:IsA("Tool")
            or obj:IsA("StringValue")
            or obj:IsA("NumberValue")
            or obj:IsA("IntValue")
            or obj:IsA("BoolValue") then

            add(
                "CHAR|" ..
                obj:GetFullName() ..
                "|" ..
                obj.ClassName
            )

            if obj:IsA("StringValue")
                or obj:IsA("NumberValue")
                or obj:IsA("IntValue")
                or obj:IsA("BoolValue") then

                add(
                    "VALUE=" ..
                    tostring(obj.Value)
                )
            end
        end
    end

else
    add("CHARACTER_NOT_FOUND")
end

--==================================================
-- PROMPT VISIBILITY MONITOR
--==================================================

add("")
add("[LIVE PROMPT MONITOR]")
add("Move close to an egg or the sell area now.")

local monitoring = true
local monitorCount = 0

local connection

connection = ProximityPromptService.PromptShown:Connect(function(prompt)

    if not monitoring then
        return
    end

    local combined =
        tostring(prompt.Name) ..
        " " ..
        tostring(prompt.ActionText) ..
        " " ..
        tostring(prompt.ObjectText)

    if relevantText(combined) then

        unique(
            "SHOWN|" ..
            prompt:GetFullName() ..
            "|" ..
            tostring(prompt.ActionText) ..
            "|" ..
            tostring(prompt.ObjectText) ..
            "|Enabled=" ..
            tostring(prompt.Enabled) ..
            "|Hold=" ..
            tostring(prompt.HoldDuration) ..
            "|Distance=" ..
            tostring(prompt.MaxActivationDistance)
        )

        monitorCount += 1
    end
end)

--==================================================
-- WAIT
--==================================================

task.wait(10)

monitoring = false

if connection then
    connection:Disconnect()
end

add("")
add("LIVE_PROMPTS_CAPTURED=" .. monitorCount)

--==================================================
-- COMPLETE
--==================================================

add("")
add("========================================")
add("SCAN COMPLETE")
add("========================================")

local finalText = table.concat(results, "\n")

add("OUTPUT_CHARS=" .. tostring(#finalText))

--==================================================
-- COPY GUI
--==================================================

local old = PlayerGui:FindFirstChild("EggDiscoveryV4")

if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "EggDiscoveryV4"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 180)
frame.Position = UDim2.new(0.5, -160, 0.08, 0)
frame.BackgroundTransparency = 0.08
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "DISCOVERY V4"
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 48)
info.Position = UDim2.new(0, 10, 0, 48)
info.BackgroundTransparency = 1
info.Text =
    "Targeted scan complete.\n" ..
    "Move around the egg/sell area for 10 seconds."
info.TextSize = 12
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.TextColor3 = Color3.new(1,1,1)
info.Parent = frame

local copy = Instance.new("TextButton")
copy.Size = UDim2.new(0, 215, 0, 45)
copy.Position = UDim2.new(0.5, -107, 1, -57)
copy.Text = "COPY ALL RESULTS"
copy.TextSize = 15
copy.Font = Enum.Font.GothamBold
copy.TextColor3 = Color3.new(1,1,1)
copy.Parent = frame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copy

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
