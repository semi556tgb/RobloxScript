return function(library)
    local Window = library.NewWindow({
        title = "Your Cheat Name | Your Game Name",
        size = UDim2.new(0, 510, 0.6, 6)
    })

    local MainTab = Window:AddTab("Main Tab")
    local SettingsTab = library:CreateSettingsTab(Window)

    local MainSection = MainTab:AddSection("Main Features", 1)

    MainSection:AddToggle({
        text = "Example Toggle",
        state = false,
        callback = function(value)
            print("Toggle is now:", value)
        end
    })

    MainSection:AddButton({
        text = "Example Button",
        confirm = true,
        callback = function()
            print("Button was pressed!")
        end
    })

    MainSection:AddSlider({
        text = "Example Slider",
        min = 0,
        max = 100,
        increment = 1,
        callback = function(value)
            print("Slider value:", value)
        end
    })

    MainSection:AddList({
        text = "Example List",
        selected = "",
        values = {"Option1", "Option2", "Option3"},
        multi = false,
        callback = function(value)
            print("Selected:", value)
        end
    })

    MainSection:AddColor({
        text = "Example Color Picker",
        color = Color3.fromRGB(255, 255, 255),
        callback = function(value)
            print("Selected Color:", value)
        end
    })
end
