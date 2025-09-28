--- Downtime character sheet tab for managing downtime activities and projects
--- Provides a dedicated interface for tracking downtime activities within the character sheet
--- @class DTCharSheetTab
--- @field _instance DTCharSheetTab The singleton instance of this class
DTCharSheetTab = RegisterGameType("DTCharSheetTab")
DTCharSheetTab.__index = DTCharSheetTab

--- Creates a new DTCharSheetTab instance
--- @return DTCharSheetTab instance The new instance
function DTCharSheetTab:new()
    local instance = setmetatable({}, self)
    return instance
end

--- Creates the main downtime panel for the character sheet
--- @return table|nil panel The GUI panel containing downtime content
function DTCharSheetTab.CreateDowntimePanel()
    local downtimePanel = gui.Panel {
        bgimage = true,
        bgcolor = "clear",
        width = "100%",
        height = "100%",
        flow = "vertical",
        valign = "top",
        halign = "center",
        styles = DTUIUtils.GetDialogStyles(),

        children = {
            -- Header
            DTCharSheetTab._createHeaderPanel(),

            -- Body
            DTCharSheetTab._createBodyPanel(),
        }
    }

    return downtimePanel
end

--- Creates the available rolls display panel
--- @return table panel The panel showing available rolls count
function DTCharSheetTab._createHeaderPanel()
    return gui.Panel {
        width = "100%",
        height = 40,
        flow = "horizontal",
        halign = "center",
        valign = "center",
        bgimage = "panels/square.png",
        bgcolor = "#2a2a2a",
        border = { y1 = 1, y2 = 0, x1 = 0, x2 = 0 },
        borderColor = "white",
        children = {
            -- Roll Status
            gui.Panel {
                width = "45%",
                height = "100%",
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    gui.Panel {
                        width = "100%",
                        height = "100%",
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        hmargin = "20",
                        children = {
                            gui.Label {
                                text = "Rolling status is ",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = "100%",
                                hmargin = 2,
                                fontSize = 20,
                                halign = "left",
                                valign = "center"
                            },
                            gui.Label {
                                text = "CALCULATING...",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                hmargin = 2,
                                height = "100%",
                                fontSize = 20,
                                halign = "left",
                                valign = "center",
                                refreshToken = function(element, info)
                                    local status = "UNKNOWN"
                                    local settings = DTSettings:new()
                                    if settings then
                                        status = settings:GetPauseRolls() and "PAUSED" or "AVAILABLE"
                                    end
                                    element.text = status
                                    element.classes = {"DTLabel", "DTBase", status == "AVAILABLE" and "DTStatusAvailable" or "DTStatusPaused"}
                                end
                            },
                            gui.Label {
                                text = "",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = "100%",
                                fontSize = 20,
                                halign = "left",
                                valign = "center",
                                bold = false,
                                refreshToken = function(element, info)
                                    local reason = ""
                                    local settings = DTSettings:new()
                                    if settings then
                                        if settings:GetPauseRolls() then
                                            reason = "(" .. settings:GetPauseRollsReason() .. ")"
                                        end
                                    end
                                    element.text = reason
                                end
                            }
                        }
                    }
                }
            },

            -- Staged & Available Rolls
            gui.Panel {
                width = "45%",
                height = "100%",
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    gui.Label {
                        text = "Calculating staged and available rolls...",
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = "100%",
                        halign = "left",
                        valign = "center",
                        hmargin = "20",
                        fontSize = 20,
                        refreshToken = function(element, info)
                            local fmt = "Staged %d / %d Available Rolls.%s"
                            local stagedRolls = 0
                            local availableRolls = 0
                            local msg = ""
                            local token = CharacterSheet.instance.data.info.token
                            if token and token.properties and token.properties:IsHero() then
                                local downtimeInfo = token.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
                                if downtimeInfo then
                                    availableRolls = downtimeInfo:GetAvailableRolls()
                                    stagedRolls = downtimeInfo:GetStagedRollsCount()
                                else
                                    msg = " (Can't get downtime info)"
                                end
                            else
                                msg = " (WTF not a character)"
                            end
                            element.text = string.format(fmt, stagedRolls, availableRolls, msg)
                        end
                    }
                },
            },

            -- Add button
            gui.Panel {
                width = "10%",
                height = "100%",
                flow = "horizontal",
                halign = "right",
                valign = "center",
                children = {
                    gui.AddButton {
                        halign = "right",
                        vmargin = 5,
                        hmargin = 20,
                        linger = function(element)
                            gui.Tooltip("Add a new downtime project")(element)
                        end,
                        click = function(element)
                            local token = CharacterSheet.instance.data.info.token
                            if token and token.properties and token.properties:IsHero() then
                                local downtimeInfo = token.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
                                if downtimeInfo then
                                    downtimeInfo:AddDowntimeProject()
                                    DTSettings.Touch()
                                    local scrollArea = CharacterSheet.instance:Get("projectScrollArea")
                                    if scrollArea then
                                        scrollArea:FireEventTree("refreshToken")
                                    end
                                end
                            end
                        end
                    }
                }
            }
        }
    }
