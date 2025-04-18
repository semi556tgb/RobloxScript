-- aimbot.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Target = nil

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(vector.X, vector.Y)).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Key Press Detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not library.flags["AimbotEnabled"] then return end

    if input.KeyCode == library.flags["AimbotKey"] then
        Target = GetClosestPlayer()
    end
end)

-- Lock onto the target
RunService.RenderStepped:Connect(function()
    if not library.flags["AimbotEnabled"] then
        Target = nil
        return
    end

    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.HumanoidRootPart.Position)
    end
end)
