-- Silent Aim Module
local SilentAim = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Variables
local SilentAimEnabled = false
local FOV = 300
local TargetPart = "Head" -- The part of the enemy to hit (e.g., "Head" or "HumanoidRootPart")
local FOVCircle = Drawing.new("Circle")

-- FOV Circle Settings
FOVCircle.Visible = false
FOVCircle.Radius = FOV
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 255, 0) -- Default color: green
FOVCircle.Transparency = 1

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
                        closestTarget, shortestDistance = targetPart, distance
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Function to modify bullet trajectory for Silent Aim
local function modifyBulletTrajectory()
    if SilentAimEnabled then
        local target = getClosestTarget()
        if target then
            -- Silent Aim magic: adjusting aim to hit target without moving the camera
            local bulletDirection = (target.Position - Camera.CFrame.Position).Unit
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + bulletDirection * 500)
        end
    end
end

-- UI Setup for Silent Aim
function SilentAim:SetupUI(MainTab)
    -- Toggle for Silent Aim
    MainTab:CreateToggle({
        Name = "Enable Silent Aim",
        CurrentValue = false,
        Flag = "Toggle2", -- Unique flag for Silent Aim
        Callback = function(Value)
            SilentAimEnabled = Value
            FOVCircle.Visible = Value -- Show/hide the FOV circle
        end
    })

    -- Slider to adjust FOV
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
        end
    })

    -- Color Picker for FOV Circle
    MainTab:CreateColorPicker({
        Name = "FOV Circle Color",
        CurrentValue = Color3.fromRGB(0, 255, 0),
        Flag = "ColorPicker1", -- Unique flag for FOV circle color
        Callback = function(Value)
            FOVCircle.Color = Value
        end
    })
end

-- Silent Aim Runtime Logic
function SilentAim:Run()
    -- Update the FOV Circle position
    RunService.RenderStepped:Connect(function()
        if SilentAimEnabled then
            FOVCircle.Position = UserInputService:GetMouseLocation()
        else
            FOVCircle.Visible = false
        end
    end)

    -- Adjust bullet trajectory to always hit the target
    RunService.RenderStepped:Connect(modifyBulletTrajectory)
end

-- Function to expose "getClosestTarget" for external use (e.g., Auto Shoot)
function SilentAim:getClosestTarget()
    return getClosestTarget()
end

return SilentAim
