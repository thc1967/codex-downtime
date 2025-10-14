--- Reusable UI component builders for consistent interface design
--- Factory methods for creating styled form controls with consistent behavior
--- @class DTUIComponents
DTUIComponents = RegisterGameType("DTUIComponents")

--- Creates a labeled checkbox with consistent styling
--- @param checkboxOptions table Options for the checkbox (text, value, change, etc.)
--- @param panelOptions? table Optional panel options (width, height, etc.)
--- @return table panel The complete labeled checkbox panel
function DTUIComponents.CreateLabeledCheckbox(checkboxOptions, panelOptions)
    -- Default panel options
    local panelDefaults = {
        classes = {"DTPanel", "DTBase"},
        width = "25%",
    }

    -- Merge panel options
    for k, v in pairs(panelOptions or {}) do
        panelDefaults[k] = v
    end

    -- Default checkbox options
    local checkboxDefaults = {
        classes = {"DTCheck", "DTBase"}
    }

    -- Merge checkbox options
    for k, v in pairs(checkboxOptions) do
        checkboxDefaults[k] = v
    end

    return gui.Panel{
        width = panelDefaults.width,
        height = panelDefaults.height,
        halign = panelDefaults.halign,
        valign = panelDefaults.valign,
        children = {
            gui.Check(checkboxDefaults)
        }
    }
end

--- Creates a labeled dropdown with consistent styling
--- @param labelText string The label text to display above the dropdown
--- @param dropdownOptions table Options for the dropdown (options, idChosen, change, etc.)
--- @param panelOptions table Optional panel options (width, height, vmargin, etc.)
--- @return table panel The complete labeled dropdown panel
function DTUIComponents.CreateLabeledDropdown(labelText, dropdownOptions, panelOptions)
    -- Default panel options
    local panelDefaults = {
        width = "33%",
        height = 60,
        flow = "vertical",
        hmargin = 5
    }

    -- Merge panel options
    for k, v in pairs(panelOptions or {}) do
        panelDefaults[k] = v
    end

    -- Default dropdown options
    local dropdownDefaults = {
        width = "80%",
        halign = "left",
        classes = {"DTDropdown", "DTBase"}
    }

    -- Merge dropdown options
    for k, v in pairs(dropdownOptions) do
        dropdownDefaults[k] = v
    end

    return gui.Panel{
        width = panelDefaults.width,
        height = panelDefaults.height,
        flow = panelDefaults.flow,
        hmargin = panelDefaults.hmargin,
        children = {
            gui.Label{
                text = labelText,
                classes = {"DTLabel", "DTBase"},
                width = "100%",
                height = 20
            },
            gui.Dropdown(dropdownDefaults)
        }
    }
end

