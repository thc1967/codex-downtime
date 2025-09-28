--- In-place project editor for character sheet integration
--- Provides real-time editing of project fields within the character sheet
--- @class DTProjectEditor
--- @field project DTDowntimeProject The project being edited
DTProjectEditor = RegisterGameType("DTProjectEditor")
DTProjectEditor.__index = DTProjectEditor

local DEBUG_PANEL_BG = "panels/square.png"

--- Creates a new DTProjectEditor instance
--- @param project DTDowntimeProject The project to edit
--- @return DTProjectEditor instance The new editor instance
function DTProjectEditor:new(project)
    local instance = setmetatable({}, self)
    instance.projectId = project:GetID()
    return instance
end

--- Executes the function to update downtime settings
--- and touches the shared document to prompt refresh
local function updateDowntime(f)
    f()
    DTSettings.Touch()
end

--- Gets the fresh project data from the character sheet
--- @return DTDowntimeProject|nil project The current project or nil if not found
function DTProjectEditor:GetProject()
    local character = CharacterSheet.instance.data.info.token
    if character and character.properties and character.properties:IsHero() then
        local downtimeInfo = character.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
        if downtimeInfo then
            return downtimeInfo:GetDowntimeProject(self.projectId)
        end
    end
    return nil
end

--- Creates the project editor form for a downtime project
--- @return table panel The form panel with input fields
function DTProjectEditor:_createProjectForm()
    local editor = self
    local isDM = dmhub.isDM

    -- Title field (input only, no label)
    local titleField = gui.Panel{
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        height = 64,
        children = {
            gui.Input {
                width = "98%",
                height = 30,
                valign = "center",
                classes = {"DTInput", "DTBase"},
                placeholderText = "Enter project title...",
                editlag = 0.5,
                refreshToken = function(element, info)
                    local project = editor:GetProject()
                    if project and element.text ~= project:GetTitle() then
                        element.text = project:GetTitle() or ""
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and element.text ~= project:GetTitle() then
                        updateDowntime(function() project:SetTitle(element.text) end)
                    end
                end
            }
        }
    }

    -- Progress field (label + read-only display)
    local progressField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        halign = "center",
        children = {
            gui.Label {
                text = "Progress:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Label {
                classes = {"DTLabel", "DTBase"},
                width = "98%",
                height = 30,
                bold = false,
                refreshToken = function(element, info)
                    local project = editor:GetProject()
                    if project then
                        element.text = string.format("%d / %d", project:GetProgress(), project:GetProjectGoal())
                    end
                end
            }
        }
    }

    -- Pending Rolls field (label + compact +/-/number controls)
    local pendingField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        children = {
            gui.Label {
                text = "Staged Rolls: ",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Panel {
                width = "auto",
                height = 25,
                flow = "horizontal",
                halign = "left",
                refreshToken = function(element)
                    local enabled = false
                    local project = editor:GetProject()
                    if project then
                        enabled = project:GetStatus() ~= DTConstants.STATUS.COMPLETE.key
                    end
                    element:FireEventTree("setButtonEnabled", enabled)
                end,
                updatePendingRolls = function(element, numRolls)
                    local project = editor:GetProject()
                    local controllerPanel = element:FindParentWithClass("downtimeController")
                    if project and controllerPanel then
                        project:SetPendingRolls(numRolls)
                        controllerPanel:FireEventTree("refreshToken")
                    end
                end,
                children = {
                    gui.Button{
                        text = "-",
                        width = 25,
                        height = 25,
                        classes = {"DTButton", "DTBase"},
                        setButtonEnabled = function(element, enabled)
                            element:SetClass("invalid", not enabled)
                            element.interactable = enabled
                        end,
                        click = function(element)
                            local project = editor:GetProject()
                            if project then
                                local current = project:GetPendingRolls()
                                if current > 0 then
                                    element.parent:FireEvent("updatePendingRolls", current - 1)
                                end
                            end
                        end
                    },
                    gui.Label {
                        classes = {"DTLabel", "DTBase"},
                        width = "auto",
                        height = 25,
                        textAlignment = "center",
                        halign = "center",
                        valign = "center",
                        bold = false,
                        refreshToken = function(element)
                            local project = editor:GetProject()
                            if project then
                                local pendingRolls = project:GetPendingRolls() or 0
                                local btRolls = project:GetEarnedBreakthroughs()
                                local text = string.format("%d & %d", pendingRolls, btRolls)
                                if element.text ~= text then
                                    element.text = text
                                end
                            end
                        end
                    },
                    gui.Button{
                        text = "+",
                        width = 25,
                        height = 25,
                        classes = {"DTButton", "DTBase"},
                        setButtonEnabled = function(element, enabled)
                            element:SetClass("invalid", not enabled)
                            element.interactable = enabled
                        end,
                        click = function(element)
                            local project = editor:GetProject()
                            if project then
                                element.parent:FireEvent("updatePendingRolls", project:GetPendingRolls() + 1)
                            end
                        end
                    },
                }
            }
        }
    }

    -- Prerequisite field (label + input)
    local prerequisiteField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%-4",
        flow = "vertical",
        hmargin = 2,
        children = {
            gui.Label {
                text = "Prerequisites:",
                classes = {"DTLabel", "DTBase"},
            },
            gui.Input {
                width = "96%",
                classes = {"DTInput", "DTBase"},
                placeholderText = "Required items or prerequisites...",
                editlag = 0.5,
                refreshToken = function(element, info)
                    local project = editor:GetProject()
                    if project and element.text ~= project:GetItemPrerequisite() then
                        element.text = project:GetItemPrerequisite() or ""
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and element.text ~= project:GetItemPrerequisite() then
                        project:SetItemPrerequisite(element.text)
                    end
                end
            }
        }
    }

    -- Source field (label + input)
    local sourceField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%-4",
        flow = "vertical",
        hmargin = 2,
        children = {
            gui.Label {
                text = "Source:",
                classes = {"DTLabel", "DTBase"},
            },
            gui.Input {
                width = "96%",
                classes = {"DTInput", "DTBase"},
                placeholderText = "Book, tutor, or source of project knowledge...",
                editlag = 0.5,
                refreshToken = function(element, info)
                    local project = editor:GetProject()
                    if project and element.text ~= project:GetProjectSource() then
                        element.text = project:GetProjectSource() or ""
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and element.text ~= project:GetProjectSource() then
                        project:SetProjectSource(element.text)
                    end
                end
            }
        }
    }

    -- Characteristic field (label + dropdown)
    local characteristicField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        children = {
            gui.Label {
                text = "Characteristic:",
                classes = {"DTLabel", "DTBase"},
            },
            gui.Dropdown {
                width = "100%",
                classes = {"DTDropdown", "DTBase"},
                options = DTUIUtils.ListToDropdownOptions(DTConstants.CHARACTERISTICS),
                refreshToken = function(element, info)
                    local project = editor:GetProject()
                    if project and element.idChosen ~= project:GetTestCharacteristic() then
                        element.idChosen = project:GetTestCharacteristic()
                    end
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and element.idChosen ~= project:GetTestCharacteristic() then
                        project:SetTestCharacteristic(element.idChosen)
                    end
                end
            }
        }
    }

    -- Language field (label + dropdown)
    local languageField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        children = {
            gui.Label {
                text = "Language Penalty:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Dropdown {
                width = "100%",
                classes = {"DTDropdown", "DTBase"},
                options = DTUIUtils.ListToDropdownOptions(DTConstants.LANGUAGE_PENALTY),
                refreshToken = function(element)
                    local project = editor:GetProject()
                    if project and element.idChosen ~= project:GetProjectSourceLanguagePenalty() then
                        element.idChosen = project:GetProjectSourceLanguagePenalty()
                    end
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and element.idChosen ~= project:GetProjectSourceLanguagePenalty() then
                        project:SetProjectSourceLanguagePenalty(element.idChosen)
                    end
                end
            }
        }
    }

    -- Goal field (label + input)
    local goalField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        children = {
            gui.Label {
                text = "Goal:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Input {
                width = 60,
                classes = {"DTInput", "DTBase"},
                textAlignment = "center",
                editlag = 0.5,
                refreshToken = function(element, info)
                    local project = editor:GetProject()
                    if project and element.text ~= tostring(project:GetProjectGoal()) then
                        element.text = tostring(project:GetProjectGoal())
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and tonumber(element.text) ~= project:GetProjectGoal() then
                        local value = tonumber(element.text) or 1
                        project:SetProjectGoal(math.max(1, math.floor(value)))
                    end
                end
            }
        }
    }

    -- Status field (label + dropdown for DM, display for players)
    local statusField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        children = {
            gui.Label {
                text = "Status:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            isDM and gui.Dropdown {
                width = "100%",
                classes = {"DTDropdown", "DTBase"},
                options = DTUIUtils.ListToDropdownOptions(DTConstants.STATUS),
                refreshToken = function(element)
                    local project = editor:GetProject()
                    if project and element.idChosen ~= project:GetStatus() then
                        element.idChosen = project:GetStatus()
                    end
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and element.idChosen ~= project:GetStatus() then
                        updateDowntime(function() project:SetStatus(element.idChosen) end)
                    end
                end
            } or gui.Label {
                classes = {"DTLabel", "DTBase"},
                width = "98%",
                valign = "center",
                refreshToken = function(element)
                    local project = editor:GetProject()
                    if project then
                        element.text = DTConstants.GetDisplayText(DTConstants.STATUS, project:GetStatus())
                    end
                end
            }
        }
    }

    -- Status Reason field (label + textbox for DM, display for players)
    local statusReasonField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        children = {
            gui.Label {
                text = "",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
                refreshToken = function(element)
                    local project = editor:GetProject()
                    if isDM or (project and project:GetStatus() == DTConstants.STATUS.PAUSED.key) then
                        element.text = "Status Reason:"
                    else
                        element.text = ""
                    end
                end
            },
            isDM and gui.Input {
                width = "96%",
                classes = {"DTInput", "DTBase"},
                editlag = 0.5,
                refreshToken = function(element)
                    local project = editor:GetProject()
                    if project and element.text ~= project:GetStatusReason() then
                        element.text = project:GetStatusReason()
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and element.text ~= project:GetStatusReason() then
                        updateDowntime(function() project:SetStatusReason(element.text) end)
                    end
                end
            }or gui.Label {
                text = "",
                classes = {"DTLabel", "DTBase"},
                bold = false,
                width = "98%",
                refreshToken = function(element)
                    local project = editor:GetProject()
                    if project and project:GetStatus() == DTConstants.STATUS.PAUSED.key then
                        element.text = project:GetStatusReason()
                    else
                        element.text = ""
                    end
                end
            }
        }
    }

    -- Milestone field (label + input, DM only)
    local milestoneField = isDM and gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        children = {
            gui.Label {
                text = "Milestone Stop:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Input {
                width = 60,
                classes = {"DTInput", "DTBase"},
                textAlignment = "center",
                placeholderText = "0",
                editlag = 0.5,
                refreshToken = function(element, info)
                    local project = editor:GetProject()
                    if project and element.text ~= tostring(project:GetMilestoneThreshold()) then
                        local threshold = project:GetMilestoneThreshold()
                        element.text = threshold and tostring(threshold) or ""
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = editor:GetProject()
                    if project and element.text ~= tostring(project:GetMilestoneThreshold()) then
                        if element.text == "" then
                            project:SetMilestoneThreshold(nil)
                        else
                            local value = tonumber(element.text) or 0
                            project:SetMilestoneThreshold(math.max(0, math.floor(value)))
                        end
                    end
                end
            }
        }
    } or gui.Panel{height = 1}

    -- Main form panel (reduced width to make room for delete button)
    return gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "100%",
        flow = "vertical",
        vmargin = 10,
        borderColor = "red",
        children = {
            -- Row 1: Title, Progress, Pending Rolls
            gui.Panel {
                classes = {"DTPanelRow", "DTPanel", "DTBase"},
                borderColor = "blue",
                children = {
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "87%",
                        borderColor = "yellow",
                        children = {titleField}
                    },
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "12%",
                        borderColor = "yellow",
                        children = {pendingField,}
                    }
                }
            },

            -- Row 2: Prerequisite & Source
            gui.Panel {
                classes = {"DTPanelRow", "DTPanel", "DTBase"},
                borderColor = "blue",
                children = {
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "43%",
                        borderColor = "yellow",
                        children = {prerequisiteField,}
                    },
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "43%",
                        borderColor = "yellow",
                        children = {sourceField,}
                    },
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "12%",
                        borderColor = "yellow",
                        children = {progressField,},
                    },
                }
            },

            -- Row 3: Characteristic, Language Penalty, Goal
            gui.Panel {
                classes = {"DTPanelRow", "DTPanel", "DTBase"},
                borderColor = "blue",
                children = {
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "43%",
                        borderColor = "yellow",
                        children = {characteristicField,}
                    },
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "43%",
                        borderColor = "yellow",
                        children = {languageField,}
                    },
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "12%",
                        borderColor = "yellow",
                        children = {goalField,}
                    },
                },
            },

            -- Row 4: Status, Status Reason, Milestone
            gui.Panel {
                classes = {"DTPanelRow", "DTPanel", "DTBase"},
                borderColor = "blue",
                children = {
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "43%",
                        borderColor = "yellow",
                        children = {statusField,}
                    },
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "43%",
                        borderColor = "yellow",
                        children = {statusReasonField,}
                    },
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "12%",
                        borderColor = "yellow",
                        children = {milestoneField,}
                    },
                }
            },
        }
    }
