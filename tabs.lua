local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/1%20Tokyo%20Lib%20(FIXED)/Tokyo%20Lib%20Source.lua"))()
end)

if not success or type(Library) ~= "table" or not Library.CreateWindow then
    warn("Failed to load Tokyo UI Library or CreateWindow method missing!")
    return {
        Main = nil,
        Visuals = nil,
        Exploits = nil,
        Settings = {}
    }
end

local Window = Library:CreateWindow("My Script")

local Tabs = {}
Tabs.Main = Window:CreateTab("Main")
Tabs.Visuals = Window:CreateTab("Visuals")
Tabs.Exploits = Window:CreateTab("Exploits")
Tabs.Settings = {
    library = Library
}

return Tabs
