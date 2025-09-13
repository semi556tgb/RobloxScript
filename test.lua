-- test.lua - ESP core (UI-based box-only ESP)
-- Returns a module table with ToggleESP, refresh_elements, Destroy

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local MODULE = {}
MODULE._internal = {}
MODULE.Enabled = true
MODULE.MaxDistance = 200
MODULE.Objects = {} -- map: player -> ui objects
MODULE._screenGui = nil
MODULE._connections = {}
MODULE._settings = {
    BoxType = "Corner", -- "Corner" or "Full"
    BoxColor = Color3.fromRGB(255,255,255),
    BoxOutline = Color3.fromRGB(0,0,0),
    Filled = true,
    FillColor = Color3.fromRGB(0,0,0),
    FillTransparency = 0.75,
    Animate = true,
    RotationSpeed = 300,
}

-- Helper: try to read flags from your UI library if present
local function sync_from_library_flags()
    if type(_G) == "table" and type(_G.library) == "table" then
        -- nothing global; keep safe
    end
    -- many UIs put flags in a global table called "library" or similar
    -- we'll attempt a few safe lookups (pcall) but won't error if not present
    local ok, flags = pcall(function() return library and library.flags end)
    if ok and type(flags) == "table" then
        local f = flags
        if f.Box_Type then MODULE._settings.BoxType = f.Box_Type end
        if f.Box_Color then
            pcall(function() MODULE._settings.BoxColor = f.Box_Color end)
        end
        if f.Box_Outline then
            pcall(function() MODULE._settings.BoxOutline = f.Box_Outline end)
        end
        -- allow toggles for filled
        -- some UIs might store boolean or other names; safe defaults used otherwise
    end
end

local function Create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

-- Create the ScreenGui holder
local function CreateScreenGui()
    if MODULE._screenGui and MODULE._screenGui.Parent then return MODULE._screenGui end
    local sg = Create("ScreenGui", {
        Name = "ESP_UI_HOLDER",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = CoreGui,
    })
    MODULE._screenGui = sg
    return sg
end

-- Fade helper (keeps a minimum visible)
local function apply_fade_to_frame(frame, distance)
    local transparency = math.max(0.05, 1 - (distance / MODULE.MaxDistance))
    frame.BackgroundTransparency = 1 - transparency
end
local function apply_fade_to_stroke(stroke, distance)
    if stroke then stroke.Transparency = 1 - math.max(0.05, 1 - (distance / MODULE.MaxDistance)) end
end

-- Create UI objects for a player
local function make_player_ui(plr)
    if MODULE.Objects[plr] then return end
    local screen = CreateScreenGui()
    local baseName = "ESP_" .. plr.UserId .. "_" .. plr.Name

    local box = Create("Frame", {
        Name = baseName .. "_Box",
        Parent = screen,
        BackgroundColor3 = MODULE._settings.FillColor,
        BackgroundTransparency = MODULE._settings.FillTransparency,
        BorderSizePixel = 0,
        Visible = MODULE.Enabled,
        ZIndex = 2,
    })

    local stroke = Create("UIStroke", {
        Parent = box,
        Color = MODULE._settings.BoxOutline,
        Thickness = 1,
        Transparency = 0,
        LineJoinMode = Enum.LineJoinMode.Miter,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })

    -- corner pieces (for "Corner" style)
    local corners = {}
    for i=1,8 do
        corners[i] = Create("Frame", {
            Parent = screen,
            BackgroundColor3 = MODULE._settings.BoxColor,
            BorderSizePixel = 0,
            Visible = MODULE.Enabled,
            ZIndex = 2,
        })
    end

    MODULE.Objects[plr] = {
        Frame = box,
        Stroke = stroke,
        Corners = corners,
        Player = plr,
        Rotation = -45,
    }
end

-- Remove UI for a player
local function remove_player_ui(plr)
    local obj = MODULE.Objects[plr]
    if not obj then return end
    if obj.Frame and obj.Frame.Parent then obj.Frame:Destroy() end
    if obj.Stroke and obj.Stroke.Parent then obj.Stroke:Destroy() end
    for _,c in pairs(obj.Corners or {}) do
        if c and c.Parent then c:Destroy() end
    end
    MODULE.Objects[plr] = nil
end

-- Hide all (but keep objects)
function MODULE.ToggleESP(state)
    MODULE.Enabled = state and true or false
    if MODULE._screenGui then
        for _,child in pairs(MODULE._screenGui:GetChildren()) do
            -- some objects might be non-frame; keep it simple: set Visible for frames
            if child:IsA("Frame") then
                child.Visible = MODULE.Enabled
            end
        end
    end
end

-- Destroy everything (full cleanup)
function MODULE.Destroy()
    -- disconnect connections
    for _,c in pairs(MODULE._connections) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        end
    end
    MODULE._connections = {}
    -- destroy UI
    if MODULE._screenGui then
        pcall(function() MODULE._screenGui:Destroy() end)
        MODULE._screenGui = nil
    end
    -- clear objects
    MODULE.Objects = {}
end

