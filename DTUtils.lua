--- Shared UI utilities for Quest Manager including dialogs and styles
--- Provides consistent dialog components and styling across all Quest Manager UI
--- @class DTUtils
DTUtils = RegisterGameType("DTUtils")

-- Turn on the background to see lines around the downtime tab panels
local DEBUG_PANEL_BG = DTConstants.DEVUI and "panels/square.png" or nil

--- Creates a labeled checkbox with consistent styling
--- @param checkboxOptions table Options for the checkbox (text, value, change, etc.)
--- @param panelOptions? table Optional panel options (width, height, etc.)
--- @return table panel The complete labeled checkbox panel
function DTUtils.CreateLabeledCheckbox(checkboxOptions, panelOptions)
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
function DTUtils.CreateLabeledDropdown(labelText, dropdownOptions, panelOptions)
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
function DTUtils.CreateNumericEditor(labelText, initialValue, controllerClass, eventName, panelOptions)
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
                                width = 100,
                                height = "100%",
                                flow = "vertical",
                                halign = "center",
                                valign = "center",
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
                                width = 75,
                                height = "100%",
                                flow = "vertical",
                                halign = "center",
                                valign = "center",
                                children = {
                                    gui.Label {
                                        id = "adjustmentAmount",
                                        text = tostring(initialValue),
                                        width = 60,
                                        height = 60,
                                        cornerRadius = 4,
                                        bgimage = "panels/square.png",
                                        border = 1,
                                        textAlignment = "center",
                                        valign = "center",
                                        classes = {"DTInput", "DTBase"},
                                        adjustValue = function(element, delta)
                                            local currentValue = tonumber(element.text) or 0
                                            local newValue = currentValue + delta
                                            element.text = tostring(newValue)

                                            if type(controllerClass) == "string" and #controllerClass > 0 and
                                               type(eventName) == "string" and #eventName > 0 then
                                                local controller = element:FindParentWithClass(controllerClass)
                                                if controller then
                                                    controller:FireEvent(eventName, newValue)
                                                end
                                            end
                                        end
                                    }
                                }
                            },
                            -- Increment buttons panel (right cell)
                            gui.Panel{
                                width = 75,
                                height = "100%",
                                flow = "vertical",
                                halign = "center",
                                valign = "center",
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
function DTUtils.CreateLabeledInput(labelText, inputOptions, panelOptions)
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

--- Gets all the tokens in the game that are heroes
--- @param fn? function Filter callback to apply, called on token object, added if return is true
--- @return table heroes The list of heroes in the game
function DTUtils.GetAllHeroTokens(fn)
    if fn and type(fn) ~= "function" then error("arg1 must be nil or a function") end
    local heroes = {}

    local partyTable = dmhub.GetTable(Party.tableName)
    for partyId, _ in pairs(partyTable) do
        local characterIds = dmhub.GetCharacterIdsInParty(partyId)
        for _, characterId in ipairs(characterIds) do
            local character = dmhub.GetCharacterById(characterId)
            if character and character.properties and character.properties:IsHero() then
                if fn == nil or fn(character) then
                    heroes[#heroes + 1] = character
                end
            end
        end
    end

    -- Also get unaffiliated characters (director controlled on current map)
    local unaffiliatedTokens = dmhub.GetTokens{ unaffiliated = true }
    for _, token in ipairs(unaffiliatedTokens) do
        local character = dmhub.GetCharacterById(token.charid)
        if character and character.properties and character.properties:IsHero() then
            if fn == nil or fn(character) then
                heroes[#heroes + 1] = character
            end
        end
    end

    -- Optionally include despawned characters from graveyard
    local despawnedTokens = dmhub.despawnedTokens or {}
    for _, token in ipairs(despawnedTokens) do
        local character = dmhub.GetCharacterById(token.charid)
        if character and character.properties and character.properties:IsHero() then
            if fn == nill or fn(character) then
                heroes[#heroes + 1] = character
            end
        end
    end

    return heroes
end

--- Gets the standardized styling configuration for Quest Manager dialogs
--- Provides consistent styling across all Quest Manager UI components
--- @return table styles Array of GUI styles using DTBase inheritance pattern
function DTUtils.GetDialogStyles()
    return {
        -- DTBase: Foundation style for all Quest Manager controls
        gui.Style{
            selectors = {"DTBase"},
            fontSize = 18,
            fontFace = "Berling",
            color = Styles.textColor,
            height = 24,
        },

        -- DT Dialog Windows
        gui.Style{
            selectors = {"DTDialog"},
            halign = "center",
            valign = "center",
            bgcolor = "#111111ff",
            borderWidth = 2,
            borderColor = Styles.textColor,
            bgimage = "panels/square.png",
            flow = "vertical",
            hpad = 20,
            vpad = 20,
        },

        -- Panels
        gui.Style{
            selectors = {"DTPanel", "DTBase"},
            height = "auto",
            hmargin = 2,
            vmargin = 2,
            hpad = 2,
            vpad = 2,
            flow = "horizontal",
            bgimage = DEBUG_PANEL_BG,
            border = DEBUG_PANEL_BG and 1 or 0,
        },
        gui.Style{
            selectors = {"DTPanelRow", "DTPanel", "DTBase"},
            vmargin = 4,
            height = 60,
            width = "100%-4",
            valign = "top",
        },

        -- DT Control Types: Inherit from DTBase, add specific properties
        gui.Style{
            selectors = {"DTLabel", "DTBase"},
            bold = true,
            textAlignment = "left",
            cornerRadius = 4,
        },
        gui.Style{
            selectors = {"DTInput", "DTBase"},
            bgcolor = Styles.backgroundColor,
            borderWidth = 1,
            borderColor = Styles.textColor,
            bold = false,
            cornerRadius = 4,
        },
        gui.Style{
            selectors = {"DTDropdown", "DTBase"},
            bgcolor = Styles.backgroundColor,
            borderWidth = 1,
            borderColor = Styles.textColor,
            height = 30,
            bold = false,
            cornerRadius = 4,
        },
        gui.Style{
            selectors = {"DTCheck", "DTBase"},
            halign = "left",
            cornerRadius = 4,
        },

        -- Buttons
        gui.Style{
            selectors = {"DTButton", "DTBase"},
            fontSize = 22,
            textAlignment = "center",
            bold = true,
            height = 35,
            cornerRadius = 4,
        },
        gui.Style{
            selectors = {"DTDanger", "DTButton", "DTBase"},
            bgcolor = "#220000",
            borderColor = "#440000",
        },
        gui.Style{
            selectors = {"DTDisabled", "DTButton", "DTBase"},
            bgcolor = "#222222",
            borderColor = "#444444",
        },
        gui.Style{
            selectors = {"downtime-edit-button"},
            width = 20,
            height = 20
        },

        -- Rolling status color classes
        gui.Style{
            selectors = {"DTStatusAvailable"},
            color = "#4CAF50"  -- Green for available/enabled
        },
        gui.Style{
            selectors = {"DTStatusPaused"},
            color = "#FF9800"  -- Orange for paused
        },

        -- Objective drag handle styles
        gui.Style{
            selectors = {"objective-drag-handle"},
            width = 24,
            height = 24,
            bgcolor = "#444444aa",
            bgimage = "panels/square.png",
            transitionTime = 0.2
        },
        gui.Style{
            selectors = {"objective-drag-handle", "hover"},
            bgcolor = "#666666cc"
        },
        gui.Style{
            selectors = {"objective-drag-handle", "dragging"},
            bgcolor = "#888888ff",
            opacity = 0.8
        },
        gui.Style{
            selectors = {"objective-drag-handle", "drag-target"},
            bgcolor = "#4CAF50aa"
        },

        -- Compact List Styles for efficient list views
        gui.Style {
            selectors = {"DTListBase"},
            fontSize = 12,
            bgimage = DEBUG_PANEL_BG,
            border = DEBUG_PANEL_BG and 1 or 0,
        },
        gui.Style {
            selectors = {"DTListRow", "DTListBase"},
            width = "98%",
            height = 45,
            pad = 2,
            flow = "horizontal",
            valign = "top",
            halign = "right",
            bgimage = "panels/square.png",
            border = { y1 = 1, y2 = 0, x1 = 0, x2 = 0 },
            borderColor = "#666666",
        },
        gui.Style {
            selectors = {"DTListDetail", "DTListBase"},
            width = 100,
            height = 45,
            valign = "top",
            flow = "vertical",
        },
        gui.Style {
            selectors = {"DTListHeader", "DTListBase"},
            width = "98%",
            margin = 2,
            height = 20,
            flow = "horizontal",
            valign = "top",
            fontSize = 14,
        },
        gui.Style {
            selectors = {"DTListTimestamp"},
            width = 120,
            hmargin = 2,
        },
        gui.Style {
            selectors = {"DTListAmount"},
            width = 25,
            hmargin = 2,
        },
        gui.Style {
            selectors = {"DTListAmountPositive"},
            color = "#4CAF50",
        },
        gui.Style {
            selectors = {"DTListAmountNegative"},
            color = "#F44336",
        },
        gui.Style {
            selectors = {"DTListDetail", "DTListBase"},
            width = "100%",
            valign = "top",
            height = 20,
            margin = 2,
            border = 1,
        },
    }
end

--- Gets player display name with color formatting from user ID
--- @param userId string The user ID to look up
--- @return string coloredDisplayName The player's display name with HTML color tags, or "{unknown}" if not found
function DTUtils.GetPlayerDisplayName(userId)

    if userId and #userId > 0 then
        local sessionInfo = dmhub.GetSessionInfo(userId)
        if sessionInfo and sessionInfo.displayName then
            local displayName = sessionInfo.displayName
            if sessionInfo.displayColor and sessionInfo.displayColor.tostring then
                local colorCode = sessionInfo.displayColor.tostring
                return string.format("<color=%s>%s</color>", colorCode, displayName)
            else
                return displayName
            end
        end
    end

    return "{unknown}"
end

--- Transforms a list of DTConstant instances into a list of id, text pairs for dropdown lists
--- @param sourceList table The table containing DTConstant instances
--- @return table destList The transformed table, sorted by sortOrder
function DTUtils.ListToDropdownOptions(sourceList)
    local destList = {}
    if sourceList and type(sourceList) == "table" and #sourceList > 0 then
        -- Sort DTConstant instances by sortOrder
        local sortedList = {}
        for _, constant in ipairs(sourceList) do
            sortedList[#sortedList + 1] = constant
        end
        table.sort(sortedList, function(a, b) return a.sortOrder < b.sortOrder end)

        -- Create dropdown options using displayText
        for _, constant in ipairs(sortedList) do
            destList[#destList+1] = { id = constant.key, text = constant.displayText}
        end
    end
    return destList
end

