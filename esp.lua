-- ESP Module
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Variables
local ESPEnabled = false
local activeESP = {}

-- Function to create a line
local function createLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Transparency = 1
    line.Color = Color3.fromRGB(255, 255, 255) -- Default to white
    return line
end

-- Function to create a skeleton for a player
local function createSkeleton(player)
    local skeleton = {}
    local bodyParts = {
        "Head",
        "UpperTorso",
        "LowerTorso",
        "LeftUpperArm",
        "LeftLowerArm",
        "LeftHand",
        "RightUpperArm",
        "RightLowerArm",
        "RightHand",
        "LeftUpperLeg",
        "LeftLowerLeg",
        "LeftFoot",
        "RightUpperLeg",
        "RightLowerLeg",
        "RightFoot"
    }

    for _, partName in ipairs(bodyParts) do
        skeleton[partName] = createLine()
    end

    return skeleton
end

-- Function to update a player's skeleton ESP
local function updateSkeleton(player, skeleton)
    local character = player.Character
    if not character then return end

    local connections = {
        {character:FindFirstChild("Head"), character:FindFirstChild("UpperTorso")},
        {character:FindFirstChild("UpperTorso"), character:FindFirstChild("LowerTorso")},
        {character:FindFirstChild("UpperTorso"), character:FindFirstChild("LeftUpperArm")},
        {character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm")},
        {character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand")},
        {character:FindFirstChild("UpperTorso"), character:FindFirstChild("RightUpperArm")},
        {character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm")},
        {character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand")},
        {character:FindFirstChild("LowerTorso"), character:FindFirstChild("LeftUpperLeg")},
        {character:FindFirstChild("LeftUpperLeg"), character:FindFirstChild("LeftLowerLeg")},
        {character:FindFirstChild("LeftLowerLeg"), character:FindFirstChild("LeftFoot")},
        {character:FindFirstChild("LowerTorso"), character:FindFirstChild("RightUpperLeg")},
        {character:FindFirstChild("RightUpperLeg"), character:FindFirstChild("RightLowerLeg")},
        {character:FindFirstChild("RightLowerLeg"), character:FindFirstChild("RightFoot")}
    }

    for _, connection in ipairs(connections) do
        local part1, part2 = connection[1], connection[2]
        local line = skeleton[part1 and part1.Name or ""]
        if line and part1 and part2 and part1:IsA("BasePart") and part2:IsA("BasePart") then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)

            if onScreen1 and onScreen2 then
                line.Visible = true
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
            else
                line.Visible = false
            end
        elseif line then
            line.Visible = false
        end
    end
end

-- Function to clean up ESP for a player
local function removeSkeleton(skeleton)
    for _, line in pairs(skeleton) do
        line:Remove()
    end
end

-- ESP UI Setup
function ESP:SetupUI(MainTab)
    MainTab:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Flag = "Toggle1", -- Unique flag for the ESP toggle
        Callback = function(Value)
            ESPEnabled = Value
        end
    })
end

-- ESP Runtime Logic
function ESP:Run()
    -- Update ESP on RenderStep
    RunService.RenderStepped:Connect(function()
        if ESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Team ~= Players.LocalPlayer.Team then
                    if not activeESP[player] then
                        activeESP[player] = createSkeleton(player)
                    end
                    updateSkeleton(player, activeESP[player])
                end
            end
        else
            -- Clean up ESP when disabled
            for player, skeleton in pairs(activeESP) do
                removeSkeleton(skeleton)
                activeESP[player] = nil
            end
        end
    end)

    -- Clean up ESP when a player leaves
    Players.PlayerRemoving:Connect(function(player)
        if activeESP[player] then
            removeSkeleton(activeESP[player])
            activeESP[player] = nil
        end
    end)
end

return ESP
