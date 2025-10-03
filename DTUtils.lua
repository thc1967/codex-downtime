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

--- Formats any display name string with the specified user's color
--- @param displayName string The name to format (character name, follower name, or user name)
--- @param userId string The user ID to get color from
--- @return string coloredDisplayName The name with HTML color tags, or plain name if color unavailable
function DTUtils.FormatNameWithUserColor(displayName, userId)
    if not displayName or #displayName == 0 then
        return "{unknown}"
    end

    if userId and #userId > 0 then
        local sessionInfo = dmhub.GetSessionInfo(userId)
        if sessionInfo and sessionInfo.displayColor and sessionInfo.displayColor.tostring then
            local colorCode = sessionInfo.displayColor.tostring
            return string.format("<color=%s>%s</color>", colorCode, displayName)
        end
    end

    -- Return plain name if no color available
    return displayName
end

--- Gets player display name with color formatting from user ID
--- @param userId string The user ID to look up
--- @return string coloredDisplayName The player's display name with HTML color tags, or "{unknown}" if not found
function DTUtils.GetPlayerDisplayName(userId)
    if userId and #userId > 0 then
        local sessionInfo = dmhub.GetSessionInfo(userId)
        if sessionInfo and sessionInfo.displayName then
            return DTUtils.FormatNameWithUserColor(sessionInfo.displayName, userId)
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

