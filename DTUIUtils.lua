--- Shared UI utilities for Quest Manager including dialogs and styles
--- Provides consistent dialog components and styling across all Quest Manager UI
--- @class DTUIUtils
DTUIUtils = RegisterGameType("DTUIUtils")

-- Turn on the background to see lines around the downtime tab panels
local DEBUG_PANEL_BG = DTConstants.DEVUI and "panels/square.png" or nil

--- Creates a labeled checkbox with consistent styling
--- @param checkboxOptions table Options for the checkbox (text, value, change, etc.)
--- @param panelOptions? table Optional panel options (width, height, etc.)
--- @return table panel The complete labeled checkbox panel
function DTUIUtils.CreateLabeledCheckbox(checkboxOptions, panelOptions)
    -- Default panel options
    local panelDefaults = {
        classes = {"DTPanel", "DTBase"},
        width = "25%",
        -- height = 60,
        -- halign = "left",
        -- valign = "center"
    }

    -- Merge panel options
    for k, v in pairs(panelOptions or {}) do
        panelDefaults[k] = v
    end

    -- Default checkbox options
    local checkboxDefaults = {
        -- width = 160,
        -- halign = "left",
        -- valign = "center",
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
function DTUIUtils.CreateLabeledDropdown(labelText, dropdownOptions, panelOptions)
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

--- Creates a labeled input field with consistent styling
--- @param labelText string The label text to display above the input
--- @param inputOptions table Options for the input field (text, placeholderText, lineType, etc.)
--- @param panelOptions table Optional panel options (width, height, vmargin, etc.)
--- @return table panel The complete labeled input panel
function DTUIUtils.CreateLabeledInput(labelText, inputOptions, panelOptions)
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

--- Gets the standardized styling configuration for Quest Manager dialogs
--- Provides consistent styling across all Quest Manager UI components
--- @return table styles Array of GUI styles using DTBase inheritance pattern
function DTUIUtils.GetDialogStyles()
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
        },
        gui.Style{
            selectors = {"DTInput", "DTBase"},
            bgcolor = Styles.backgroundColor,
            borderWidth = 1,
            borderColor = Styles.textColor,
            bold = false,
        },
        gui.Style{
            selectors = {"DTDropdown", "DTBase"},
            bgcolor = Styles.backgroundColor,
            borderWidth = 1,
            borderColor = Styles.textColor,
            height = 30,
            bold = false,
        },
        gui.Style{
            selectors = {"DTCheck", "DTBase"},
            halign = "left",
        },

        -- Buttons
        gui.Style{
            selectors = {"DTButton", "DTBase"},
            fontSize = 22,
            cornerRadius = 4,
            textAlignment = "center",
            bold = true,
            height = 35  -- Override DTBase height for buttons
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
    }
end

--- Gets player display name with color formatting from user ID
--- @param userId string The user ID to look up
--- @return string coloredDisplayName The player's display name with HTML color tags, or "{unknown}" if not found
function DTUIUtils.GetPlayerDisplayName(userId)

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
function DTUIUtils.ListToDropdownOptions(sourceList)
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

--- Shows a generic confirmation dialog with customizable title and message
--- @param title string The title text for the dialog header
--- @param message string The main confirmation message text
--- @param confirmButtonText string Optional text for the confirm button (default: "OK")
--- @param cancelButtonText string Optional text for the cancel button (default: "Cancel")
--- @param onConfirm function Callback function to execute if user confirms
--- @param onCancel function|nil Optional callback function to execute if user cancels (default: just close dialog)
function DTUIUtils.ShowConfirmationDialog(title, message, confirmButtonText, cancelButtonText, onConfirm, onCancel)
    -- Set default button text if not provided or empty
    confirmButtonText = (confirmButtonText and confirmButtonText ~= "") and confirmButtonText or "Confirm"
    cancelButtonText = (cancelButtonText and cancelButtonText ~= "") and cancelButtonText or "Cancel"

    local confirmationWindow = gui.Panel{
        width = 400,
        height = 200,
        halign = "center",
        valign = "center",
        bgcolor = "#111111ff",
        borderWidth = 2,
        borderColor = Styles.textColor,
        bgimage = "panels/square.png",
        flow = "vertical",
        hpad = 20,
        vpad = 20,
        styles = DTUIUtils.GetDialogStyles(),

        children = {
            -- Header
            gui.Label{
                text = title,
                fontSize = 24,
                width = "100%",
                height = 30,
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                halign = "center"
            },

            -- Confirmation message
            gui.Label{
                text = message,
                width = "100%",
                height = 80,
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                textWrap = true,
                halign = "center",
                valign = "center"
            },

            -- Button panel
            gui.Panel{
                width = "100%",
                height = 40,
                flow = "horizontal",
                halign = "center",
                valign = "center",
                children = {
                    -- Cancel button (first)
                    gui.Button{
                        text = cancelButtonText,
                        width = 120,
                        height = 40,
                        hmargin = 10,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            gui.CloseModal()
                            if onCancel then
                                onCancel()
                            end
                        end
                    },
                    -- Confirm button (second)
                    gui.Button{
                        text = confirmButtonText,
                        width = 120,
                        height = 40,
                        hmargin = 10,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            gui.CloseModal()
                            if onConfirm then
                                onConfirm()
                            end
                        end
                    }
                }
            }
        },

        escape = function(element)
            gui.CloseModal()
            if onCancel then
                onCancel()
            end
        end
    }

    gui.ShowModal(confirmationWindow)
end

--- Shows a standardized delete confirmation dialog
--- @param itemType string The type of item being deleted ("quest", "note", "objective")
--- @param itemTitle string The display name/title of the item being deleted
--- @param onConfirm function Callback function to execute if user confirms deletion
--- @param onCancel function Optional callback function to execute if user cancels (default: just close dialog)
function DTUIUtils.ShowDeleteConfirmation(itemType, itemTitle, onConfirm, onCancel)
    local title = "Delete Confirmation"
    local message = "Are you sure you want to delete " .. itemType .. " \"" .. (itemTitle or "Untitled") .. "\"?"

    DTUIUtils.ShowConfirmationDialog(title, message, "Delete", "Cancel", onConfirm, onCancel)
end
