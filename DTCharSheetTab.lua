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
                                    CharacterSheet.instance:FireEventTree("refreshDowntimeProjectList")
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
            local scrollArea = element:Get("projectsScrollArea")
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
                        id = "projectsScrollArea",
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
    local isFirstItem = true
    for projectId, project in pairs(projects) do
        -- Add divider before project (except first one)
        if not isFirstItem then
            projectEntries[#projectEntries + 1] = gui.Divider { width = "90%", vmargin = 2 }
        end
        isFirstItem = false

        -- Project item
        projectEntries[#projectEntries + 1] = DTProjectEditor:new(project):CreateEditorPanel()
    end

    element.children = projectEntries
end

--- Creates a single project entry display
--- @param project DTDowntimeProject The project to display
--- @return table panel The project entry panel
function DTCharSheetTab._createProjectEntry(project)
    local title = project:GetTitle() or "Untitled Project"
    local progress = project:GetProgress()
    local goal = project:GetProjectGoal()
    local status = project:GetStatus()
    local statusReason = project:GetStatusReason()
    local pendingRolls = project:GetPendingRolls()
    local characteristic = project:GetTestCharacteristic()
    local languagePenalty = project:GetProjectSourceLanguagePenalty()
    local prerequisite = project:GetItemPrerequisite()
    local source = project:GetProjectSource()

    local statusColor = status == DTConstants.STATUS.COMPLETE and "#4CAF50" or
                       status == DTConstants.STATUS.PAUSED and "#FF9800" or
                       status == DTConstants.STATUS.MILESTONE and "#2196F3" or
                       "#FFFFFF"

    -- Build title label
    local titleLabel = gui.Label {
        text = project:GetTitle() ~= "" and project:GetTitle() or "Untitled Project",
        classes = {"DTLabel", "DTBase"},
        width = "auto",
        height = 25,
        hmargin = 2,
        halign = "left",
        valign = "center"
    }

    -- Build progress label (uncolored)
    local progressPanel = gui.Panel {
        width = "auto",
        height = 20,
        flow = "horizontal",
        hmargin = 2,
        halign = "left",
        valign = "center",
        children = {
            gui.Label {
                text = "Progress:",
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
                bold = false,
            },
            gui.Label {
                text = string.format("%d/%d", progress, goal),
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
            },
        },
    }

    -- Build status reason label (conditional, uncolored)
    local statusReasonLabel = (status == DTConstants.STATUS.PAUSED and statusReason and statusReason ~= "") and gui.Label {
        text = string.format(" (%s)", statusReason),
        classes = {"DTLabel", "DTBase"},
        width = "auto",
        height = 20,
        halign = "left",
        valign = "center",
        bold = false
    } or nil

    -- Build status panel (label + colored value + conditional reason)
    local statusPanel = gui.Panel {
        width = "auto",
        height = 20,
        flow = "horizontal",
        hmargin = 2,
        halign = "left",
        valign = "center",
        children = {
            gui.Label {
                text = "Status:",
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                halign = "left",
                valign = "center",
                hmargin = 2,
                bold = false
            },
            gui.Label {
                text = DTConstants.GetDisplayText(DTConstants.STATUS, status),
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
                color = statusColor
            },
            statusReasonLabel
        }
    }

    -- Build detail labels (all non-bold, conditional display)
    local characteristicLabel = (characteristic and characteristic ~= "") and gui.Panel {
        width = "auto",
        height = 20,
        flow = "horizontal",
        hmargin = 2,
        halign = "left",
        valign = "center",
        children = {
            gui.Label {
                text = "Characteristic:",
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
                bold = false
            },
            gui.Label {
                text = DTConstants.GetDisplayText(DTConstants.CHARACTERISTICS, characteristic),
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
            }
        }
    } or nil

    local languagePenaltyLabel = languagePenalty and gui.Panel {
        width = "auto",
        height = 20,
        flow = "horizontal",
        hmargin = 2,
        halign = "left",
        valign = "center",
        children = {
            gui.Label {
                text = "Language Penalty:",
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
                bold = false
            },
            gui.Label {
                text = DTConstants.GetDisplayText(DTConstants.LANGUAGE_PENALTY, languagePenalty),
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
            }
        }
    } or nil

    local prerequisiteLabel = (prerequisite and prerequisite ~= "") and gui.Panel {
        width = "auto",
        height = 20,
        flow = "horizontal",
        hmargin = 2,
        halign = "left",
        valign = "center",
        children = {
            gui.Label {
                text = "Prerequisites:",
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
                bold = false
            },
            gui.Label {
                text = prerequisite,
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
            }
        }
    } or nil

    local sourceLabel = (source and source ~= "") and gui.Panel {
        width = "auto",
        height = 20,
        flow = "horizontal",
        hmargin = 2,
        halign = "left",
        valign = "center",
        children = {
            gui.Label {
                text = "Project Source:",
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
                bold = false
            },
            gui.Label {
                text = source,
                classes = {"DTLabel", "DTBase"},
                width = "auto",
                height = 20,
                hmargin = 2,
                halign = "left",
                valign = "center",
            }
        }
    } or nil

    return gui.Panel {
        width = "95%",
        height = 60,
        flow = "horizontal",
        halign = "center",
        valign = "center",
        vmargin = 5,
        styles = DTUIUtils.GetDialogStyles(),
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
                    -- Title line with progress/status
                    gui.Panel {
                        width = "100%",
                        height = 25,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            gui.Panel {
                                width = "50%",
                                halign = "left",
                                valign = "center",
                                children = {
                                    titleLabel,
                                }
                            },
                            gui.Panel {
                                width = "25%",
                                halign = "left",
                                valign = "center",
                                children = {
                                    progressPanel,
                                }
                            },
                            gui.Panel {
                                width = "25%",
                                halign = "left",
                                valign = "center",
                                children = {
                                    statusPanel
                                }
                            }
                        }
                    },
                    -- Detail line with project specifics
                    gui.Panel {
                        width = "100%",
                        height = 20,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            gui.Panel {
                                width = "25%",
                                halign = "left",
                                valign = "center",
                                children = {
                                    characteristicLabel,
                                }
                            },
                            gui.Panel {
                                width = "25%",
                                halign = "left",
                                valign = "center",
                                children = {
                                    languagePenaltyLabel,
                                }
                            },
                            gui.Panel {
                                width = "25%",
                                halign = "left",
                                valign = "center",
                                children = {
                                    prerequisiteLabel,
                                }
                            },
                            gui.Panel {
                                width = "25%",
                                halign = "left",
                                valign = "center",
                                children = {
                                    sourceLabel
                                }
                            },
                        }
                    }
                }
            },

            -- Actions section
            gui.Panel {
                width = "30%",
                height = "100%",
                flow = "horizontal",
                halign = "right",
                valign = "center",
                hpad = 10,
                children = {
                    gui.SettingsButton {
                        width = 20,
                        height = 20,
                        halign = "right",
                        valign = "center",
                        hmargin = 5,
                        vmargin = 5,
                        click = function()
                            local dialog = DTEditProjectDialog:new(project)
                            if dialog then
                                dialog:ShowDialog(
                                    function(savedProject) -- onSave callback
                                        DTSettings.Touch()
                                        CharacterSheet.instance:FireEventTree("refreshDowntimeProjectList")
                                    end
                                )
                            end
                        end,
                    },
                    gui.DeleteItemButton {
                        width = 20,
                        height = 20,
                        halign = "right",
                        valign = "center",
                        hmargin = 5,
                        vmargin = 5,
                        click = function()
                            DTUIUtils.ShowDeleteConfirmation("Project", title, function()
                                print("THC:: DELETE::", title)
                            local token = CharacterSheet.instance.data.info.token
                                if token and token.properties and token.properties:IsHero() then
                                    local downtimeInfo = token.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
                                    if downtimeInfo then
                                        downtimeInfo:RemoveDowntimeProject(project:GetID())
                                        DTSettings.Touch()
                                        CharacterSheet.instance:FireEventTree("refreshDowntimeProjectList")
                                    end
                                end
                            end)
                        end
                    },
                    -- gui.Label {
                    --     text = "Staged:",
                    --     classes = {"DTLabel", "DTBase"},
                    --     width = "auto",
                    --     height = "auto",
                    --     -- fontSize = 12,
                    --     halign = "right",
                    --     valign = "center",
                    --     hmargin = 5
                    -- },
                    -- gui.Label {
                    --     text = tostring(pendingRolls),
                    --     classes = {"DTLabel", "DTBase"},
                    --     width = "auto",
                    --     height = "auto",
                    --     -- fontSize = 14,
                    --     halign = "right",
                    --     valign = "center"
                    -- }
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