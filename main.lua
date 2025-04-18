-- Load your feature modules
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/semi556tgb/RobloxScript/main/aimbot.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/semi556tgb/RobloxScript/main/esp.lua"))()
local Tracers = loadstring(game:HttpGet("https://raw.githubusercontent.com/semi556tgb/RobloxScript/main/tracers.lua"))()

-- Load the tabs
local Tabs = loadstring(game:HttpGet("https://raw.githubusercontent.com/semi556tgb/RobloxScript/main/tabs.lua"))()
if not Tabs.Main then
    warn("Tabs failed to load! UI will not be set up.")
    return
end

-- Aimbot Section
local AimbotSection = Tabs.Main:AddSection("Aimbot Controls", 1)
AimbotSection:AddToggle({
    text = "Aimbot",
    state = false,
    flag = "AimbotEnabled",
    callback = function(state)
        if state then Aimbot.Enable() else Aimbot.Disable() end
    end
})

-- ESP Section
local ESPSection = Tabs.Visuals:AddSection("ESP Controls", 1)
ESPSection:AddToggle({
    text = "ESP",
    state = false,
    flag = "ESPEnabled",
    callback = function(state)
        if state then ESP.Enable() else ESP.Disable() end
    end
})

-- Tracers Section
local TracerSection = Tabs.Visuals:AddSection("Tracer Controls", 1)
TracerSection:AddToggle({
    text = "Tracers",
    state = false,
    flag = "TracersEnabled",
    callback = function(state)
        if state then Tracers.Enable() else Tracers.Disable() end
    end
})

-- Exploits Section
local ExploitsSection = Tabs.Exploits:AddSection("Exploits", 1)
ExploitsSection:AddButton({
    text = "Infinite Jump",
    callback = function()
        game:GetService("UserInputService").JumpRequest:Connect(function()
            local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState("Jumping") end
        end)
    end
})

-- Notification
Tabs.Settings.library:SendNotification("Script Loaded Successfully!", 5)