end

--- Creates the rolls list for a downtime project
--- @return table panel The rolls table / panel
function DTProjectEditor:_createRollsPanel()
    return gui.Panel {
        width = "98%",
        height = "100%",
        valign = "top",
        halign = "center",
        bgimage = "panels/square.png",
        borderColor = "white",
        border = 1,
        children = {
            gui.Label {
                text = "Rolls Placeholder",
                width = "98%",
                height = "auto",
                valign = "top",
                halign = "center",
                classes = {"DTInput", "DTBase"},
            }
        }
    }
end

--- Creates the adjustments list for a downtime project
--- @return table panel The adjustments table / panel
function DTProjectEditor:_createAdjustmentsPanel()
    return gui.Panel {
        width = "98%",
        height = "100%",
        valign = "top",
        halign = "center",
        bgimage = "panels/square.png",
        borderColor = "white",
        border = 1,
        children = {
            gui.Label {
                text = "Adjustments Placeholder",
                width = "98%",
                height = "auto",
                valign = "top",
                halign = "center",
                classes = {"DTInput", "DTBase"},
            }
        }
    }
end

--- Creates an inline editor panel for real-time project editing
--- @return table panel The editor panel with input fields
function DTProjectEditor:CreateEditorPanel()
    local editor = self

    local formPanel = self:_createProjectForm()

    local rollsPanel = self:_createRollsPanel()

    local adjustmentsPanel = self:_createAdjustmentsPanel()

    local deletePanel = gui.Panel {
        width = 60,
        height = "auto",
        halign = "right",
        valign = "top",
        children = {
            gui.DeleteItemButton {
                width = 20,
                height = 20,
                halign = "right",
                valign = "top",
                hmargin = 5,
                vmargin = 5,
                click = function()
                    local project = editor:GetProject()
                    if project then
                        DTUIUtils.ShowDeleteConfirmation("Project", project:GetTitle(), function()
                            local token = CharacterSheet.instance.data.info.token
                            if token and token.properties and token.properties:IsHero() then
                                local downtimeInfo = token.properties:try_get("downtime_info")
                                if downtimeInfo then
                                    downtimeInfo:RemoveDowntimeProject(editor.projectId)
                                    DTSettings.Touch()
                                    local scrollArea = CharacterSheet.instance:Get("projectScrollArea")
                                    if scrollArea then
                                        scrollArea:FireEventTree("refreshToken")
                                    end
                                end
                            end
                        end)
                    end
                end
            }
        }
    }

    -- Container panel with form and delete button side by side
    return gui.Panel {
        id = editor:GetProject():GetID(),
        width = "95%",
        height = "auto",
        flow = "horizontal",
        hmargin = 5,
        vmargin = 7,
        bgimage = "panels/square.png",
        borderColor = "#444444",
        border = { y1 = 4, y2 = 1, x2 = 4, x1 = 1 },
        children = {
            gui.Panel{
                width = "98%",
                height = "auto",
                halign = "left",
                flow = "horizontal",
                valign = "top",
                children = {
                    gui.Panel {
                        width = "60%",
                        height = "auto",
                        halign = "left",
                        valign = "top",
                        hmargin = 8,
                        children = { formPanel }
                    },
                    gui.Panel {
                        width = "20%",
                        height = "260",
                        halign = "left",
                        valign = "center",
                        children = { adjustmentsPanel }
                    },
                    gui.Panel {
                        width = "20%",
                        height = "260",
                        halign = "left",
                        valign = "center",
                        children = { rollsPanel }
                    },
                    gui.Panel {
                        width = "auto",
                        height = "auto",
                        halign = "right",
                        valign = "top",
                        children = { deletePanel }
                    }
                }
            }
        }
    }
end
