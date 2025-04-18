local ESP = {}
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
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

                if onScreen and humanoid then
                    local height = math.clamp(3000 / (hrp.Position - workspace.CurrentCamera.CFrame.Position).Magnitude, 20, 250)
                    local width = height / 2

                    local box = Drawing.new("Square")
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 1.1)
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
