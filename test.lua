local Workspace, RunService, Players, CoreGui =
    cloneref(game:GetService("Workspace")),
    cloneref(game:GetService("RunService")),
    cloneref(game:GetService("Players")),
    game:GetService("CoreGui")

local ESP = {
    Enabled = true, -- 🔴 Master ON/OFF switch
    MaxDistance = 200,
    Drawing = {
        Boxes = {
            Gradient = false,
            GradientRGB1 = Color3.fromRGB(119, 120, 255),
            GradientRGB2 = Color3.fromRGB(0, 0, 0),
            GradientFill = true,
            GradientFillRGB1 = Color3.fromRGB(119, 120, 255),
            GradientFillRGB2 = Color3.fromRGB(0, 0, 0),
            Filled = {
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        };
    };
    Connections = { RunService = RunService };
}

-- Vars
local lplayer = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

-- Create ScreenGui holder
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPHolder"
ScreenGui.Parent = CoreGui

-- Utility
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

-- Toggle ALL ESP visibility
local function ToggleESP(state)
    ESP.Enabled = state
    for _, child in pairs(ScreenGui:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = state
        end
    end
end

-- Create Box for Player
local function BoxESP(plr)
    local Box = Create("Frame", {
        Parent = ScreenGui,
        Name = plr.Name .. "_Box",
        BackgroundColor3 = ESP.Drawing.Boxes.Filled.RGB,
        BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency,
        BorderSizePixel = 0,
        Visible = ESP.Enabled,
    })
    local Outline = Create("UIStroke", {
        Parent = Box,
        Transparency = 0,
        Color = ESP.Drawing.Boxes.Full.RGB,
    })

    RunService.RenderStepped:Connect(function()
        if not ESP.Enabled then
            Box.Visible = false
            return
        end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = plr.Character.HumanoidRootPart
            local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
            local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714

            if OnScreen and Dist <= ESP.MaxDistance then
                local Size = HRP.Size.Y
                local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                Box.Size = UDim2.new(0, w, 0, h)
                Box.Visible = true
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
    end)
end

-- Init ESP for all current players
for _, v in pairs(Players:GetPlayers()) do
    if v ~= lplayer then
        BoxESP(v)
    end
end
Players.PlayerAdded:Connect(function(v)
    if v ~= lplayer then
        BoxESP(v)
    end
end)

-- Example toggle calls
-- ToggleESP(true)   -- turn ON
-- ToggleESP(false)  -- turn OFF
