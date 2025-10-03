--- In-place project editor for character sheet integration
--- Provides real-time editing of project fields within the character sheet
--- @class DTProjectEditor
--- @field project DTProject The project being edited
DTProjectEditor = RegisterGameType("DTProjectEditor")
DTProjectEditor.__index = DTProjectEditor

--- Creates a new DTProjectEditor instance
--- @param project DTProject The project to edit
--- @return DTProjectEditor instance The new editor instance
function DTProjectEditor:new(project)
    local instance = setmetatable({}, self)
    instance.project = project
    return instance
end

--- Gets the fresh project data from the character sheet
--- @return DTProject|nil project The current project or nil if not found
function DTProjectEditor:GetProject()
    return self.project
end

--- Creates the project editor form for a downtime project
--- @return table panel The form panel with input fields
function DTProjectEditor:_createProjectForm()
    local isDM = dmhub.isDM

    local projectFormStyles = {
        gui.Style {
            selectors = {"PEFormRow", "DTPanelRow", "DTPanel", "DTBase"},
            height = 72,
            pad = 0,
            margin = 0,
            width = "100%-4",
            borderColor = "blue",
        },
        gui.Style {
            selectors = {"PEFormFieldContainer", "DTPanel", "DTBase"},
            height = "100%-8",
            pad = 0,
            margin = 0,
            hpad = 2,
            borderColor = "yellow",
        }
    }

    -- Title field (input only, no label)
    local titleField = gui.Panel{
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        height = "auto",
        valign = "center",
        borderColor = "green",
        children = {
            gui.Input {
                width = "98%",
                height = 32,
                valign = "center",
                classes = {"DTInput", "DTBase"},
                placeholderText = "Enter project title...",
                editlag = 0.5,
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= project:GetTitle() then
                        element.text = project:GetTitle() or ""
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= project:GetTitle() then
                        project:SetTitle(element.text)
                        DTSettings.Touch()
                    end
                end
            }
        }
    }

    -- Progress field
    local progressField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        valign = "center",
        borderColor = "green",
        children = {
            gui.Label {
                text = "Progress:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Label {
                classes = {"DTLabel", "DTBase"},
                width = "100%-8",
                bold = false,
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project then
                        local progress = project:GetProgress()
                        local goal = project:GetProjectGoal()
                        local pct = goal > 0 and (progress / goal) or 0
                        element.text = string.format("%d / %d (%d%%)", progress, goal, math.floor(pct * 100))
                    end
                end
            }
        }
    }

    -- Prerequisite field (label + input)
    local prerequisiteField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        borderColor = "green",
        children = {
            gui.Label {
                text = "Project Prerequisite:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Input {
                width = "94%",
                classes = {"DTInput", "DTBase"},
                placeholderText = "Required items or prerequisites...",
                editlag = 0.5,
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= project:GetItemPrerequisite() then
                        element.text = project:GetItemPrerequisite() or ""
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= project:GetItemPrerequisite() then
                        project:SetItemPrerequisite(element.text)
                    end
                end
            }
        }
    }

    -- Source field
    local sourceField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%-4",
        flow = "vertical",
        borderColor = "green",
        children = {
            gui.Label {
                text = "Project Source:",
                classes = {"DTLabel", "DTBase"},
            },
            gui.Input {
                width = "94%",
                classes = {"DTInput", "DTBase"},
                placeholderText = "Book, tutor, or source of project knowledge...",
                editlag = 0.5,
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= project:GetProjectSource() then
                        element.text = project:GetProjectSource() or ""
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= project:GetProjectSource() then
                        project:SetProjectSource(element.text)
                    end
                end
            }
        }
    }

    -- Breakthrough Rolls field
    local breakthroughRolls = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        height = "100%-8",
        flow = "vertical",
        halign = "center",
        borderColor = "green",
        children = {
            gui.Label {
                text = "Breakthroughs:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Label {
                classes = {"DTLabel", "DTBase"},
                width = "100%-8",
                bold = false,
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project then
                        local s = string.format("%d pending", project:GetEarnedBreakthroughs())
                        if element.text ~= s then
                            element.text = s
                        end
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
        borderColor = "green",
        children = {
            gui.Label {
                text = "Project Roll Characteristic:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Dropdown {
                width = "100%-4",
                classes = {"DTDropdown", "DTBase"},
                options = DTUtils.ListToDropdownOptions(DTConstants.CHARACTERISTICS),
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element, info)
                    local project = element.data.getProject(element)
                    if project and element.idChosen ~= project:GetTestCharacteristic() then
                        element.idChosen = project:GetTestCharacteristic()
                    end
                end,
                change = function(element)
                    local project = element.data.getProject(element)
                    if project and element.idChosen ~= project:GetTestCharacteristic() then
                        project:SetTestCharacteristic(element.idChosen)
                    end
                end
            },
            DTUtils.Multiselect {
                classes = {"DTPanel", "DTBase"},
                flow = "horizontal",
                dropdown = {
                    classes = {"DTDropdown", "DTBase"},
                    width = "33%",
                },
                chipPanel = {
                    width = "67%",
                },
                chips = {},
                options = DTUtils.ListToDropdownOptions(DTConstants.CHARACTERISTICS),
                sort = true,
                textDefault = "Select...",
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                create = function(element)
                    local project = element.data.getProject(element)
                    if project then
                        local c = project:GetTestCharacteristic()
                        print("THC:: CREATE:: GOTPROJECT::", c)
                        element.value = c
                    end
                end,
                refreshToken = function(element)
                    print("THC:: REFRESHTOKEN::")
                end,
                change = function(element)
                    print("THC:: CHANGE::", element)
                end
            }
        }
    }

    -- Language field (label + dropdown)
    local languageField = gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        flow = "vertical",
        borderColor = "green",
        children = {
            gui.Label {
                text = "Language Penalty:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Dropdown {
                width = "100%-4",
                classes = {"DTDropdown", "DTBase"},
                options = DTUtils.ListToDropdownOptions(DTConstants.LANGUAGE_PENALTY),
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project and element.idChosen ~= project:GetProjectSourceLanguagePenalty() then
                        element.idChosen = project:GetProjectSourceLanguagePenalty()
                    end
                end,
                change = function(element)
                    local project = element.data.getProject(element)
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
        borderColor = "green",
        children = {
            gui.Label {
                text = "Project Goal:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Input {
                width = "80%",
                classes = {"DTInput", "DTBase"},
                textAlignment = "center",
                editlag = 0.5,
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= tostring(project:GetProjectGoal()) then
                        element.text = tostring(project:GetProjectGoal())
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = element.data.getProject(element)
                    if project and tonumber(element.text) ~= project:GetProjectGoal() then
                        local value = tonumber(element.text) or 1
                        project:SetProjectGoal(math.max(1, math.floor(value)))
                        DTSettings.Touch()
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
        borderColor = "green",
        children = {
            gui.Label {
                text = "Status:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            isDM and gui.Dropdown {
                width = "100%-4",
                classes = {"DTDropdown", "DTBase"},
                options = DTUtils.ListToDropdownOptions(DTConstants.STATUS),
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project =element.data.getProject(element)
                    if project and element.idChosen ~= project:GetStatus() then
                        element.idChosen = project:GetStatus()
                    end
                end,
                change = function(element)
                    local project =element.data.getProject(element)
                    if project and element.idChosen ~= project:GetStatus() then
                        project:SetStatus(element.idChosen)
                        DTSettings.Touch()
                    end
                end
            } or gui.Label {
                classes = {"DTLabel", "DTBase"},
                width = "98%",
                valign = "center",
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project =element.data.getProject(element)
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
        borderColor = "green",
        children = {
            gui.Label {
                text = "",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if isDM or (project and project:GetStatus() == DTConstants.STATUS.PAUSED.key) then
                        element.text = "Status Reason:"
                    else
                        element.text = ""
                    end
                end
            },
            isDM and gui.Input {
                width = "94%",
                classes = {"DTInput", "DTBase"},
                editlag = 0.5,
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= project:GetStatusReason() then
                        element.text = project:GetStatusReason()
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = element.data.getProject(element)
                    if project and element.text ~= project:GetStatusReason() then
                        project:SetStatusReason(element.text)
                        DTSettings.Touch()
                    end
                end
            }or gui.Label {
                text = "",
                classes = {"DTLabel", "DTBase"},
                bold = false,
                width = "98%",
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element)
                    local project = element.data.getProject(element)
                    if project and not project:IsActive() then
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
        borderColor = "green",
        children = {
            gui.Label {
                text = "Milestone Stop:",
                classes = {"DTLabel", "DTBase"},
                width = "98%",
            },
            gui.Input {
                width = "80%",
                classes = {"DTInput", "DTBase"},
                textAlignment = "center",
                placeholderText = "0",
                editlag = 0.5,
                data = {
                    getProject = function(element)
                        local projectController = element:FindParentWithClass("projectController")
                        if projectController then
                            return projectController.data.project
                        end
                        return nil
                    end
                },
                refreshToken = function(element, info)
                    local project = element.data.getProject(element)
                    if project and element.text ~= tostring(project:GetMilestoneThreshold()) then
                        local threshold = project:GetMilestoneThreshold()
                        element.text = threshold and tostring(threshold) or ""
                    end
                end,
                edit = function(element)
                    element:FireEvent("change")
                end,
                change = function(element)
                    local project = element.data.getProject(element)
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

    -- Main form panel
    return gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "100%",
        flow = "vertical",
        vmargin = 10,
        borderColor = "red",
        styles = projectFormStyles,
        children = {
            -- Row 1
            gui.Panel {
                classes = {"PEFormRow", "DTPanelRow", "DTPanel", "DTBase"},
                children = {
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "84%",
                        children = {titleField}
                    },
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "15%-4",
                        children = {progressField,},
                    },
                }
            },

            -- Row 2
            gui.Panel {
                classes = {"PEFormRow", "DTPanelRow", "DTPanel", "DTBase"},
                children = {
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "42%-2",
                        children = {prerequisiteField,}
                    },
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "42%-2",
                        children = {sourceField,}
                    },
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "15%-4",
                        children = {breakthroughRolls,},
                    },
                }
            },

            -- Row 3
            gui.Panel {
                classes = {"PEFormRow", "DTPanelRow", "DTPanel", "DTBase"},
                children = {
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "42%-2",
                        children = {characteristicField,}
                    },
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "42%-2",
                        children = {languageField,}
                    },
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "15%-4",
                        children = {goalField,}
                    },
                },
            },

            -- Row 4
            gui.Panel {
                classes = {"PEFormRow", "DTPanelRow", "DTPanel", "DTBase"},
                children = {
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "42%-2",
                        children = {statusField,}
                    },
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "42%-2",
                        children = {statusReasonField,}
                    },
                    gui.Panel {
                        classes = {"PEFormFieldContainer", "DTPanel", "DTBase"},
                        width = "15%-4",
                        children = {milestoneField,}
                    },
                }
            },
        }
    }
