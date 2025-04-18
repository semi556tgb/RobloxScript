local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESP = {}
ESP.Enabled = true
ESP.Boxes = {}

function ESP:CreateBox(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Transparency = 1
    self.Boxes[player] = box
end

function ESP:RemoveBox(player)
    if self.Boxes[player] then
        self.Boxes[player]:Remove()
        self.Boxes[player] = nil
    end
end

function ESP:UpdateBox(player)
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        local position, visible = Camera:WorldToViewportPoint(hrp.Position)

        if visible then
            local scale = (Camera.CFrame.Position - hrp.Position).Magnitude
            local size = math.clamp(1000 / scale, 20, 300)

            local box = self.Boxes[player]
            box.Size = Vector2.new(size, size * 1.6)
            box.Position = Vector2.new(position.X - size / 2, position.Y - size * 1.6 / 2)
            box.Visible = self.Enabled
        else
            self.Boxes[player].Visible = false
        end
    else
        if self.Boxes[player] then
            self.Boxes[player].Visible = false
        end
    end
end

function ESP:Update()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if not self.Boxes[player] then
                self:CreateBox(player)
            end
            self:UpdateBox(player)
        end
    end

    -- Clean up boxes for players that left
    for trackedPlayer, _ in pairs(self.Boxes) do
        if not Players:FindFirstChild(trackedPlayer.Name) then
            self:RemoveBox(trackedPlayer)
        end
    end
end

RunService.Heartbeat:Connect(function()
    ESP:Update()
end)

Players.PlayerRemoving:Connect(function(player)
    ESP:RemoveBox(player)
end)

return ESP
