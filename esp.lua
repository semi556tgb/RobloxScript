-- esp.lua
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

ESP.Enabled = false
ESP.Boxes = {}
ESP.Settings = {
    Color = Color3.fromRGB(0, 255, 0)
}

function ESP:Clear()
    for _, box in pairs(self.Boxes) do
        if box and box.Remove then
            box:Remove()
        end
    end
    self.Boxes = {}
end

function ESP:Enable()
    self.Enabled = true
    if not self.Connection then
        self:Start()
    end
end

function ESP:Disable()
    self.Enabled = false
    self:Clear()
end

function ESP:SetColor(color)
    self.Settings.Color = color
end

function ESP:Start()
    if self.Connection then return end

    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end

        -- Clean old boxes first
        for i = #self.Boxes, 1, -1 do
            local box = self.Boxes[i]
            if box.Player and (not box.Player.Parent or not Players:FindFirstChild(box.Player.Name)) then
                if box.Drawing and box.Drawing.Remove then
                    box.Drawing:Remove()
                end
                table.remove(self.Boxes, i)
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local exists = false
                for _, b in pairs(self.Boxes) do
                    if b.Player == player then
                        exists = true
                        break
                    end
                end

                if not exists then
                    local newBox = Drawing.new("Square")
                    newBox.Thickness = 1
                    newBox.Transparency = 1
                    newBox.Color = self.Settings.Color
                    table.insert(self.Boxes, {Drawing = newBox, Player = player})
                end
            end
        end

        for _, box in pairs(self.Boxes) do
            if box.Player and box.Player.Character and box.Player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = box.Player.Character.HumanoidRootPart
                local humanoid = box.Player.Character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    local min = hrp.Position - Vector3.new(2, 3, 0)
                    local max = hrp.Position + Vector3.new(2, 3, 0)

                    local min2d, minOnScreen = Camera:WorldToViewportPoint(min)
                    local max2d, maxOnScreen = Camera:WorldToViewportPoint(max)

                    if minOnScreen or maxOnScreen then
                        local size = Vector2.new(math.abs(max2d.X - min2d.X), math.abs(max2d.Y - min2d.Y))
                        local pos = Vector2.new((min2d.X + max2d.X) / 2 - size.X / 2, (min2d.Y + max2d.Y) / 2 - size.Y / 2)

                        box.Drawing.Size = size
                        box.Drawing.Position = pos
                        box.Drawing.Color = self.Settings.Color
                        box.Drawing.Visible = true
                    else
                        box.Drawing.Visible = false
                    end
                end
            elseif box.Drawing then
                box.Drawing.Visible = false
            end
        end
    end)
end

function ESP:Destroy()
    self:Disable()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

return ESP