end

--- Creates the adjustments list for a downtime project
--- @return table panel The adjustments table / panel
function DTProjectEditor:_createAdjustmentsPanel()
    return gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        height = "100%",
        valign = "center",
        flow = "vertical",
        bgimage = "panels/square.png",
        borderColor = "#999999",
        border = 1,
        children = {
            -- Header
            gui.Panel {
                classes = {"DTPanel", "DTBase"},
                width = "100%",
                margin = 0,
                pad = 0,
                bgimage = "panels/square.png",
                bgcolor = "#222222",
                borderColor = "#666666",
                border = { y1 = 1, y2 = 0, x1 = 0, x2 = 0 },
                children = {
                    gui.Panel {
                        classes = { "DTPanel", "DTBase"},
                        width = "80%",
                        halign = "left",
                        children = {
                            gui.Label {
                                classes = {"DTLabel", "DTBase"},
                                text = "Adjustments",
                                width = "90%",
                                hmargin = 10,
                            },
                        }
                    },
                    gui.Panel {
                        classes = { "DTPanel", "DTBase" },
                        width = "12%",
                        halign = "right",
                        linger = function(element)
                            gui.Tooltip("Add an adjustment")(element)
                        end,
                        children = {
                            gui.AddButton {
                                classes = {"DTButton", "DTBase"},
                                halign = "center",
                                click = function(element)
                                    local controller = element:FindParentWithClass("projectController")
                                    if controller then
                                        local newAdjustment = DTAdjustment:new(0, "")
                                        CharacterSheet.instance:AddChild(DTAdjustmentDialog.CreateAsChild(newAdjustment, {
                                            confirm = function()
                                                controller:FireEvent("addAdjustment", newAdjustment)
                                            end,
                                            cancel = function()
                                                -- Cancel handling if needed
                                            end
                                        }))
                                    end
                                end,
                            }
                        }
                    },
                }
            },

            -- Body - Scrollable adjustments list
            gui.Panel {
                classes = {"DTPanel", "DTBase"},
                width = "98%",
                height = "85%",
                valign = "top",
                vscroll = true,
                borderColor = "red",
                children = {
                    gui.Panel {
                        id = "adjustmentScrollArea",
                        classes = {"DTPanel", "DTBase"},
                        width = "100%",
                        height = "auto",
                        flow = "vertical",
                        valign = "top",
                        borderColor = "blue",
                        data = {
                            getProject = function(element)
                                local projectController = element:FindParentWithClass("projectController")
                                if projectController then
                                    return projectController.data.project
                                end
                                return nil
                            end,
                        },
                        refreshToken = function(element)
                            local project = element.data.getProject(element)
                            if project then
                                local adjustments = project:GetAdjustments()
                                element.children = DTProjectEditor._reconcileProgressItemsList(element.children, adjustments, "deleteAdjustment")
                            end
                        end,
                        children = {}
                    }
                }
            }
        }
    }
