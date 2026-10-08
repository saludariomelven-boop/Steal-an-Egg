--// STEAL AN EGG - PRIVATE BETA AUTO STEAL TEST
--// V1
--// Flow:
--// 1. Find highest-value CarryAreaEgg
--// 2. Trigger Steal
--// 3. Detect/enter carrying phase
--// 4. Move player to own pen
--// 5. Trigger nearby deposit/place prompt if available
--// 6. Repeat

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
    Enabled = false,

    ScanDelay = 0.8,
    StealWait = 0.6,
    DepositWait = 1.2,
    TeleportBursts = 6,

    EggPromptName = "CarryAreaEgg",

    -- Used when the game exposes an actual numeric
    -- egg value through Attributes/Value objects.
    ValueNames = {
        "Value",
        "EggValue",
        "Price",
        "Cost",
        "Worth",
        "Cash",
        "Money",
        "Coins",
        "SellValue",
        "Amount",
    },

    DepositWords = {
        "deposit",
        "place",
        "store",
        "return",
        "drop",
        "sell",
        "put",
    },

    BaseWords = {
        "base",
        "plot",
        "pen",
        "home",
        "territory",
    },
}

--==================================================
-- GUI
--==================================================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    local old = PlayerGui:FindFirstChild("StealAnEggAuto")
    if old then
        old:Destroy()
    end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "StealAnEggAuto"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 330, 0, 245)
Main.Position = UDim2.new(0.5, -165, 0.08, 0)
Main.BackgroundTransparency = 0.12
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "STEAL AN EGG — BETA TEST"
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 45)
Status.BackgroundTransparency = 1
Status.Text = "Status: OFF"
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextColor3 = Color3.new(1, 1, 1)
Status.Parent = Main

local EggInfo = Instance.new("TextLabel")
EggInfo.Size = UDim2.new(1, -20, 0, 55)
EggInfo.Position = UDim2.new(0, 10, 0, 75)
EggInfo.BackgroundTransparency = 1
EggInfo.Text = "Egg: none"
EggInfo.TextSize = 13
EggInfo.Font = Enum.Font.Gotham
EggInfo.TextXAlignment = Enum.TextXAlignment.Left
EggInfo.TextYAlignment = Enum.TextYAlignment.Top
EggInfo.TextWrapped = true
EggInfo.TextColor3 = Color3.new(1, 1, 1)
EggInfo.Parent = Main

local PenInfo = Instance.new("TextLabel")
PenInfo.Size = UDim2.new(1, -20, 0, 30)
PenInfo.Position = UDim2.new(0, 10, 0, 130)
PenInfo.BackgroundTransparency = 1
PenInfo.Text = "Pen: searching..."
PenInfo.TextSize = 13
PenInfo.Font = Enum.Font.Gotham
PenInfo.TextXAlignment = Enum.TextXAlignment.Left
PenInfo.TextColor3 = Color3.new(1, 1, 1)
PenInfo.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 145, 0, 42)
Toggle.Position = UDim2.new(0, 10, 1, -55)
Toggle.BackgroundTransparency = 0
Toggle.Text = "AUTO STEAL: OFF"
Toggle.TextSize = 14
Toggle.Font = Enum.Font.GothamBold
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

local SetPen = Instance.new("TextButton")
SetPen.Size = UDim2.new(0, 145, 0, 42)
SetPen.Position = UDim2.new(1, -155, 1, -55)
SetPen.BackgroundTransparency = 0
SetPen.Text = "SET PEN HERE"
SetPen.TextSize = 13
SetPen.Font = Enum.Font.GothamBold
SetPen.TextColor3 = Color3.new(1, 1, 1)
SetPen.Parent = Main

local SetPenCorner = Instance.new("UICorner")
SetPenCorner.CornerRadius = UDim.new(0, 8)
SetPenCorner.Parent = SetPen

--==================================================
-- STATE
--==================================================

local Running = false
local ManualPen = nil
local CurrentEgg = nil
local Busy = false

--==================================================
-- HELPERS
--==================================================

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local Character = getCharacter()
    return Character:FindFirstChild("HumanoidRootPart")
end

local function getObjectPosition(obj)
    if not obj then
        return nil
    end

    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        end

        local part = obj:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return part.Position
        end
    end

    local attachment = obj:FindFirstChildWhichIsA("Attachment", true)

    if attachment then
        return attachment.WorldPosition
    end

    return nil
end

local function containsWord(text, words)
    text = string.lower(tostring(text or ""))

    for _, word in ipairs(words) do
        if string.find(text, word, 1, true) then
            return true
        end
    end

    return false
end

--==================================================
-- VALUE DETECTION
--==================================================

