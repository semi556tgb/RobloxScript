local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/1%20Tokyo%20Lib%20(FIXED)/Tokyo%20Lib%20Source.lua"))()

local Window = Library:CreateWindow("My Script") -- make sure this matches the real library's API

local Tabs = {}

Tabs.Main = Window:CreateTab("Main")
Tabs.Visuals = Window:CreateTab("Visuals")
Tabs.Exploits = Window:CreateTab("Exploits")
Tabs.Settings = {
    library = Library
}

return Tabs
