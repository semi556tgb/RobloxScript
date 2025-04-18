-- aimbot.lua

local Aimbot = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

Aimbot.Enabled = false
Aimbot.TeamCheck = true
Aimbot.FOV = 150
Aimbot.Smoothness = 0.2
Aimbot.LockedTarget = nil

Aimbot.Key = Enum.KeyCode.E
Aimbot.IsAiming = false

function Aimbot:GetClosestTarget()
    local closest = nil
    local shortestDistance = Aimbot.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if not Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local rootPosition = player.Character.HumanoidRootPart.Position
                    local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPosition)

                    if onScreen then
                        local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
                        local dist = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePos).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closest = player
                        end
                    end
                end
            end
        end
    end

    return closest
end

function Aimbot:AimAt(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = target.Character.HumanoidRootPart.Position
        local currentDirection = Camera.CFrame.LookVector
        local aimDirection = (targetPosition - Camera.CFrame.Position).Unit
        local smoothDirection = currentDirection:Lerp(aimDirection, Aimbot.Smoothness)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + smoothDirection)
    end
end

function Aimbot:BindToRenderStep()
    RunService:UnbindFromRenderStep("Aimbot")
    RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value, function()
        if Aimbot.Enabled and Aimbot.IsAiming then
            if not Aimbot.LockedTarget or not Aimbot.LockedTarget.Character
                or not Aimbot.LockedTarget.Character:FindFirstChild("HumanoidRootPart")
                or Aimbot.LockedTarget.Character.Humanoid.Health <= 0 then

                Aimbot.LockedTarget = Aimbot:GetClosestTarget()
            end

            if Aimbot.LockedTarget then
                Aimbot:AimAt(Aimbot.LockedTarget)
            end
        else
            Aimbot.LockedTarget = nil
        end
    end)
end

function Aimbot:Enable()
    Aimbot.Enabled = true
    Aimbot:BindToRenderStep()
end

function Aimbot:Disable()
    Aimbot.Enabled = false
    RunService:UnbindFromRenderStep("Aimbot")
    Aimbot.LockedTarget = nil
    Aimbot.IsAiming = false
end

function Aimbot:SetKey(newKey)
    Aimbot.Key = newKey
end

function Aimbot:SetFOV(newFOV)
    Aimbot.FOV = newFOV
end

function Aimbot:SetSmoothness(newValue)
    Aimbot.Smoothness = newValue
end

function Aimbot:SetTeamCheck(state)
    Aimbot.TeamCheck = state
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Aimbot.Key then
        Aimbot.IsAiming = not Aimbot.IsAiming
        if not Aimbot.IsAiming then
            Aimbot.LockedTarget = nil
        end
    end
end)

return Aimbot
