-- STEAL AN EGG - AUTO STEAL TEST
-- Client-side anti-cheat testing

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local CONFIG = {
    EggFolder = "Eggs",
    PenFolder = "Pens",

    StealPromptName = "StealPrompt",
    DepositPromptName = "DepositPrompt",

    Delay = 0.5
}

local function getRoot()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local function getPart(object)
    if object:IsA("BasePart") then
        return object
    end

    if object:IsA("Model") then
        return object.PrimaryPart
            or object:FindFirstChildWhichIsA("BasePart")
    end
end

local function teleport(position)
    local root = getRoot()
    root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
end

local function triggerPrompt(object, promptName)
    local prompt = object:FindFirstChild(promptName, true)

    if not prompt then
        prompt = object:FindFirstChildWhichIsA("ProximityPrompt", true)
    end

    if prompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)

        return true
    end

    return false
end

local function findEgg()
    local folder = workspace:FindFirstChild(CONFIG.EggFolder)

    if not folder then
        warn("Egg folder not found:", CONFIG.EggFolder)
        return nil
    end

    local root = getRoot()
    local closest
    local closestDistance = math.huge

    for _, egg in ipairs(folder:GetChildren()) do
        local part = getPart(egg)

        if part then
            local distance = (root.Position - part.Position).Magnitude

            if distance < closestDistance then
                closestDistance = distance
                closest = egg
            end
        end
    end

    return closest
end

local function findMyPen()
    local folder = workspace:FindFirstChild(CONFIG.PenFolder)

    if not folder then
        warn("Pen folder not found:", CONFIG.PenFolder)
        return nil
    end

    -- Try ownership attributes first
    for _, pen in ipairs(folder:GetChildren()) do
        if pen:GetAttribute("OwnerUserId") == player.UserId
        or pen:GetAttribute("Owner") == player.UserId
        or pen:GetAttribute("Owner") == player.Name then
            return pen
        end
    end

    return folder:GetChildren()[1]
end

local function autoSteal()
    local egg = findEgg()

    if not egg then
        return
    end

    local eggPart = getPart(egg)

    if not eggPart then
        return
    end

    -- Go to egg
    teleport(eggPart.Position)

    task.wait(0.15)

    -- Steal
    triggerPrompt(egg, CONFIG.StealPromptName)

    task.wait(CONFIG.Delay)

    -- Find pen
    local pen = findMyPen()

    if not pen then
        return
    end

    local penPart = getPart(pen)

    if not penPart then
        return
    end

    -- Go directly to pen
    teleport(penPart.Position)

    task.wait(0.15)

    -- Deposit
    triggerPrompt(pen, CONFIG.DepositPromptName)
end

task.spawn(function()
    while task.wait(CONFIG.Delay) do
        pcall(autoSteal)
    end
end)
