-- AutoStealTest.lua
-- Roblox Studio / private beta test
-- Flow:
-- Toggle ON
-- -> Find nearest egg
-- -> Move to egg
-- -> Claim/steal egg
-- -> Move to player's pen
-- -> Place egg
-- -> Repeat

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local CONFIG = {
    Enabled = false,
    RepeatDelay = 1,
    MoveHeight = 3,

    EggsFolder = workspace:WaitForChild("Eggs"),
    PensFolder = workspace:WaitForChild("Pens"),
}

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
    local character = getCharacter()
    return character:FindFirstChild("HumanoidRootPart")
end

local function findNearestEgg()
    local root = getRoot()
    if not root then
        return nil
    end

    local nearestEgg = nil
    local nearestDistance = math.huge

    for _, egg in ipairs(CONFIG.EggsFolder:GetChildren()) do
        if egg:IsA("BasePart") or egg:IsA("Model") then
            local targetPart

            if egg:IsA("BasePart") then
                targetPart = egg
            else
                targetPart = egg.PrimaryPart
                    or egg:FindFirstChildWhichIsA("BasePart")
            end

            if targetPart then
                local distance = (root.Position - targetPart.Position).Magnitude

                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestEgg = egg
                end
            end
        end
    end

    return nearestEgg
end

local function getObjectPosition(object)
    if object:IsA("BasePart") then
        return object.Position
    end

    if object:IsA("Model") then
        local part = object.PrimaryPart
            or object:FindFirstChildWhichIsA("BasePart")

        if part then
            return part.Position
        end
    end

    return nil
end

local function findPlayerPen()
    -- Expected:
    -- workspace.Pens/<PlayerName>

    return CONFIG.PensFolder:FindFirstChild(player.Name)
end

local function moveTo(position)
    local character = getCharacter()

    character:PivotTo(
        CFrame.new(
            position + Vector3.new(0, CONFIG.MoveHeight, 0)
        )
    )

    task.wait(0.25)
end

local function stealEgg(egg)
    -- TEST/BETA ACTION
    --
    -- Put your game's legitimate server-side
    -- steal/claim implementation here.

    if not egg then
        return false
    end

    egg:SetAttribute("CarriedBy", player.UserId)

    print("[AUTO STEAL] Egg claimed:", egg.Name)

    return true
end

local function placeEgg(egg, pen)
    -- TEST/BETA ACTION
    --
    -- Put your game's legitimate server-side
    -- placement implementation here.

    if not egg or not pen then
        return false
    end

    local penPosition = getObjectPosition(pen)

    if not penPosition then
        return false
    end

    local targetPart

    if egg:IsA("BasePart") then
        targetPart = egg
    else
        targetPart = egg.PrimaryPart
            or egg:FindFirstChildWhichIsA("BasePart")
    end

    if not targetPart then
        return false
    end

    targetPart.CFrame = CFrame.new(penPosition)
    egg:SetAttribute("CarriedBy", nil)

    print("[AUTO STEAL] Egg placed:", egg.Name)

    return true
end

local function runCycle()
    if not CONFIG.Enabled then
        return
    end

    -- STEP 1: Find egg
    local egg = findNearestEgg()

    if not egg then
        print("[AUTO STEAL] No egg found.")
        return
    end

    print("[AUTO STEAL] Target:", egg.Name)

    -- STEP 2: Move to egg
    local eggPosition = getObjectPosition(egg)

    if not eggPosition then
        return
    end

    moveTo(eggPosition)

    -- STEP 3: Steal
    local stolen = stealEgg(egg)

    if not stolen then
        print("[AUTO STEAL] Steal failed.")
        return
    end

    -- STEP 4: Find pen
    local pen = findPlayerPen()

    if not pen then
        print("[AUTO STEAL] Player pen not found.")
        return
    end

    -- STEP 5: Move to pen
    local penPosition = getObjectPosition(pen)

    if not penPosition then
        return
    end

    moveTo(penPosition)

    -- STEP 6: Place egg
    local placed = placeEgg(egg, pen)

    if placed then
        print("[AUTO STEAL] Cycle complete.")
    else
        print("[AUTO STEAL] Placement failed.")
    end
end

local function start()
    if CONFIG.Enabled then
        return
    end

    CONFIG.Enabled = true

    print("[AUTO STEAL] ENABLED")

    task.spawn(function()
        while CONFIG.Enabled do
            runCycle()
            task.wait(CONFIG.RepeatDelay)
        end
    end)
end

local function stop()
    CONFIG.Enabled = false
    print("[AUTO STEAL] DISABLED")
end

-- Expose controls for your Studio test UI
_G.AutoSteal = {
    Start = start,
    Stop = stop,

    Toggle = function()
        if CONFIG.Enabled then
            stop()
        else
            start()
        end
    end,

    IsEnabled = function()
        return CONFIG.Enabled
    end,
}

print("================================")
print("AUTO STEAL TEST LOADED")
print("Use:")
print("_G.AutoSteal.Toggle()")
print("_G.AutoSteal.Start()")
print("_G.AutoSteal.Stop()")
print("================================")