-- Called by UI to re-read options (box type, colors, etc.)
function MODULE.refresh_elements()
    sync_from_library_flags()
    -- update existing UI element colors/types
    for plr, obj in pairs(MODULE.Objects) do
        if obj.Frame then
            obj.Frame.BackgroundColor3 = MODULE._settings.Filled and MODULE._settings.FillColor or Color3.new(0,0,0)
            obj.Frame.BackgroundTransparency = MODULE._settings.Filled and MODULE._settings.FillTransparency or 1
        end
        if obj.Stroke then
            obj.Stroke.Color = MODULE._settings.BoxOutline
        end
        for _,c in pairs(obj.Corners or {}) do
            c.BackgroundColor3 = MODULE._settings.BoxColor
        end
    end
end

-- Build/update _settings from current library flags (if available)
sync_from_library_flags()
-- listen for players
local function on_player_added(plr)
    if plr == LocalPlayer then return end
    make_player_ui(plr)
end
local function on_player_remove(plr)
    remove_player_ui(plr)
end

-- init existing players
for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        make_player_ui(p)
    end
end
table.insert(MODULE._connections, Players.PlayerAdded:Connect(on_player_added))
table.insert(MODULE._connections, Players.PlayerRemoving:Connect(on_player_remove))

-- Main render loop: update positions & visibility
local renderConn = RunService.RenderStepped:Connect(function(dt)
    if not MODULE._screenGui then return end
    -- attempt to keep settings up-to-date (in case UI changes)
    sync_from_library_flags()

    for plr, obj in pairs(MODULE.Objects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            if obj.Frame then obj.Frame.Visible = false end
            for _,c in pairs(obj.Corners) do c.Visible = false end
        else
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            if onScreen and dist <= MODULE.MaxDistance and MODULE.Enabled then
                -- build approximate box size
                local Size = hrp.Size.Y
                local scaleFactor = (Size * Camera.ViewportSize.Y) / (pos.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                -- Full box handling
                if MODULE._settings.BoxType == "Full" then
                    if obj.Frame then
                        obj.Frame.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)
                        obj.Frame.Size = UDim2.new(0, w, 0, h)
                        obj.Frame.BackgroundColor3 = MODULE._settings.FillColor
                        obj.Frame.BackgroundTransparency = MODULE._settings.Filled and MODULE._settings.FillTransparency or 1
                        obj.Frame.Visible = true
                    end
                    for _,c in pairs(obj.Corners) do c.Visible = false end
                else
                    -- Corner boxes
                    if obj.Frame then obj.Frame.Visible = false end
                    local cx, cy = pos.X - w/2, pos.Y - h/2
                    -- top-left horizontal
                    local c1 = obj.Corners[1]; c1.Size = UDim2.new(0, w/5, 0, 1); c1.Position = UDim2.new(0, cx, 0, cy); c1.Visible = true
                    -- top-left vertical
                    local c2 = obj.Corners[2]; c2.Size = UDim2.new(0, 1, 0, h/5); c2.Position = UDim2.new(0, cx, 0, cy); c2.Visible = true
                    -- bottom-left vertical
                    local c3 = obj.Corners[3]; c3.Size = UDim2.new(0, 1, 0, h/5); c3.Position = UDim2.new(0, cx, 0, cy + h); c3.Visible = true
                    -- bottom-left horizontal
                    local c4 = obj.Corners[4]; c4.Size = UDim2.new(0, w/5, 0, 1); c4.Position = UDim2.new(0, cx, 0, cy + h); c4.Visible = true
                    -- top-right horizontal
                    local c5 = obj.Corners[5]; c5.Size = UDim2.new(0, w/5, 0, 1); c5.Position = UDim2.new(0, cx + w, 0, cy); c5.Visible = true
                    -- top-right vertical
                    local c6 = obj.Corners[6]; c6.Size = UDim2.new(0, 1, 0, h/5); c6.Position = UDim2.new(0, cx + w - 1, 0, cy); c6.Visible = true
                    -- bottom-right horizontal
                    local c7 = obj.Corners[7]; c7.Size = UDim2.new(0, w/5, 0, 1); c7.Position = UDim2.new(0, cx + w, 0, cy + h); c7.Visible = true
                    -- bottom-right vertical
                    local c8 = obj.Corners[8]; c8.Size = UDim2.new(0, 1, 0, h/5); c8.Position = UDim2.new(0, cx + w - 1, 0, cy + h - (h/5)); c8.Visible = true
                    -- set colors
                    for _,c in pairs(obj.Corners) do c.BackgroundColor3 = MODULE._settings.BoxColor end
                end

                -- fade based on distance
                if obj.Frame then apply_fade_to_frame(obj.Frame, dist) end
                if obj.Stroke then apply_fade_to_stroke(obj.Stroke, dist) end
            else
                if obj.Frame then obj.Frame.Visible = false end
                for _,c in pairs(obj.Corners) do c.Visible = false end
            end
        end
    end
end)
table.insert(MODULE._connections, renderConn)

-- expose API
MODULE.ToggleESP(true) -- start visible by default
MODULE.refresh_elements() -- apply initial settings

-- safe Destroy on unref
MODULE.Destroy = MODULE.Destroy or MODULE.Destroy

return MODULE