end

--- Creates the downtime projects panel
--- @return table panel The panel for managing downtime projects
function DTCharSheetTab._createBodyPanel()
    return gui.Panel {
        width = "100%",
        height = "100%-40",
        flow = "vertical",
        halign = "center",
        valign = "top",
        vmargin = 10,
        refreshDowntimeProjectList = function(element)
            local scrollArea = element:Get("projectScrollArea")
            if scrollArea then
                DTCharSheetTab._refreshProjectsList(scrollArea)
            end
        end,
        children = {
            -- Scrollable projects area
            gui.Panel{
                width = "100%",
                height = "100%",
                valign = "top",
                vscroll = true,
                styles = DTUIUtils.GetDialogStyles(),
                children = {
                    -- Inner auto-height container that pins content to top
                    gui.Panel{
                        id = "projectScrollArea",
                        width = "100%",
                        height = "auto",
                        flow = "vertical",
                        halign = "center",
                        valign = "top",
                        refreshToken = function(element, info)
                            DTCharSheetTab._refreshProjectsList(element)
                        end
                    }
                }
            }
        }
    }
end

--- Refreshes the projects list display
--- @param element table The projects list container element
function DTCharSheetTab._refreshProjectsList(element)
    element.children = {}

    local character = CharacterSheet.instance.data.info.token
    if not character or not character.properties or not character.properties:IsHero() then
        return
    end

    local downtimeInfo = character.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
    if not downtimeInfo then
        -- Show "no projects" message
        element.children = {
            gui.Label {
                text = "(unable to create downtime info)",
                classes = {"DTLabel", "DTBase"},
                width = "100%",
                height = 40,
                textAlignment = "center",
                halign = "center",
                valign = "top"
            }
        }
        return
    end

    local projects = downtimeInfo:GetSortedProjects()
    if not projects or #projects == 0 then
        -- Show "no projects" message
        element.children = {
            gui.Label {
                text = "No downtime projects yet.\nClick the Add button to create one.",
                classes = {"DTLabel", "DTBase"},
                width = "100%",
                height = 40,
                textAlignment = "center",
                halign = "center",
                valign = "top"
            }
        }
        return
    end

    -- Create project entries
    local projectEntries = {}
    -- local isFirstItem = true
    for _, project in ipairs(projects) do
        projectEntries[#projectEntries + 1] = DTProjectEditor:new(project):CreateEditorPanel()
    end

    element.children = projectEntries
end

-- Register the Downtime tab at the top level of the character sheet
CharSheet.RegisterTab {
    id = "Downtime",
    text = "Downtime",
	visible = function(c)
		--only visible for characters.
		return c ~= nil and c:IsHero()
	end,
    panel = DTCharSheetTab.CreateDowntimePanel
}