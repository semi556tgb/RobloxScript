local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/semi556tgb/RobloxScript/main/esp.lua"))()
local Tracers = loadstring(game:HttpGet("https://raw.githubusercontent.com/semi556tgb/RobloxScript/main/tracers.lua"))()

local Visuals = {}

function Visuals.Setup(tab)
    local ESPSection = tab:AddSection("ESP Controls", 1)

    ESPSection:AddToggle({
        text = "ESP",
        state = false,
        flag = "ESPEnabled",
        callback = function(state)
            if state then
                ESP.Enable()
            else
                ESP.Disable()
            end
        end
    })

    local TracerSection = tab:AddSection("Tracer Controls", 1)

    TracerSection:AddToggle({
        text = "Tracers",
        state = false,
        flag = "TracersEnabled",
        callback = function(state)
            if state then
                Tracers.Enable()
            else
                Tracers.Disable()
            end
        end
    })
end

return Visuals
