local Players = game:GetService("Players")

local player = Players.LocalPlayer

--==================================================
-- UI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "StealEggAutoTest"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 220, 0, 55)
button.Position = UDim2.new(0.5, -110, 0.08, 0)
button.Text = "AUTO STEAL: OFF"
button.TextScaled = true
button.Parent = gui

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 420, 0, 70)
status.Position = UDim2.new(0.5, -210, 0.08, 65)
status.TextScaled = true
status.TextWrapped = true
status.Text = "Ready"
status.Parent = gui

--==================================================
-- Helpers
--==================================================

local enabled = false
local busy = false

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
    return getCharacter():WaitForChild("HumanoidRootPart")
end

local function setStatus(text)
    status.Text = text
end

local function teleportTo(position)
    local root = getRoot()

    root.CFrame = CFrame.new(
        position + Vector3.new(0, 3, 0)
    )

    task.wait(0.2)
end

--==================================================
-- Find ALL egg steal prompts
--==================================================

local function getEggPrompts()

    local prompts = {}

    for _, obj in ipairs(workspace:GetDescendants()) do

        if obj:IsA("ProximityPrompt")
        and obj.Name == "CarryAreaEgg"
        and obj.ActionText == "Steal"
        and obj.ObjectText == "Egg" then

            table.insert(prompts, obj)
        end
    end

    return prompts
end

--==================================================
-- Get prompt position
--==================================================

local function getPromptPosition(prompt)

    local parent = prompt.Parent

    if parent and parent:IsA("BasePart") then
        return parent.Position
    end

    if parent and parent:IsA("Attachment") then
        return parent.WorldPosition
    end

    if parent and parent:IsA("Model") then
        local part =
            parent.PrimaryPart
            or parent:FindFirstChildWhichIsA("BasePart")

        if part then
            return part.Position
        end
    end

    return nil
end

--==================================================
-- Find closest stealable egg
--==================================================

local function getClosestEgg()

    local root = getRoot()

    local closest = nil
    local closestDistance = math.huge

    for _, prompt in ipairs(getEggPrompts()) do

        if prompt.Enabled then

            local position = getPromptPosition(prompt)

            if position then

                local distance =
                    (root.Position - position).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closest = prompt
                end
            end
        end
    end

    return closest, closestDistance
end

--==================================================
-- Try triggering the prompt multiple ways
--==================================================

local function triggerPrompt(prompt)

    -- Method 1: executor helper
    if typeof(fireproximityprompt) == "function" then

        local success = pcall(function()
            fireproximityprompt(prompt)
        end)

        if success then
            return "fireproximityprompt"
        end
    end

    -- Method 2: native Roblox prompt input
    local success = pcall(function()

        local oldHold = prompt.HoldDuration

        prompt.HoldDuration = 0

        prompt:InputHoldBegin()
        task.wait(0.15)
        prompt:InputHoldEnd()

        prompt.HoldDuration = oldHold

    end)

    if success then
        return "InputHoldBegin/End"
    end

    return nil
end

--==================================================
-- TEST ONE STEAL
--==================================================

local function stealOne()

    local prompt, distance = getClosestEgg()

    if not prompt then
        setStatus("No CarryAreaEgg / Steal prompt found.")
        return false
    end

    setStatus(
        "Target found\nDistance: "
        .. math.floor(distance)
        .. "\nMoving..."
    )

    local position = getPromptPosition(prompt)

    if not position then
        setStatus("Found egg prompt, but no position.")
        return false
    end

    teleportTo(position)

    task.wait(0.3)

    setStatus("Triggering STEAL...")

    local method = triggerPrompt(prompt)

    if not method then
        setStatus("Could not trigger the prompt.")
        return false
    end

    setStatus(
        "Steal triggered using:\n"
        .. method
    )

    task.wait(1)

    return true
end

--==================================================
-- Toggle
--==================================================

button.MouseButton1Click:Connect(function()

    enabled = not enabled

    if enabled then

        button.Text = "AUTO STEAL: ON"
        setStatus("Auto Steal enabled.")

        task.spawn(function()

            while enabled do

                if not busy then

                    busy = true

                    pcall(function()
                        stealOne()
                    end)

                    busy = false

                end

                task.wait(2)
            end

        end)

    else

        button.Text = "AUTO STEAL: OFF"
        setStatus("Auto Steal disabled.")
    end
end)
