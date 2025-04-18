local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUser/RobloxScript/main/aimbot.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUser/RobloxScript/main/esp.lua"))()
local Tracers = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUser/RobloxScript/main/tracers.lua"))()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourTokyoUILink"))()
local Window = Library:CreateWindow("My Script")
local MainTab = Window:CreateTab("Main")

local AimbotToggle = MainTab:CreateToggle("Aimbot", false, function(state)
    if state then
        Aimbot.Enable()
    else
        Aimbot.Disable()
    end
end)

local ESPToggle = MainTab:CreateToggle("ESP", false, function(state)
    if state then
        ESP.Enable()
    else
        ESP.Disable()
    end
end)

local TracersToggle = MainTab:CreateToggle("Tracers", false, function(state)
    if state then
        Tracers.Enable()
    else
        Tracers.Disable()
    end
end)