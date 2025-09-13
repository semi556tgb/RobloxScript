-- // test.lua - ESP Core Script
-- returns a module with ToggleESP and refresh_elements

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Enabled = true
ESP.MaxDistance = 200
ESP.Objects = {} -- store player UI frames

-- ScreenGui Holder
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- Utility
local function Create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props) do inst[k] = v end
    return inst
end

-- Cleanup ESP for a player
local function RemoveESP(plr)
    if ESP.Objects[plr] then
        ESP.Objects[plr].Frame:Destroy()
        ESP.Objects[plr] = nil
    end
end

-- Create ESP for a player
local function AddESP(plr)
    if ESP.Objects[plr] then return end
    local frame = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Visible = ESP.Enabled
    })
    local stroke = Create("UIStroke", {
        Parent = frame,
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
    })
    ESP.Objects[plr] = {Frame = frame, Stroke = stroke}
end

-- Update loop
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _,obj in pairs(ESP.Objects) do
            obj.Frame.Visible = false
        end
        return
    end
    for plr, obj in pairs(ESP.Objects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            if vis and dist <= ESP.MaxDistance then
                local size = 3
                local scale = 250 / pos.Z
                local w, h = 30 * scale, 50 * scale
                obj.Frame.Size = UDim2.new(0, w, 0, h)
                obj.Frame.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)
                obj.Frame.Visible = true
            else
                obj.Frame.Visible = false
            end
        else
            obj.Frame.Visible = false
        end
    end
end)

-- Player connections
for _,plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then AddESP(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then AddESP(plr) end
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- Public API
function ESP.ToggleESP(state)
    ESP.Enabled = state
    for _,obj in pairs(ESP.Objects) do
        obj.Frame.Visible = state
    end
end

function ESP.refresh_elements()
    -- placeholder for UI sync, if needed
end

return ESP