--- Transform the target to the source, returning true if we changed anything in the process
--- @param target table The destination array of strings
--- @param source table The source array of strings
--- @return boolean changed Whether we changed the destination array
function DTUtils.SyncArrays(target, source)
    local changed = false

    -- Build a lookup table for fast checking
    local sourceSet = {}
    for _, str in ipairs(source) do
        sourceSet[str] = true
    end
    
    -- Remove items not in source
    for i = #target, 1, -1 do
        if not sourceSet[target[i]] then
            table.remove(target, i)
            changed = true
        end
    end
    
    -- Build lookup of current strings
    local targetSet = {}
    for _, str in ipairs(target) do
        targetSet[str] = true
    end
    
    -- Add items from source that aren't in target
    for _, str in ipairs(source) do
        if not targetSet[str] then
            target[#target + 1] = str
            changed = true
        end
    end

    return changed
end

--- Creates a generic multiselect control for selecting multiple items from a list
--- Displays selected items as removable chips with a dropdown to add more items
--- @return table panel The multiselect panel with "change" event support
function DTUtils.Multiselect(args)
    args = args or {}
    args.classes = args.classes or {}

    -- Retain the original list of options
    local m_options = shallow_copy_list(args.options or {})
    args.options = nil

    -- For later value setting
    local optionsById = {}
    for _, opt in ipairs(m_options) do
        optionsById[opt.id] = opt
    end

    -- Reference to ourself
    local m_panel = nil

    -- Store the caller's callback for forwarding
    local fnChange = nil
    if args.change then
        fnChange = args.change
        args.change = nil
    end

    -- Guarantee a layout we know how to use.
    local flow = string.lower(args.flow or "vertical")
    if flow ~= "horizontal" and flow ~= "vertical" then
        flow = "vertical"
    end
    args.flow = nil
    local layoutVertical = flow == "vertical"
    if layoutVertical then
        args.height = "auto"
    else
        args.width = "auto"
    end

    -- Calculate our dropdown sub-component
    local function buildDropdown()
        local dropdownOpts = args.dropdown or {}
        args.dropdown = nil
        dropdownOpts.width = dropdownOpts.width or flow == "vertical" and "100%" or "50%"
        dropdownOpts.textDefault = dropdownOpts.textDefault or args.textDefault or "Select an item..."
        dropdownOpts.sort = dropdownOpts.sort or args.sort or nil
        dropdownOpts.options = shallow_copy_list(m_options)
        dropdownOpts.change = function(element)
            local controller = element:FindParentWithClass("multiselectController")
            if controller then
                if element.idChosen then
                    for _, item in ipairs(element.options) do
                        if item.id == element.idChosen then
                            controller:FireEventTree("addSelected", item)
                            break
                        end
                    end
                end
            end
        end
        dropdownOpts.addSelected = function(element, item)
            -- Adding to the selected list = removing from dropdown
            local options = element.options
            for i, option in ipairs(options) do
                if option == item then
                    element.idChosen = nil
                    table.remove(options, i)
                    element.options = options
                    break
                end
            end
        end
        dropdownOpts.removeSelected = function(element, item)
            -- Removing from the selected list = returning to the dropdown
            local listOptions = element.options
            local insertPos = #listOptions + 1
            for i, option in ipairs(listOptions) do
                if item.text < option.text then
                    insertPos = i
                    break
                end
            end
            table.insert(listOptions, insertPos, item)
        end
        dropdownOpts.repaint = function(element, selections)
            -- Remove everything from the original options list that
            -- is selected now.
            local options = shallow_copy_list(m_options)
            for i = #options, 1, -1 do
                for _, item in ipairs(selections) do
                    if options[i].id == item.id then
                        table.remove(options, i)
                        break
                    end
                end
            end
            element.options = options
        end
        args.sort = nil
        args.textDefault = nil
        return gui.Dropdown(dropdownOpts)
    end
    local dropdownPanel = buildDropdown()

    local function buildChips()
        local chipsStyle = {
            selectors = {"multiselect-chip"},
            height = "auto",
            width = "auto",
            pad = 4,
            margin = 4,
            fontSize = 14,
            bgimage = "panels/square.png",
            borderColor = Styles.textColor,
            border = 1,
            cornerRadius = 2,
            bgcolor = "#444444",
        }

        -- Calculate for individual chips
        local chipsOpts = args.chips or {}
        args.chips = nil
        local chipsClasses = chipsOpts.classes or {}
        local chipsStyles = chipsOpts.styles or {}
        args.chips = nil
        chipsOpts.styles = table.move(chipsStyles, 1, #chipsStyles, #chipsStyle, chipsStyle)

        -- Calculate for the panel
        local chipPanelOpts = args.chipPanel or {}
        args.chipPanel = nil
        chipPanelOpts.width = chipPanelOpts.width or flow == "vertical" and "100%" or "auto"
        chipPanelOpts.height = "auto"
        chipPanelOpts.flow = chipPanelOpts.flow or "horizontal"
        chipPanelOpts.wrap = true
        chipPanelOpts.children = {}
        chipPanelOpts.borderColor = "#98F347"
        chipPanelOpts.addSelected = function(element, item)
            local baseClasses = { item.id, "multiselect-chip" }
            local opts = chipsOpts
            opts.id = item.id
            opts.data = { item = item }
            opts.text = item.text
            opts.classes = table.move(chipsClasses, 1, #chipsClasses, #baseClasses + 1, baseClasses)
            opts.click = function(element)
                local controller = element:FindParentWithClass("multiselectController")
                if controller then
                    controller:FireEventTree("removeSelected", element.data.item)
                    dmhub.Schedule(0.1, function()
                        element:DestroySelf()
                    end)
                end
            end
            opts.press = function(element)
                element:FireEvent("click")
            end
            element:AddChild(gui.Label(opts))
        end
        chipPanelOpts.repaint = function(element, selections)
            -- Build lookup of selection IDs
            local selectionIds = {}
            for _, item in ipairs(selections) do
                selectionIds[item.id] = true
            end

            -- Remove children not in selections (iterate backwards)
            for i = #element.children, 1, -1 do
                if not selectionIds[element.children[i].id] then
                    element.children[i]:DestroySelf()
                end
            end

            -- Build lookup of current child IDs
            local childIds = {}
            for _, child in ipairs(element.children) do
                childIds[child.id] = true
            end

            -- Add selections that aren't in children
            for _, item in ipairs(selections) do
                if not childIds[item.id] then
                    element:FireEvent("addSelected", item)
                end
            end
        end
        chipPanelOpts.removeSelected = function(element, item)
            -- They're kind enough to destroy themselves
        end

        return gui.Panel(chipPanelOpts)
    end
    local chipsPanel = buildChips()

    local function buildController()

        local controllerClasses = {"multiselectController"}
        if args.classes then
            table.move(args.classes, 1, #args.classes, #controllerClasses + 1, controllerClasses)
            args.classes = nil
        end

        local panelData = { selected = {} }
        if args.data then
            for k, v in pairs(args.data) do
                if k ~= "selected" then
                    panelData[k] = v
                end
            end
        end

        local panelOpts = args or {}
        panelOpts.classes = controllerClasses
        panelOpts.width = panelOpts.width or "100%"
        panelOpts.height = panelOpts.height or "auto"
        panelOpts.flow = flow
        panelOpts.data = panelData
        panelOpts.change = function(element, ...)
            if fnChange then
                fnChange(element, element.data.selected, ...)
            end
        end
        panelOpts.addSelected = function(element, item)
            local selected = element.data.selected
            local found = false
            for _, v in ipairs(selected) do
                if v == item then
                    found = true
                    break
                end
            end
            if not found then
                selected[#selected + 1] = item
            end
            element:FireEvent("change")
        end
        panelOpts.removeSelected = function(element, item)
            local selected = element.data.selected
            for i, v in ipairs(selected) do
                if v == item then
                    table.remove(selected, i)
                    break
                end
            end
            element:FireEvent("change")
        end
        panelOpts.GetValue = function(element)
            local ids = {}
            for _, item in ipairs(element.data.selected) do
                ids[#ids + 1] = item.id
            end
            return ids --element.data.selected
        end
        panelOpts.SetValue = function(element, v)
            print("THC:: SETVALUE::", v)
            local newSelection = {}
            local function addById(id)
                if optionsById[id] then
                    newSelection[#newSelection + 1] = optionsById[id]
                end
            end
            if v then
                if type(v) == "string" and #v > 0 then
                    addById(v)
                elseif type(v) == "table" then
                    for _, item in ipairs(v) do
                        if type(item) == "string" and #item > 0 then
                            addById(item)
                        elseif type(item) == "table" and item.id and type(item.id) == "string" and #item.id > 0 then
                            addById(item.id)
                        end
                    end
                end
            end
            element.data.selected = newSelection
            element:FireEventTree("repaint", newSelection)
        end
        panelOpts.children = flow == "vertical"
            and {chipsPanel, dropdownPanel}
            or {dropdownPanel, chipsPanel}

        return gui.Panel(panelOpts)
    end
    m_panel = buildController()

    return m_panel
end
