local ESP = {}
ESP.Enabled = false
ESP.Boxes = {}
ESP.Color = Color3.fromRGB(0, 255, 0)

function ESP:SetColor(color)
    self.Color = color
end

function ESP:Enable()
    self.Enabled = true
    self:Run()
end

function ESP:Disable()
    self.Enabled = false
    self:Clear()
end

function ESP:Clear()
    for player, drawing in pairs(self.Boxes) do
        if drawing and drawing.Box then
            drawing.Box:Remove()
        end
        self.Boxes[player] = nil
    end
end

function ESP:Run()
    task.spawn(function()
        while self.Enabled do
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

                    if not self.Boxes[player] then
                        self.Boxes[player] = {
                            Box = Drawing.new("Square")
                        }
                        self.Boxes[player].Box.Thickness = 2
                        self.Boxes[player].Box.Filled = false
                        self.Boxes[player].Box.Color = self.Color
                    end

                    local box = self.Boxes[player].Box

                    if onScreen then
                        local scale = 3 -- Size adjuster
                        local height = math.clamp((workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude, 2, 30) * scale
                        local width = height / 2

                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                        box.Color = self.Color
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                elseif self.Boxes[player] then
                    self.Boxes[player].Box:Remove()
                    self.Boxes[player] = nil
                end
            end

            -- Clean up for players who left
            for trackedPlayer, drawings in pairs(self.Boxes) do
                if not game.Players:FindFirstChild(trackedPlayer.Name) then
                    if drawings.Box then drawings.Box:Remove() end
                    self.Boxes[trackedPlayer] = nil
                end
            end

            task.wait()
        end

        self:Clear()
    end)
end

function ESP:Destroy()
    self.Enabled = false
    self:Clear()
end

return ESP
