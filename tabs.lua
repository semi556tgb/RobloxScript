return function(library)

    local Window = library.NewWindow({
        title = "Your Cheat Name | Your Game Name",
        size = UDim2.new(0, 510, 0.6, 6)
    })

    -- Tabs
    local MainTab = Window:AddTab("Main")
    local VisualsTab = Window:AddTab("Visuals")
    local ExploitsTab = Window:AddTab("Exploits")
    local SettingsTab = library:CreateSettingsTab(Window)

    -- Main Tab Section
    local MainSection = MainTab:AddSection("Main Features", 1)

    MainSection:AddToggle({
        text = "Enable Main Feature",
        state = false,
        callback = function(value)
            print("Main Feature Enabled:", value)
        end
    })

    MainSection:AddButton({
        text = "Run Main Action",
        confirm = true,
        callback = function()
            print("Main Action executed!")
        end
    })

    -- Visuals Tab Section
    local VisualSection = VisualsTab:AddSection("Visual Tweaks", 1)

    VisualSection:AddToggle({
        text = "Enable ESP",
        state = false,
        callback = function(value)
            print("ESP Enabled:", value)
        end
    })

    VisualSection:AddColor({
        text = "ESP Color",
        color = Color3.fromRGB(255, 255, 255),
        callback = function(value)
            print("ESP Color Set To:", value)
        end
    })

    -- Exploits Tab Section
    local ExploitSection = ExploitsTab:AddSection("Exploits", 1)

    ExploitSection:AddButton({
        text = "Infinite Jump",
        confirm = true,
        callback = function()
            print("Infinite Jump Enabled!")
        end
    })

    ExploitSection:AddToggle({
        text = "No Clip",
        state = false,
        callback = function(value)
            print("No Clip State:", value)
        end
    })

    -- Optional: Confirm everything loaded
    print("All Tabs and Sections Loaded Successfully!")

end
