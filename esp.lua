--// Optimized ESP Script with Auto-Cleanup and Color Picker

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Color = Color3.fromRGB(0, 255, 0)
ESP.Enabled = false
ESP.Boxes = {}

-- Create Box Drawing
local function CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP.Color
    box.Thickness = 1
    box.Transparency = 1
    return box
end

-- Update ESP Boxes
local function UpdateESP()
    for player, box in pairs(ESP.Boxes) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, visible = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if visible then
                local size = Vector3.new(2, 3, 1.5) * (workspace.CurrentCamera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude / 15
                box.Size = Vector2.new(80 / pos.Z, 150 / pos.Z)
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Color = ESP.Color
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

-- Add ESP for a Player
function ESP:AddPlayer(player)
    if player == LocalPlayer then return end
    if not ESP.Boxes[player] then
        ESP.Boxes[player] = CreateBox()
    end
end

-- Remove ESP for a Player
function ESP:RemovePlayer(player)
    if ESP.Boxes[player] then
        ESP.Boxes[player]:Remove()
        ESP.Boxes[player] = nil
    end
end

-- Connection Setup
Players.PlayerAdded:Connect(function(player)
    ESP:AddPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    ESP:RemovePlayer(player)
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        UpdateESP()
    else
        for _, box in pairs(ESP.Boxes) do
            box.Visible = false
        end
    end
end)

-- Initialize Existing Players
for _, player in pairs(Players:GetPlayers()) do
    ESP:AddPlayer(player)
end

-- Tokyo UI Example Child Box 2 Color Picker
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/TokyoLib/main/source.lua"))()
local Window = Library:Window("Your Cheat Name", "Private", Color3.fromRGB(255, 0, 0), Enum.KeyCode.RightControl)
local Visuals = Window:Tab("Visuals")
local ChildBox2 = Visuals:Section("Child Box 2")

ChildBox2:Toggle("ESP", false, function(state)
    ESP.Enabled = state
end)

ChildBox2:Colorpicker("ESP Color", Color3.fromRGB(0, 255, 0), function(color)
    ESP.Color = color
end)

return ESP