local function getNumericValue(obj)
    if not obj then
        return nil
    end

    -- Attributes
    for _, name in ipairs(CONFIG.ValueNames) do
        local value = obj:GetAttribute(name)

        if typeof(value) == "number" then
            return value
        end
    end

    -- Value objects
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            for _, name in ipairs(CONFIG.ValueNames) do
                if string.lower(child.Name) == string.lower(name) then
                    return child.Value
                end
            end
        end
    end

    return nil
end

local function getEggScore(prompt)
    local score = 0

    local current = prompt

    -- Inspect prompt and several ancestors.
    for _ = 1, 5 do
        if not current then
            break
        end

        local value = getNumericValue(current)

        if value then
            score = math.max(score, value)
        end

        local name = string.lower(current.Name)

        -- Rarity fallback if a numerical value isn't exposed.
        if string.find(name, "secret", 1, true) then
            score = math.max(score, 9000000)
        elseif string.find(name, "eternal", 1, true) then
            score = math.max(score, 8000000)
        elseif string.find(name, "mythic", 1, true) then
            score = math.max(score, 7000000)
        elseif string.find(name, "legendary", 1, true) then
            score = math.max(score, 6000000)
        elseif string.find(name, "epic", 1, true) then
            score = math.max(score, 5000000)
        elseif string.find(name, "rare", 1, true) then
            score = math.max(score, 4000000)
        end

        current = current.Parent
    end

    -- Final fallback:
    -- stable score so an egg is still selectable.
    if score == 0 then
        score = 1
    end

    return score
end

--==================================================
-- FIND EGGS
--==================================================

local function findEggPrompts()
    local results = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local action = string.lower(obj.ActionText or "")
            local name = string.lower(obj.Name or "")
            local objectText = string.lower(obj.ObjectText or "")

            local isEggPrompt =
                name == string.lower(CONFIG.EggPromptName)
                or (
                    action == "steal"
                    and string.find(objectText, "egg", 1, true)
                )

            if isEggPrompt then
                local position = getObjectPosition(obj.Parent)

                if position then
                    local score = getEggScore(obj)

                    table.insert(results, {
                        Prompt = obj,
                        Position = position,
                        Score = score,
                    })
                end
            end
        end
    end

    table.sort(results, function(a, b)
        return a.Score > b.Score
    end)

    return results
end

local function getBestEgg()
    local eggs = findEggPrompts()

    return eggs[1], eggs
end

--==================================================
-- PEN DETECTION
--==================================================

local function inspectForOwnership(obj)
    local ownerNames = {
        "Owner",
        "OwnerName",
        "OwnerUserName",
        "Username",
        "Player",
    }

    local ownerIds = {
        "OwnerUserId",
        "UserId",
        "OwnerId",
    }

    for _, name in ipairs(ownerNames) do
        local value = obj:GetAttribute(name)

        if typeof(value) == "string" then
            if value == LocalPlayer.Name
                or value == LocalPlayer.DisplayName then
                return true
            end
        end
    end

    for _, name in ipairs(ownerIds) do
        local value = obj:GetAttribute(name)

        if typeof(value) == "number" and value == LocalPlayer.UserId then
            return true
        end

        if typeof(value) == "string"
            and tonumber(value) == LocalPlayer.UserId then
            return true
        end
    end

    return false
end

local function findOwnPen()
    if ManualPen then
        return ManualPen
    end

    local candidates = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = string.lower(obj.Name)

            if containsWord(name, CONFIG.BaseWords) then
                if inspectForOwnership(obj) then
                    local position = getObjectPosition(obj)

                    if position then
                        table.insert(candidates, {
                            Object = obj,
                            Position = position,
                        })
                    end
                end
            end
        end
    end

    if #candidates > 0 then
        return candidates[1]
    end

    return nil
end

--==================================================
-- PROMPT TRIGGER
--==================================================

local function triggerPrompt(prompt)
    if not prompt or not prompt.Parent then
        return false
    end

    -- Delta/executor environments commonly expose
    -- fireproximityprompt().
    if typeof(fireproximityprompt) == "function" then
        local ok = pcall(function()
            fireproximityprompt(prompt)
        end)

        if ok then
            return true
        end
    end

    -- Standard Roblox ProximityPrompt method fallback.
    local ok = pcall(function()
        prompt:InputHoldBegin()

        local duration = tonumber(prompt.HoldDuration) or 0

        if duration > 0 then
            task.wait(duration + 0.1)
        else
            task.wait(0.1)
        end

        prompt:InputHoldEnd()
    end)

    return ok
end

--==================================================
-- TELEPORT / RETURN
--==================================================

