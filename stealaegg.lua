-- STEAL AN EGG - AUTO STEAL TEST
-- Step 1: locate nearest egg and trigger Steal

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
    return getCharacter():WaitForChild("HumanoidRootPart")
end

local function getNearestEggPrompt()
    local root = getRoot()

    local closestPrompt = nil
    local closestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt")
            and obj.Name == "CarryAreaEgg"
            and obj.ActionText == "Steal"
            and obj.ObjectText == "Egg" then

            local parent = obj.Parent

            if parent and parent:IsA("BasePart") then
                local distance = (root.Position - parent.Position).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closestPrompt = obj
                end
            end
        end
    end

    return closestPrompt
end

local function stealNearestEgg()
    local root = getRoot()
    local prompt = getNearestEggPrompt()

    if not prompt then
        warn("No stealable egg found.")
        return
    end

    local eggPart = prompt.Parent

    -- Move to the egg
    root.CFrame = eggPart.CFrame + Vector3.new(0, 3, 0)

    task.wait(0.25)

    -- Trigger the actual egg's Steal interaction
    pcall(function()
        fireproximityprompt(prompt)
    end)

    print("Attempted to steal nearest egg.")
end

stealNearestEgg()
