-- Load Tokyo UI Library
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/RunDTM/Tokyo-Library-Fixed/main/TokyoLib.lua"))()
end)

if not success or type(Library) ~= "table" or not Library.CreateWindow then
    warn("Tokyo UI Library failed to load properly! Check the URL or your connection.")
    return nil
end

-- Create the main window and tabs
local Window = Library:CreateWindow("My Script")

local Tabs = {}
Tabs.Main = Window:CreateTab("Main")
Tabs.Visuals = Window:CreateTab("Visuals")
Tabs.Exploits = Window:CreateTab("Exploits")
Tabs.Settings = { library = Library }

return Tabs