local function moveToPosition(position)
    if not position then
        return false
    end

    local root = getRoot()

    if not root then
        return false
    end

    local target = CFrame.new(position + Vector3.new(0, 3, 0))

    for _ = 1, CONFIG.TeleportBursts do
        if not Running then
            break
        end

        pcall(function()
            root.CFrame = target
        end)

        task.wait(0.08)
    end

    return true
end

--==================================================
-- DEPOSIT
--==================================================

local function findDepositPrompt(penPosition)
    if not penPosition then
        return nil
    end

    local closest = nil
    local closestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local action = string.lower(obj.ActionText or "")
            local objectText = string.lower(obj.ObjectText or "")
            local promptPosition = getObjectPosition(obj.Parent)

            if promptPosition then
                local distance = (promptPosition - penPosition).Magnitude

                if distance <= 80 then
                    local valid =
                        containsWord(action, CONFIG.DepositWords)
                        or containsWord(objectText, CONFIG.DepositWords)

                    if valid and distance < closestDistance then
                        closestDistance = distance
                        closest = obj
                    end
                end
            end
        end
    end

    return closest
end

local function depositEgg(pen)
    if not pen then
        return false
    end

    Status.Text = "Status: RETURNING TO PEN"

    moveToPosition(pen.Position)

    task.wait(CONFIG.DepositWait)

    local depositPrompt = findDepositPrompt(pen.Position)

    if depositPrompt then
        Status.Text = "Status: DEPOSITING"
        triggerPrompt(depositPrompt)
        task.wait(CONFIG.DepositWait)
    else
        -- Some implementations deposit automatically
        -- when the carried egg reaches the player's base.
        Status.Text = "Status: WAITING FOR AUTO-DEPOSIT"
        task.wait(CONFIG.DepositWait)
    end

    return true
end

--==================================================
-- ONE STEAL
--==================================================

local function performSteal()
    if Busy then
        return
    end

    Busy = true

    local egg, eggs = getBestEgg()

    if not egg then
        Status.Text = "Status: NO EGGS FOUND"
        Busy = false
        return
    end

    CurrentEgg = egg

    EggInfo.Text =
        "Egg: " ..
        tostring(egg.Prompt.ObjectText) ..
        "\nScore/Value: " ..
        tostring(egg.Score) ..
        "\nCandidates: " ..
        tostring(#eggs)

    PenInfo.Text = "Pen: searching..."

    local pen = findOwnPen()

    if not pen then
        PenInfo.Text = "Pen: NOT FOUND"
        Status.Text = "Status: SET YOUR PEN"
        Busy = false
        return
    end

    PenInfo.Text =
        "Pen: " ..
        tostring(pen.Object and pen.Object.Name or "Detected")

    -- Move close enough for normal prompt interaction first.
    local eggPosition = egg.Position

    if eggPosition then
        moveToPosition(eggPosition)
        task.wait(0.2)
    end

    Status.Text = "Status: STEALING"

    local success = triggerPrompt(egg.Prompt)

    if not success then
        Status.Text = "Status: STEAL TRIGGER FAILED"
        Busy = false
        return
    end

    task.wait(CONFIG.StealWait)

    -- Return immediately after the steal attempt.
    depositEgg(pen)

    Busy = false
end

--==================================================
-- LOOP
--==================================================

task.spawn(function()
    while task.wait(CONFIG.ScanDelay) do
        if Running and not Busy then
            pcall(function()
                performSteal()
            end)
        end
    end
end)

--==================================================
-- BUTTONS
--==================================================

Toggle.MouseButton1Click:Connect(function()
    Running = not Running

    if Running then
        Toggle.Text = "AUTO STEAL: ON"
        Status.Text = "Status: SCANNING"
    else
        Toggle.Text = "AUTO STEAL: OFF"
        Status.Text = "Status: OFF"
    end
end)

SetPen.MouseButton1Click:Connect(function()
    local root = getRoot()

    if not root then
        return
    end

    ManualPen = {
        Object = nil,
        Position = root.Position,
    }

    PenInfo.Text = "Pen: MANUAL POSITION SET"
    Status.Text = "Status: PEN SAVED"
end)

--==================================================
-- STARTUP
--==================================================

Status.Text = "Status: READY"

task.spawn(function()
    task.wait(1)

    local best, all = getBestEgg()

    if best then
        EggInfo.Text =
            "Egg: " ..
            tostring(best.Prompt.ObjectText) ..
            "\nScore/Value: " ..
            tostring(best.Score) ..
            "\nCandidates: " ..
            tostring(#all)
    else
        EggInfo.Text = "Egg: none found"
    end

    local pen = findOwnPen()

    if pen then
        PenInfo.Text =
            "Pen: " ..
            tostring(pen.Object and pen.Object.Name or "Detected")
    else
        PenInfo.Text = "Pen: not detected — use SET PEN HERE"
    end
end)
