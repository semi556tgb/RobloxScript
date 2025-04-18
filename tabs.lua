local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/1%20Tokyo%20Lib%20(FIXED)/Tokyo%20Lib%20Source.lua"))({
    cheatname = "Your Script Name",
    gamename = "Your Game Name",
})

library:init()

local Window = library.NewWindow({
    title = "Your Script Name | Your Game Name",
    size = UDim2.new(0, 510, 0.6, 6)
})

local Tabs = {}

Tabs.Visuals = Window:AddTab("Visuals")
Tabs.Main = Window:AddTab("Main")
Tabs.Exploits = Window:AddTab("Exploits")
Tabs.Settings = library:CreateSettingsTab(Window)

return Tabs
