-- Auto Shoot Module
local AutoShoot = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local AutoShootEnabled = false
local CanShoot = true -- To prevent rapid firing
local SilentAimGetClosestTarget = nil -- Will store the getClosestTarget function from Silent Aim

-- Function to fire the weapon
local function fireWeapon()
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end

    local tool = character:FindFirstChildOfClass("Tool") -- Finds the equipped weapon
    if tool and tool:FindFirstChild("Handle") then
        tool:Activate() -- Simulates left mouse click to fire the weapon
    end
end

-- Auto Shoot Logic
local function autoShootLogic()
    if AutoShootEnabled and SilentAimGetClosestTarget then
        local target = SilentAimGetClosestTarget() -- Get the closest target from Silent Aim
        if target and CanShoot then
            fireWeapon()
            CanShoot = false
            -- Add a slight cooldown to prevent firing too rapidly
            task.delay(0.1, function() -- Adjust the delay as needed
                CanShoot = true
            end)
        end
    end
end

-- UI Setup for Auto Shoot
function AutoShoot:SetupUI(MainTab)
    -- Toggle for Auto Shoot
    MainTab:CreateToggle({
        Name = "Enable Auto Shoot",
        CurrentValue = false,
        Flag = "Toggle3", -- Unique flag for Auto Shoot
        Callback = function(Value)
            AutoShootEnabled = Value
        end
    })
end

-- Auto Shoot Runtime Logic
function AutoShoot:Run(getClosestTargetFunction)
    -- Store the Silent Aim function for getting the closest target
    SilentAimGetClosestTarget = getClosestTargetFunction

    -- Run Auto Shoot logic on every frame
    RunService.RenderStepped:Connect(autoShootLogic)
end

return AutoShoot
