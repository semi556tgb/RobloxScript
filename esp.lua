local ESP = {}
local Drawing = Drawing or {}

ESP.Enabled = false
ESP.Boxes = {}

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
    self:Start()
end

function ESP:Disable()
    self.Enabled = false
    self:Clear()
end

function ESP:Start()
    if self.Connection then return end

    self.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not self.Enabled then return end
        self:Clear()

        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    local box = Drawing.new("Square")
                    box.Size = Vector2.new(50, 50)
                    box.Position = Vector2.new(vector.X - 25, vector.Y - 25)
                    box.Color = Color3.fromRGB(0, 255, 0)
                    box.Thickness = 1
                    box.Transparency = 1
                    box.Visible = true

                    table.insert(self.Boxes, box)
                end
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