--- Creates a numeric editor with +/- buttons for precise value adjustment
--- @param labelText string The label text to display above the editor
--- @param initialValue number The starting numeric value
--- @param controllerClass string The CSS class of the parent controller for event targeting
--- @param eventName string The event name to fire when value changes
--- @param panelOptions? table Optional panel options (width, height, vmargin, etc.)
--- @return table panel The complete numeric editor panel
function DTUIComponents.CreateNumericEditor(labelText, initialValue, controllerClass, eventName, panelOptions)
    -- Default panel options
    local panelDefaults = {
        width = "100%",
        height = 100,
        flow = "vertical",
        vmargin = 5
    }

    -- Merge panel options
    for k, v in pairs(panelOptions or {}) do
        panelDefaults[k] = v
    end

    return gui.Panel{
        classes = {"dtNumericEditorController", "DTPanel", "DTBase"},
        width = panelDefaults.width,
        height = panelDefaults.height,
        flow = panelDefaults.flow,
        vmargin = panelDefaults.vmargin,
        halign = panelDefaults.halign,

        updateValue = function(element, delta)
            local valueLabel = element:Get("adjustmentAmount")
            if valueLabel and delta then
                valueLabel:FireEvent("adjustValue", delta)
            end
        end,
        children = {
            gui.Panel {
                classes = {"DTPanel", "DTBase"},
                height = "100%-6",
                width = "100%-12",
                pad = 3,
                halign = "center",
                flow = "vertical",
                -- borderColor = "red",
                children = {
                    gui.Label{
                        text = labelText,
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = 20
                    },
                    -- Control panel with 3 equal cells
                    gui.Panel{
                        width = "auto",
                        height = 80,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            -- Decrement buttons panel (left cell)
                            gui.Panel{
                                classes = {"DTPanel", "DTBase"},
                                width = 90,
                                height = "100%",
                                flow = "vertical",
                                halign = "right",
                                valign = "center",
                                borderColor = "cyan",
                                children = {
                                    -- Top row: [-5] [-1]
                                    gui.Panel{
                                        width = "100%",
                                        height = 35,
                                        flow = "horizontal",
                                        halign = "center",
                                        valign = "center",
                                        children = {
                                            gui.Button{
                                                text = "-5",
                                                width = 30,
                                                height = 30,
                                                classes = {"DTButton", "DTBase"},
                                                click = function(element)
                                                    local controller = element:FindParentWithClass("dtNumericEditorController")
                                                    if controller then
                                                        controller:FireEvent("updateValue", -5)
                                                    end
                                                end
                                            },
                                            gui.Button{
                                                text = "-1",
                                                width = 30,
                                                height = 30,
                                                hmargin = 2,
                                                classes = {"DTButton", "DTBase"},
                                                click = function(element)
                                                    local controller = element:FindParentWithClass("dtNumericEditorController")
                                                    if controller then
                                                        controller:FireEvent("updateValue", -1)
                                                    end
                                                end
                                            }
                                        }
                                    },
                                    -- Bottom row: [-10]
                                    gui.Panel{
                                        width = "100%",
                                        height = 35,
                                        flow = "horizontal",
                                        halign = "center",
                                        valign = "center",
                                        children = {
                                            gui.Button{
                                                text = "-10",
                                                width = 70,
                                                height = 30,
                                                classes = {"DTButton", "DTBase"},
                                                click = function(element)
                                                    local controller = element:FindParentWithClass("dtNumericEditorController")
                                                    if controller then
                                                        controller:FireEvent("updateValue", -10)
                                                    end
                                                end
                                            }
                                        }
                                    }
                                }
                            },
                            -- Value display panel (center cell)
                            gui.Panel{
                                classes = {"DTPanel", "DTBase"},
                                width = 80,
                                height = "100%",
                                flow = "vertical",
                                halign = "center",
                                valign = "center",
                                borderColor = "cyan",
                                hpad = 20,
                                children = {
                                    gui.Input {
                                        id = "adjustmentAmount",
                                        text = tostring(initialValue),
                                        width = 90,
                                        height = 60,
                                        cornerRadius = 4,
                                        fontSize = 28,
                                        bgimage = "panels/square.png",
                                        border = 1,
                                        textAlignment = "center",
                                        valign = "center",
                                        halign = "center",
                                        classes = {"DTInput", "DTBase"},
                                        editlag = 0.25,

                                        edit = function(element)
                                            -- Clean input: remove non-numeric chars except minus sign
                                            local cleaned = string.gsub(element.text or "", "[^%d%-]", "")
                                            cleaned = string.gsub(cleaned, "%-+", "-")
                                            if string.sub(cleaned, 2):find("%-") then
                                                cleaned = string.gsub(cleaned, "%-", "", 1)
                                            end
                                            if cleaned ~= element.text then
                                                element.text = cleaned
                                            end
                                            element:FireEvent("change")
                                        end,

                                        change = function(element)
                                            local numericValue = tonumber(element.text) or tonumber(element.text:match("%-?%d+")) or 0
                                            element.text = tostring(numericValue)

                                            -- Fire the parent controller event
                                            if type(controllerClass) == "string" and #controllerClass > 0 and
                                               type(eventName) == "string" and #eventName > 0 then
                                                local controller = element:FindParentWithClass(controllerClass)
                                                if controller then
                                                    controller:FireEvent(eventName, numericValue)
                                                end
                                            end
                                        end,

                                        adjustValue = function(element, delta)
                                            local currentValue = tonumber(element.text) or 0
                                            local newValue = currentValue + delta
                                            element.text = tostring(newValue)
                                        end
                                    }
                                }
                            },
                            -- Increment buttons panel (right cell)
                            gui.Panel{
                                classes = {"DTPanel", "DTBase"},
                                width = 90,
                                height = "100%",
                                flow = "vertical",
                                halign = "left",
                                valign = "center",
                                borderColor = "cyan",
                                children = {
                                    -- Top row: [+1] [+5]
                                    gui.Panel{
                                        width = "100%",
                                        height = 35,
                                        flow = "horizontal",
                                        halign = "center",
                                        valign = "center",
                                        children = {
                                            gui.Button{
                                                text = "+1",
                                                width = 30,
                                                height = 30,
                                                classes = {"DTButton", "DTBase"},
                                                click = function(element)
                                                    local controller = element:FindParentWithClass("dtNumericEditorController")
                                                    if controller then
                                                        controller:FireEvent("updateValue", 1)
                                                    end
                                                end
                                            },
                                            gui.Button{
                                                text = "+5",
                                                width = 30,
                                                height = 30,
                                                hmargin = 2,
                                                classes = {"DTButton", "DTBase"},
                                                click = function(element)
                                                    local controller = element:FindParentWithClass("dtNumericEditorController")
                                                    if controller then
                                                        controller:FireEvent("updateValue", 5)
                                                    end
                                                end
                                            }
                                        }
                                    },
                                    -- Bottom row: [+10]
                                    gui.Panel{
                                        width = "100%",
                                        height = 35,
                                        flow = "horizontal",
                                        halign = "center",
                                        valign = "center",
                                        children = {
                                            gui.Button{
                                                text = "+10",
                                                width = 70,
                                                height = 30,
                                                classes = {"DTButton", "DTBase"},
                                                click = function(element)
                                                    local controller = element:FindParentWithClass("dtNumericEditorController")
                                                    if controller then
                                                        controller:FireEvent("updateValue", 10)
                                                    end
                                                end
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end

--- Creates a labeled input field with consistent styling
--- @param labelText string The label text to display above the input
--- @param inputOptions table Options for the input field (text, placeholderText, lineType, etc.)
--- @param panelOptions table Optional panel options (width, height, vmargin, etc.)
--- @return table panel The complete labeled input panel
function DTUIComponents.CreateLabeledInput(labelText, inputOptions, panelOptions)
    -- Default panel options
    local panelDefaults = {
        width = "95%",
        height = inputOptions.lineType == "MultiLine" and 120 or 60,
        flow = "vertical",
        vmargin = 5
    }

    -- Merge panel options
    for k, v in pairs(panelOptions or {}) do
        panelDefaults[k] = v
    end

    -- Default input options
    local inputDefaults = {
        width = "100%",
        classes = {"DTInput", "DTBase"},
        lineType = "Single",
        editlag = 0.25
    }

    -- Merge input options
    for k, v in pairs(inputOptions) do
        inputDefaults[k] = v
    end

    -- Adjust input height for multiline
    if inputDefaults.lineType == "MultiLine" then
        inputDefaults.height = inputDefaults.height or 100
        inputDefaults.textAlignment = inputDefaults.textAlignment or "topleft"
    end

    return gui.Panel{
        width = panelDefaults.width,
        height = panelDefaults.height,
        flow = panelDefaults.flow,
        vmargin = panelDefaults.vmargin,
        children = {
            gui.Label{
                text = labelText,
                classes = {"DTLabel", "DTBase"},
                width = "100%",
                height = 20
            },
            gui.Input(inputDefaults)
        }
    }
end

--- Creates a roll button with blue hover icon tint (following DeleteItemButton pattern)
--- @param options table Options table with click handler and optional styling
---   - click: function(element) - Click handler callback
---   - press: function(element) - Press handler callback (optional)
---   - linger: function(element) - Linger/hover handler for tooltips (optional)
---   - width: number - Button width (default: 20)
---   - height: number - Button height (default: 20)
---   - halign: string - Horizontal alignment (optional)
---   - valign: string - Vertical alignment (optional)
---   - hmargin: number - Horizontal margin (optional)
---   - vmargin: number - Vertical margin (optional)
---   - margin: number - All-around margin (optional)
---   - classes: table - Additional CSS classes (optional)
---   - styles: table - Additional styles (optional)
---   - create: function(element) - Create event handler (optional)
---   - refreshGame: function(element) - Refresh game event (optional)
---   - refreshToken: function(element) - Refresh token event (optional)
---   - data: table - Custom data object (optional)
--- @return table panel The roll button panel
function DTUIComponents.CreateRollButton(options)
    options = options or {}

    -- Styles for roll button icon tinting
    local rollButtonStyles = {
        {
            priority = 10,
            selectors = {'dt-roll-button'},
            bgcolor = "white",  -- Default: white icon
            borderWidth = 0,
        },
        {
            priority = 10,
            selectors = {'dt-roll-button', 'hover'},
            bgcolor = "#00cccc",  -- Hover: blue icon
            transitionTime = 0.2
        },
        {
            priority = 10,
            selectors = {'dt-roll-button', 'press'},
            bgcolor = "#000088",  -- Press: darker blue
        },
    }

    -- Build args table
    local args = {
        classes = {'dt-roll-button'},
        bgimage = 'panels/initiative/initiative-dice.png',
        borderWidth = 0,
        width = options.width or 20,
        height = options.height or 20,
        styles = rollButtonStyles,
    }

    -- Merge additional classes
    if options.classes then
        for _, cls in ipairs(options.classes) do
            args.classes[#args.classes + 1] = cls
        end
        options.classes = nil
    end

    -- Merge additional styles
    if options.styles then
        local styles = {}
        for _, s in ipairs(args.styles) do
            styles[#styles + 1] = s
        end
        for _, s in ipairs(options.styles) do
            styles[#styles + 1] = s
        end
        args.styles = styles
        options.styles = nil
    end

    -- Copy all other options
    for k, v in pairs(options) do
        if k ~= "width" and k ~= "height" then  -- Already handled above
            args[k] = v
        end
    end

    return gui.Panel(args)
end
