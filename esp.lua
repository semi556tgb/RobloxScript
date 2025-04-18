local ESP = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

ESP.Enabled = false
ESP.Boxes = {}

function ESP:CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Thickness = 1
    box.Filled = false
    return box
end

function ESP:GetTopAndBottom(character)
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not (head and hrp and humanoid) then return end

    -- Get world positions for top and bottom
    local topWorld = head.Position + Vector3.new(0, head.Size.Y / 2, 0)
    local bottomWorld = hrp.Position - Vector3.new(0, humanoid.HipHeight + hrp.Size.Y / 2, 0)

    local top, topVisible = Camera:WorldToViewportPoint(topWorld)
    local bottom, bottomVisible = Camera:WorldToViewportPoint(bottomWorld)

    if topVisible and bottomVisible then
        local height = math.abs(top.Y - bottom.Y)
        local width = height / 2
        local x = (top.X + bottom.X) / 2 - width / 2
        local y = math.min(top.Y, bottom.Y)
        return Vector2.new(x, y), Vector2.new(width, height)
    end
end

function ESP:Update()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not self.Boxes[player] then
                self.Boxes[player] = self:CreateBox()
            end

            local box = self.Boxes[player]
            local position, size = self:GetTopAndBottom(player.Character)

            if position and size then
                box.Position = position
                box.Size = size
                box.Visible = self.Enabled
            else
                box.Visible = false
            end
        elseif self.Boxes[player] then
            self.Boxes[player].Visible = false
        end
    end
end

function ESP:Clear()
    for _, box in pairs(self.Boxes) do
        if box then
            box:Remove()
        end
    end
    self.Boxes = {}
end

function ESP:Enable()
    self.Enabled = true
end

function ESP:Disable()
    self.Enabled = false
    for _, box in pairs(self.Boxes) do
        if box then
            box.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        ESP:Update()
    end
end)

return ESP
