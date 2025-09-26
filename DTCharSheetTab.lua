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
                    gui.Label {
                        text = "Calculating roll status...",
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = "100%",
                        halign = "left",
                        valign = "center",
                        hmargin = "20",
                        fontSize = 20,
                        refreshToken = function(element, info)
                            local fmt = "Rolling status is %s. %s"
                            local status = "UNKNOWN"
                            local reason = "(Unable to retrieve settings!)"
                            local settings = DTSettings:new()
                            if settings then
                                status = settings:GetPauseRolls() and "PAUSED" or "AVAILABLE"
                                if settings:GetPauseRolls() then
                                    reason = settings:GetPauseRollsReason()
                                else
                                    reason = ""
                                end
                            end
                            element.text = string.format(fmt, status, reason)
                        end,
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
                            print("THC:: ADDCLICK::")
                            local token = CharacterSheet.instance.data.info.token
                            if token and token.properties and token.properties:IsHero() then
                                local downtimeInfo = token.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
                                if downtimeInfo then
                                    local project = downtimeInfo:AddDowntimeProject()
                                    local dialog = DTEditProjectDialog:new(project)
                                    if dialog then
                                        print("THC:: OPENDLG::")
                                        dialog:ShowDialog()
                                    else
                                        print("THC:: DOIALOG::")
                                    end
                                else
                                    print("THC:: NODTINFO::")
                                end
                            else
                                print("THC:: NOTOON::")
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
        children = {
            -- Projects list container
            gui.Panel {
                width = "100%",
                height = "100%",
                flow = "vertical",
                halign = "center",
                valign = "top",
                refreshToken = function(element, info)
                    DTCharSheetTab._refreshProjectsList(element)
                end
            }
        }
    }
end

--- Refreshes the projects list display
--- @param element table The projects list container element
function DTCharSheetTab._refreshProjectsList(element)
    element.children = {}

    local character = CharacterSheet.instance.data.info.token
    if not character or not character.properties then
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

    local projects = downtimeInfo:GetDowntimeProjects()
    if not projects or not next(projects) then
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
    for projectId, project in pairs(projects) do
        projectEntries[#projectEntries + 1] = DTCharSheetTab._createProjectEntry(project)
    end

    element.children = projectEntries
end

--- Creates a single project entry display
--- @param project DTDowntimeProject The project to display
--- @return table panel The project entry panel
function DTCharSheetTab._createProjectEntry(project)
    local progress = project:GetProgress()
    local goal = project:GetProjectGoal()
    local status = project:GetStatus()
    local pendingRolls = project:GetPendingRolls()

    local statusColor = status == DTConstants.STATUS.COMPLETE and "#4CAF50" or
                       status == DTConstants.STATUS.PAUSED and "#FF9800" or
                       status == DTConstants.STATUS.MILESTONE and "#2196F3" or
                       "#FFFFFF"

    return gui.Panel {
        width = "95%",
        height = 60,
        flow = "horizontal",
        halign = "center",
        valign = "center",
        vmargin = 5,
        bgcolor = "#222222aa",
        bgimage = "panels/square.png",
        borderWidth = 1,
        borderColor = "#444444",
        children = {
            -- Project info section
            gui.Panel {
                width = "70%",
                height = "100%",
                flow = "vertical",
                halign = "left",
                valign = "center",
                hpad = 10,
                children = {
                    gui.Label {
                        text = project:GetTitle() ~= "" and project:GetTitle() or "Untitled Project",
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = 25,
                        fontSize = 16,
                        halign = "left",
                        valign = "center"
                    },
                    gui.Label {
                        text = string.format("Progress: %d/%d | Status: %s", progress, goal, status),
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = 20,
                        fontSize = 12,
                        halign = "left",
                        valign = "center",
                        color = statusColor
                    }
                }
            },

            -- Pending rolls section
            gui.Panel {
                width = "30%",
                height = "100%",
                flow = "horizontal",
                halign = "right",
                valign = "center",
                hpad = 10,
                children = {
                    gui.Label {
                        text = "Staged:",
                        classes = {"DTLabel", "DTBase"},
                        width = "auto",
                        height = "auto",
                        fontSize = 12,
                        halign = "right",
                        valign = "center",
                        hmargin = 5
                    },
                    gui.Label {
                        text = tostring(pendingRolls),
                        classes = {"DTLabel", "DTBase"},
                        width = "auto",
                        height = "auto",
                        fontSize = 14,
                        halign = "right",
                        valign = "center"
                    }
                }
            }
        }
    }
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