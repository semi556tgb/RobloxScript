-- aimbot.lua

local Aimbot = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

Aimbot.Enabled = false
Aimbot.Key = Enum.KeyCode.E
Aimbot.TeamCheck = true
Aimbot.FOV = 150
Aimbot.LockedTarget = nil
Aimbot.Smoothness = 0.2

function Aimbot:GetClosestTarget()
    local closest = nil
    local shortestDistance = Aimbot.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character.Humanoid.Health > 0 then
                if not Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local rootPos = player.Character.HumanoidRootPart.Position
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)

                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
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
        local newDirection = currentDirection:Lerp(aimDirection, Aimbot.Smoothness)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newDirection)
    end
end

function Aimbot:BindToRenderStep()
    RunService:UnbindFromRenderStep("Aimbot")
    RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value, function()
        if Aimbot.Enabled and UserInputService:IsKeyDown(Aimbot.Key) then
            if not Aimbot.LockedTarget or not Aimbot.LockedTarget.Character or not Aimbot.LockedTarget.Character:FindFirstChild("HumanoidRootPart") then
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

return Aimbot
