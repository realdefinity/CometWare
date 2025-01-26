-- Auto Shoot Module
local AutoShoot = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local AutoShootEnabled = false
local SilentAimGetClosestTarget = nil -- Function to get the closest target from Silent Aim
local CanShoot = true -- Prevent rapid fire
local ShootCooldown = 0.05 -- Cooldown between shots (lower = faster shooting)

-- Debugging Helper
local function debug(message)
    print("[Auto Shoot Debug]: " .. message)
end

-- Function to fire the weapon
local function fireWeapon()
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then
        debug("Character not found.")
        return
    end

    local tool = character:FindFirstChildOfClass("Tool") -- Finds the equipped weapon
    if tool and tool:FindFirstChild("Handle") then
        debug("Firing weapon...")
        tool:Activate() -- Simulates the left mouse button click
    else
        debug("No weapon found or weapon has no handle.")
    end
end

-- Function to handle the auto-shoot logic
local function autoShootLogic()
    if AutoShootEnabled and SilentAimGetClosestTarget then
        local target = SilentAimGetClosestTarget()
        if target and CanShoot then
            fireWeapon() -- Fire at the target
            CanShoot = false -- Prevent rapid firing
            task.delay(ShootCooldown, function()
                CanShoot = true -- Allow firing again after cooldown
            end)
        end
    end
end

-- UI Setup for Auto Shoot
function AutoShoot:SetupUI(MainTab)
    -- Toggle to enable/disable Auto Shoot
    MainTab:CreateToggle({
        Name = "Enable Auto Shoot",
        CurrentValue = false,
        Flag = "Toggle3", -- Unique flag for Auto Shoot toggle
        Callback = function(Value)
            AutoShootEnabled = Value
            debug("Auto Shoot Enabled: " .. tostring(Value))
        end
    })

    -- Slider for Shoot Cooldown
    MainTab:CreateSlider({
        Name = "Shoot Cooldown",
        Range = {0.01, 0.2}, -- Range for cooldown values
        Increment = 0.01,
        CurrentValue = ShootCooldown,
        Suffix = " sec",
        Flag = "Slider2", -- Unique flag for Shoot Cooldown slider
        Callback = function(Value)
            ShootCooldown = Value
            debug("Shoot Cooldown updated to: " .. tostring(Value) .. " seconds.")
        end
    })
end

-- Runtime Logic for Auto Shoot
function AutoShoot:Run(getClosestTargetFunction)
    -- Store the Silent Aim target detection function
    SilentAimGetClosestTarget = getClosestTargetFunction

    -- Run Auto Shoot logic on every frame
    RunService.RenderStepped:Connect(function()
        autoShootLogic()
    end)
end

return AutoShoot
