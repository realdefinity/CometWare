-- ESP Module
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Variables
local ESPEnabled = false
local activeESP = {}

local function debug(msg)
    print("[ESP Debug]: " .. msg)
end

local function createLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Transparency = 1
    line.Color = Color3.fromRGB(255, 255, 255)
    return line
end

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

local function updateSkeleton(player, skeleton)
    local character = player.Character
    if not character then return end

    for partName, line in pairs(skeleton) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(part.Position)
            if onScreen1 then
                line.Visible = true
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos1.X, pos1.Y - 10)
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

function ESP:SetupUI(MainTab)
    MainTab:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Flag = "Toggle1",
        Callback = function(Value)
            debug("ESP Toggle: " .. tostring(Value))
            ESPEnabled = Value
        end
    })
end

function ESP:Run()
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
            for player, skeleton in pairs(activeESP) do
                for _, line in pairs(skeleton) do
                    line:Remove()
                end
                activeESP[player] = nil
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if activeESP[player] then
            for _, line in pairs(activeESP[player]) do
                line:Remove()
            end
            activeESP[player] = nil
        end
    end)
end

return ESP

