local Aimbot = {}
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local aimbotEnabled = false
local target = nil
local keybind = Enum.KeyCode.E  -- Change this to your desired key!

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local localPlayer = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

local function AimAtTarget(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local camera = workspace.CurrentCamera
        local hrpPosition = targetPlayer.Character.HumanoidRootPart.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, hrpPosition)
    end
end

-- Toggle Aimbot Keybind Logic
UserInputService.InputBegan:Connect(function(input, typing)
    if typing then return end
    if input.KeyCode == keybind then
        aimbotEnabled = not aimbotEnabled
        if aimbotEnabled then
            target = GetClosestPlayer()
            print("Aimbot: Locked onto", target and target.Name or "No target found.")
        else
            target = nil
            print("Aimbot: Unlocked.")
        end
    end
end)

-- Smooth Aimbot Loop
RunService.RenderStepped:Connect(function()
    if aimbotEnabled and target then
        AimAtTarget(target)
    end
end)

return Aimbot
