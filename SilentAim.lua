-- Silent Aim Module
local SilentAim = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Variables
local SilentAimEnabled = false
local FOV = 300
local TargetPart = "Head" -- Part of the enemy to hit (e.g., "Head", "HumanoidRootPart")
local FOVCircle = Drawing.new("Circle")
local CurrentTarget = nil

-- FOV Circle Settings
FOVCircle.Visible = false
FOVCircle.Radius = FOV
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0) -- Default color: red
FOVCircle.Transparency = 1

-- Helper: Debugging Messages
local function debug(message)
    print("[Silent Aim Debug]: " .. message)
end

-- Function to find the closest target within the FOV
local function getClosestTarget()
    local closestTarget, shortestDistance = nil, FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Team ~= Players.LocalPlayer.Team then
            local character = player.Character
            local targetPart = character and character:FindFirstChild(TargetPart)
            local humanoid = character and character:FindFirstChild("Humanoid")

            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    if distance < shortestDistance then
                        closestTarget = targetPart
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Function to calculate the direction for Silent Aim
local function calculateAimDirection(target)
    local targetPosition = target.Position
    local cameraPosition = Camera.CFrame.Position
    return (targetPosition - cameraPosition).Unit -- Unit vector for direction
end

-- Function to apply Silent Aim logic
local function applySilentAim()
    if SilentAimEnabled then
        CurrentTarget = getClosestTarget()
        if CurrentTarget then
            -- Modify the bullet trajectory or targeting direction
            local aimDirection = calculateAimDirection(CurrentTarget)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + aimDirection * 500) -- Aim at target
            debug("Target locked onto: " .. CurrentTarget.Parent.Name)
        else
            debug("No valid target found.")
        end
    else
        CurrentTarget = nil -- Reset target when Silent Aim is disabled
    end
end

-- UI Setup for Silent Aim
function SilentAim:SetupUI(MainTab)
    -- Toggle to enable/disable Silent Aim
    MainTab:CreateToggle({
        Name = "Enable Silent Aim",
        CurrentValue = false,
        Flag = "Toggle2", -- Unique flag for Silent Aim toggle
        Callback = function(Value)
            SilentAimEnabled = Value
            FOVCircle.Visible = Value
            debug("Silent Aim Enabled: " .. tostring(Value))
        end
    })

    -- Slider to adjust the Field of View (FOV)
    MainTab:CreateSlider({
        Name = "Field of View",
        Range = {100, 1000},
        Increment = 10,
        Suffix = " px",
        CurrentValue = FOV,
        Flag = "Slider1", -- Unique flag for FOV slider
        Callback = function(Value)
            FOV = Value
            FOVCircle.Radius = Value
            debug("FOV updated to: " .. Value)
        end
    })

    -- Color picker for FOV Circle
    MainTab:CreateColorPicker({
        Name = "FOV Circle Color",
        CurrentValue = FOVCircle.Color,
        Flag = "ColorPicker1", -- Unique flag for FOV circle color
        Callback = function(Value)
            FOVCircle.Color = Value
            debug("FOV Circle Color updated.")
        end
    })
end

-- Runtime Logic for Silent Aim
function SilentAim:Run()
    -- Update FOV Circle position and logic on every frame
    RunService.RenderStepped:Connect(function()
        if SilentAimEnabled then
            FOVCircle.Position = UserInputService:GetMouseLocation()
            applySilentAim() -- Apply Silent Aim
        else
            FOVCircle.Visible = false -- Hide the FOV circle when disabled
        end
    end)
end

-- Expose the closest target function for external use (e.g., Auto Shoot)
function SilentAim:getClosestTarget()
    return getClosestTarget()
end

return SilentAim
