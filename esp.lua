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

function ESP:GetBoundingBox(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local position = hrp.Position
    local height = humanoid.HipHeight + hrp.Size.Y + 2.5 -- Adjusting for R6/R15 scaling
    local base = position - Vector3.new(0, height / 2, 0)
    local top = position + Vector3.new(0, height / 2, 0)

    local topPos, topOnScreen = Camera:WorldToViewportPoint(top)
    local basePos, baseOnScreen = Camera:WorldToViewportPoint(base)

    if topOnScreen and baseOnScreen then
        local boxHeight = math.abs(topPos.Y - basePos.Y)
        local boxWidth = boxHeight / 2
        local x = topPos.X - boxWidth / 2
        local y = topPos.Y
        return Vector2.new(x, y), Vector2.new(boxWidth, boxHeight)
    end
end

function ESP:Update()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not self.Boxes[player] then
                self.Boxes[player] = self:CreateBox()
            end

            local box = self.Boxes[player]
            local position, size = self:GetBoundingBox(player.Character)

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
