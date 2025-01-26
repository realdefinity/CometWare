-- ESP Module
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Variables
local ESPEnabled = false
local activeESP = {}
local ESPColor = Color3.fromRGB(255, 0, 0) -- Default color: red
local ESPThickness = 2 -- Default thickness
local Transparency = 1 -- Line transparency

-- Helper: Debugging function (uses `debug` for cleaner logging)
local function debug(message)
    print("[ESP Debug]: " .. message)
end

-- Helper: Cache handling
local cache = {}
cache.iscached = function(name)
    return activeESP[name] ~= nil
end

cache.invalidate = function(name)
    if cache.iscached(name) then
        activeESP[name] = nil
        debug("Invalidated cache for player: " .. name)
    end
end

-- Helper: Create a line for skeletons
local function createLine()
    local line = Drawing.new("Line")
    line.Color = ESPColor
    line.Thickness = ESPThickness
    line.Transparency = Transparency
    return line
end

-- Helper: Create skeleton lines for a player
local function createSkeleton(player)
    debug("Creating skeleton for player: " .. player.Name)
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

-- Helper: Update the skeleton for a player
local function updateSkeleton(player, skeleton)
    local character = player.Character
    if not character then
        cache.invalidate(player.Name)
        return
    end

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
        if part1 and part2 and part1:IsA("BasePart") and part2:IsA("BasePart") then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)

            local line = skeleton[part1.Name]
            if line and onScreen1 and onScreen2 then
                line.Visible = true
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
            elseif line then
                line.Visible = false
            end
        end
    end
end

-- Helper: Remove ESP for a player
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
        Flag = "ESP_Toggle",
        Callback = function(Value)
            ESPEnabled = Value
            if not Value then
                for _, skeleton in pairs(activeESP) do
                    removeSkeleton(skeleton)
                end
                activeESP = {}
            end
        end
    })

    MainTab:CreateColorPicker({
        Name = "ESP Color",
        CurrentValue = ESPColor,
        Flag = "ESP_Color",
        Callback = function(Value)
            ESPColor = Value
            for _, skeleton in pairs(activeESP) do
                for _, line in pairs(skeleton) do
                    line.Color = ESPColor
                end
            end
        end
    })

    MainTab:CreateSlider({
        Name = "ESP Line Thickness",
        Range = {1, 5},
        Increment = 0.5,
        CurrentValue = ESPThickness,
        Flag = "ESP_Thickness",
        Callback = function(Value)
            ESPThickness = Value
            for _, skeleton in pairs(activeESP) do
                for _, line in pairs(skeleton) do
                    line.Thickness = ESPThickness
                end
            end
        end
    })
end

-- ESP Runtime Logic
function ESP:Run()
    RunService.RenderStepped:Connect(function()
        if ESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Team ~= Players.LocalPlayer.Team then
                    if not activeESP[player.Name] then
                        activeESP[player.Name] = createSkeleton(player)
                    end
                    updateSkeleton(player, activeESP[player.Name])
                end
            end
        end
    end)

    -- Cleanup when players leave
    Players.PlayerRemoving:Connect(function(player)
        if activeESP[player.Name] then
            removeSkeleton(activeESP[player.Name])
            activeESP[player.Name] = nil
        end
    end)
end

return ESP
-- crer34342