end

--- Creates the adjustments list for a downtime project
--- @return table panel The adjustments table / panel
function DTProjectEditor:_createRollsPanel()
    return gui.Panel {
        classes = {"DTPanel", "DTBase"},
        width = "98%",
        height = "100%",
        valign = "center",
        flow = "vertical",
        bgimage = "panels/square.png",
        borderColor = "#999999",
        border = 1,
        children = {
            -- Header
            gui.Panel {
                classes = {"DTPanel", "DTBase"},
                width = "100%",
                margin = 0,
                pad = 0,
                bgimage = "panels/square.png",
                bgcolor = "#222222",
                borderColor = "#666666",
                border = { y1 = 1, y2 = 0, x1 = 0, x2 = 0 },
                children = {
                    gui.Panel {
                        classes = { "DTPanel", "DTBase"},
                        width = "80%",
                        halign = "left",
                        children = {
                            gui.Label {
                                classes = {"DTLabel", "DTBase"},
                                text = "Rolls",
                                width = "90%",
                                hmargin = 10,
                            },
                        }
                    },
                    gui.Panel {
                        classes = { "DTPanel", "DTBase" },
                        width = "12%",
                        halign = "right",
                        children = {
                            gui.Button {
                                classes = {"DTButton", "DTBase"},
                                icon = "panels/initiative/initiative-dice.png",
                                width = 24,
                                height = 24,
                                margin = 0,
                                borderWidth = 0,
                                data = {
                                    enabled = false,
                                    tooltipText = "",
                                    getDowntimeInfo = function(element)
                                        local downtimeController = element:FindParentWithClass("downtimeController")
                                        if downtimeController then
                                            return downtimeController.data.getDowntimeInfo()
                                        end
                                        return nil
                                    end,
                                    getProject = function(element)
                                        local projectController = element:FindParentWithClass("projectController")
                                        if projectController then
                                            return projectController.data.project
                                        end
                                        return nil
                                    end,
                                },
                                monitorGame = DTSettings:new():GetDocumentPath(),
                                refreshToken = function(element)
                                    element:FireEvent("refreshGame")
                                end,
                                refreshGame = function(element)
                                    local isEnabled = false
                                    element.data.tooltipText = "Project not found?"
                                    local project = element.data.getProject(element)
                                    if project then
                                        local validState, issueList = project:IsValidStateToRoll()
                                        if validState then
                                            local downtimeInfo = element.data.getDowntimeInfo(element)
                                            if downtimeInfo then
                                                if downtimeInfo:GetAvailableRolls() > 0 or project:GetEarnedBreakthroughs() > 0 then
                                                    local settings = DTSettings:new()
                                                    if settings then
                                                        if settings:GetPauseRolls() then
                                                            element.data.tooltipText = "Rolling is currently paused"
                                                        else
                                                            element.data.tooltipText = "Make a roll"
                                                            isEnabled = true
                                                        end
                                                    end
                                                else
                                                    element.data.tooltipText = "You have no available rolls"
                                                end
                                            else
                                                element.data.tooltipText = "No available rolls"
                                            end
                                        else
                                            element.data.tooltipText = table.concat(issueList, " ")
                                        end
                                    end
                                    element:SetClass("DTDisabled", not isEnabled)
                                    element.interactable = isEnabled
                                end,
                                linger = function(element)
                                    if element.data.tooltipText and #element.data.tooltipText then
                                        gui.Tooltip(element.data.tooltipText)(element)
                                    end
                                end,
                                click = function(element)
                                    print("THC::", element)
                                    if not element.interactable then return end
                                    local project = element.data.getProject(element)
                                    local controller = element:FindParentWithClass("projectController")
                                    local roll = DTRoll:new()
                                    if project and controller and roll then
                                        local options = {
                                            data = {
                                                project = project
                                            },
                                            callbacks = {
                                                confirm = function(roll)
                                                    controller:FireEvent("addRoll", roll)
                                                end,
                                                cancel = function()
                                                    -- cancel handler
                                                end
                                            }
                                        }
                                        CharacterSheet.instance:AddChild(DTProjectRollDialog.CreateAsChild(roll, options))
                                    end
                                end,
                            },
                        }
                    },
                }
            },

            -- Body - Scrollable rolls list
            gui.Panel {
                classes = {"DTPanel", "DTBase"},
                width = "98%",
                height = "85%",
                valign = "top",
                vscroll = true,
                borderColor = "red",
                children = {
                    gui.Panel {
                        id = "rollScrollArea",
                        classes = {"rollListController", "DTPanel", "DTBase"},
                        width = "100%",
                        height = "auto",
                        flow = "vertical",
                        valign = "top",
                        borderColor = "blue",
                        data = {
                            getProject = function(element)
                                local projectController = element:FindParentWithClass("projectController")
                                if projectController then
                                    return projectController.data.project
                                end
                                return nil
                            end,
                        },
                        refreshToken = function(element)
                            local project = element.data.getProject(element)
                            if project then
                                local rolls = project:GetRolls()
                                element.children = DTProjectEditor._reconcileProgressItemsList(element.children, rolls, "deleteRoll")
                            end
                        end,
                        children = {}
                    }
                }
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
                click = function(element)
                    local downtimeController = element:FindParentWithClass("downtimeController")
                    local projectController = element:FindParentWithClass("projectController")
                    if projectController and downtimeController then
                        local project = projectController.data and projectController.data.project
                        if project then
                            CharacterSheet.instance:AddChild(DTConfirmationDialog.ShowDeleteAsChild("Project", project:GetTitle(), {
                                confirm = function()
                                    downtimeController:FireEvent("deleteProject", project:GetID())
                                end,
                                cancel = function()
                                    -- Optional cancel logic
                                end
                            }))
                        end
                    end
                end
            }
        }
    }

    -- Container panel with form and delete button side by side
    return gui.Panel {
        id = editor:GetProject():GetID(),
        classes = {"projectController"},
        width = "95%",
        height = "auto",
        flow = "horizontal",
        hmargin = 5,
        vmargin = 7,
        bgimage = "panels/square.png",
        borderColor = "#444444",
        border = { y1 = 4, y2 = 1, x2 = 4, x1 = 1 },
        data = {
            project = self:GetProject()
        },

        addAdjustment = function(element, newAdjustment)
            element.data.project:AddAdjustment(newAdjustment)
            DTSettings.Touch()
            element:FireEvent("refreshProject")
        end,

        deleteAdjustment = function(element, adjustmentId)
            element.data.project:RemoveAdjustment(adjustmentId)
            DTSettings.Touch()
            element:FireEvent("refreshProject")
        end,

        addRoll = function(element, newRoll)
            local downtimeController = element:FindParentWithClass("downtimeController")
            if downtimeController then
                element.data.project:AddRoll(newRoll)
                downtimeController:FireEvent("adjustRolls", -1)
            end
        end,

        deleteRoll = function(element, rollId)
            local downtimeController = element:FindParentWithClass("downtimeController")
            if downtimeController then
                element.data.project:RemoveRoll(rollId)
                downtimeController:FireEvent("adjustRolls", 1)
            end
        end,

        refreshProject = function(element)
            element:FireEventTree("refreshToken")
        end,

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

--- Reconciles progress item list panels with current data using efficient 3-step process
--- @param panels table Existing array of item panels
--- @param items table Array of DTProgressItem descendants
--- @param deleteEvent string The event name to fire when deleting
--- @return table panels The reconciled panel array
function DTProjectEditor._reconcileProgressItemsList(panels, items, deleteEvent)
    panels = panels or {}
    if type(panels) ~= "table" then
        panels = {}
    end

    items = items or {}

    -- Handle empty items case
    if not next(items) then
        return {
            gui.Panel {
                classes = {"DTPanel", "DTBase"},
                width = "100%",
                height = "100%",
                halign = "center",
                valign = "top",
                children = {
                    gui.Label {
                        text = "There are no items yet.",
                        width = "96%",
                        height = "96%",
                        halign = "center",
                        valign = "top",
                        classes = {"DTLabel", "DTBase"},
                        bold = false,
                        color = "#888888"
                    }
                }
            }
        }
    end

    -- Step 1: Remove panels that don't have corresponding items
    for i = #panels, 1, -1 do
        local panel = panels[i]
        local foundItem = false
        for _, item in ipairs(items) do
            if item:GetID() == panel.id then
                foundItem = true
                break
            end
        end
        if not foundItem then
            table.remove(panels, i)
        end
    end

    -- Step 2: Add panels for items that don't have panels
    for _, item in ipairs(items) do
        local foundPanel = false
        for _, panel in ipairs(panels) do
            if panel.id == item:GetID() then
                foundPanel = true
                break
            end
        end
        if not foundPanel then
            panels[#panels + 1] = DTProjectEditor._createProgressListItem(item, deleteEvent)
        end
    end

    -- Step 3: Sort panels by reverse chronological order
    local serverTimeLookup = {}
    for _, item in ipairs(items) do
        serverTimeLookup[item:GetID()] = item:GetServerTime()
    end

    table.sort(panels, function(a, b)
        local aTime = serverTimeLookup[a.id] or 0
        local bTime = serverTimeLookup[b.id] or 0
        return aTime > bTime
    end)

    return panels
end

--- Creates a single progress item panel for list display
--- @param item DTProgressItem The item data to display
--- @return table panel The complete panel
function DTProjectEditor._createProgressListItem(item, deleteEvent)
    if not item then return gui.Panel{} end

    -- Format timestamp for display (remove seconds and timezone)
    local displayTime = item:GetCommitDate()

    -- Format amount with color coding
    local amount = item:GetAmount()
    local amountText = string.format("%+d", amount)
    local amountClass = amount >= 0 and "DTListAmountPositive" or "DTListAmountNegative"

    -- Get user display name with color
    local commitBy, rollBy = item:GetCommitBy()
    local userDisplay = DTUtils.GetPlayerDisplayName(commitBy)
    if rollBy and #rollBy > 0 then
        local rollDisplay = DTUtils.FormatNameWithUserColor(rollBy, commitBy)
        userDisplay = string.format("%s (%s)", rollDisplay, userDisplay)
    end

    local description = item:GetDescription()
    if #description > 80 then
        description = description:sub(1, 77) .. "..."
    end

    return gui.Panel{
        id = item:GetID(),
        classes = {"DTListRow", "DTListBase"},
        flow = "vertical",
        data = {
            serverTime = item:GetServerTime(),
        },
        children = {
            -- Top Row
            gui.Panel {
                classes = {"DTListDetail", "DTListBase"},
                flow = "horizontal",
                valign = "top",
                height = "auto",
                width = "100%",
                children = {
                    -- Top row
                    gui.Panel{
                        classes = {"DTListHeader", "DTListBase"},
                        borderColor = "cyan",
                        width = "100%-20",
                        children = {
                            gui.Label{
                                classes = {"DTListTimestamp", "DTListBase"},
                                text = displayTime,
                            },
                            gui.Label{
                                classes = {"DTListAmount", "DTListBase", amountClass},
                                text = amountText,
                            },
                            gui.Label{
                                classes = {"DTListUser", "DTListBase"},
                                text = userDisplay,
                            },
                        },
                    },
                    dmhub.isDM and gui.DeleteItemButton {
                        width = 16,
                        height = 16,
                        halign = "right",
                        valign = "center",
                        click = function(element)
                            local projectController = element:FindParentWithClass("projectController")
                            if projectController then
                                CharacterSheet.instance:AddChild(DTConfirmationDialog.ShowDeleteAsChild("Item", "this Item", {
                                    confirm = function()
                                        projectController:FireEvent(deleteEvent, item:GetID())
                                    end,
                                    cancel = function()
                                        -- Optional cancel logic
                                    end
                                }))
                            end
                        end,
                    } or nil
                }
            },
            -- Bottom
            gui.Panel {
                classes = {"DTListDetail", "DTListBase"},
                flow = "horizontal",
                valign = "top",
                height = "auto",
                width = "100%",
                borderColor = "cyan",
                children = {
                    gui.Label{
                        classes = {"DTListReason", "DTListBase"},
                        height = "auto",
                        width = "98%",
                        valign = "top",
                        bold = false,
                        text = description,
                    }
                }
            }
        }
    }
end
