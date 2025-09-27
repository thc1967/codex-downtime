--- In-place project editor for character sheet integration
--- Provides real-time editing of project fields within the character sheet
--- @class DTProjectEditor
--- @field project DTDowntimeProject The project being edited
DTProjectEditor = RegisterGameType("DTProjectEditor")
DTProjectEditor.__index = DTProjectEditor

--- Creates a new DTProjectEditor instance
--- @param project DTDowntimeProject The project to edit
--- @return DTProjectEditor instance The new editor instance
function DTProjectEditor:new(project)
    local instance = setmetatable({}, self)
    instance.projectId = project:GetID()
    return instance
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

--- Creates an inline editor panel for real-time project editing
--- @return table panel The editor panel with input fields
function DTProjectEditor:CreateEditorPanel()
    local project = self:GetProject()
    local editor = self
    local isDM = dmhub.isDM

    -- Main form panel (reduced width to make room for delete button)
    local formPanel = gui.Panel {
        width = "100%-60",
        height = "auto",
        flow = "vertical",
        children = {
            -- Title input field
            gui.Panel {
                width = "100%",
                height = 35,
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    gui.Input {
                        width = "100%",
                        height = 30,
                        classes = {"DTInput", "DTBase"},
                        fontSize = 18,
                        placeholderText = "Enter project title...",
                        editlag = 0.25,
                        refreshToken = function(element, info)
                            local project = editor:GetProject()
                            if project then
                                element.text = project:GetTitle() or ""
                            end
                        end,
                        edit = function(element)
                            local project = editor:GetProject()
                            if project then
                                project:SetTitle(element.text)
                            end
                        end,
                        change = function(element)
                            local project = editor:GetProject()
                            if project then
                                project:SetTitle(element.text)
                            end
                        end
                    }
                }
            },

            -- First row: Progress display, Status dropdown, Goal input
            gui.Panel {
                width = "100%",
                height = 30,
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    -- Progress display (read-only)
                    gui.Panel {
                        width = "25%",
                        height = 30,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            gui.Label {
                                text = "Progress:",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = 30,
                                fontSize = 14,
                                bold = false,
                                hmargin = 2,
                                halign = "left",
                                valign = "center"
                            },
                            gui.Label {
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = 30,
                                fontSize = 14,
                                hmargin = 2,
                                halign = "left",
                                valign = "center",
                                refreshToken = function(element, info)
                                    local project = editor:GetProject()
                                    if project then
                                        local progress = project:GetProgress()
                                        local goal = project:GetProjectGoal()
                                        element.text = string.format("%d/%d", progress, goal)
                                    end
                                end
                            }
                        }
                    },

                    -- Status dropdown (DM only) or display
                    gui.Panel {
                        width = "35%",
                        height = 30,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            gui.Label {
                                text = "Status:",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = 30,
                                fontSize = 14,
                                bold = false,
                                hmargin = 2,
                                halign = "left",
                                valign = "center"
                            },
                            isDM and gui.Dropdown {
                                width = "auto",
                                height = 25,
                                classes = {"DTDropdown", "DTBase"},
                                options = DTUIUtils.ListToDropdownOptions(DTConstants.STATUS),
                                refreshToken = function(element, info)
                                    local project = editor:GetProject()
                                    if project then
                                        element.idChosen = DTConstants.GetDisplayText(DTConstants.STATUS, project:GetStatus())
                                    end
                                end,
                                change = function(element)
                                    local project = editor:GetProject()
                                    if project then
                                        -- Find the constant that matches the display text
                                        for _, constant in ipairs(DTConstants.STATUS) do
                                            if constant.displayText == element.idChosen then
                                                project:SetStatus(constant.key)
                                                break
                                            end
                                        end
                                    end
                                end
                            } or gui.Label {
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = 25,
                                fontSize = 14,
                                hmargin = 2,
                                halign = "left",
                                valign = "center",
                                refreshToken = function(element, info)
                                    local project = editor:GetProject()
                                    if project then
                                        element.text = DTConstants.GetDisplayText(DTConstants.STATUS, project:GetStatus())
                                    end
                                end
                            }
                        }
                    },

                    -- Goal input
                    gui.Panel {
                        width = "40%",
                        height = 30,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            gui.Label {
                                text = "Goal:",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = 30,
                                fontSize = 14,
                                bold = false,
                                hmargin = 2,
                                halign = "left",
                                valign = "center"
                            },
                            gui.Input {
                                width = 60,
                                height = 25,
                                classes = {"DTInput", "DTBase"},
                                textAlignment = "center",
                                editlag = 0.25,
                                refreshToken = function(element, info)
                                    local project = editor:GetProject()
                                    if project then
                                        element.text = tostring(project:GetProjectGoal())
                                    end
                                end,
                                edit = function(element)
                                    element:FireEvent("change")
                                end,
                                change = function(element)
                                    local project = editor:GetProject()
                                    if project then
                                        local value = tonumber(element.text) or 1
                                        project:SetProjectGoal(math.max(1, math.floor(value)))
                                    end
                                end
                            }
                        }
                    }
                }
            },

            -- Second row: Characteristic, Language Penalty, Pending Rolls
            gui.Panel {
                width = "100%",
                height = 30,
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    -- Characteristic dropdown
                    gui.Panel {
                        width = "33%",
                        height = 30,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            gui.Label {
                                text = "Char:",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = 30,
                                fontSize = 14,
                                bold = false,
                                hmargin = 2,
                                halign = "left",
                                valign = "center"
                            },
                            gui.Dropdown {
                                width = "auto",
                                height = 25,
                                classes = {"DTDropdown", "DTBase"},
                                options = DTUIUtils.ListToDropdownOptions(DTConstants.CHARACTERISTICS),
                                refreshToken = function(element, info)
                                    local project = editor:GetProject()
                                    if project then
                                        element.idChosen = DTConstants.GetDisplayText(DTConstants.CHARACTERISTICS, project:GetTestCharacteristic())
                                    end
                                end,
                                change = function(element)
                                    local project = editor:GetProject()
                                    if project then
                                        for _, constant in ipairs(DTConstants.CHARACTERISTICS) do
                                            if constant.displayText == element.idChosen then
                                                project:SetTestCharacteristic(constant.key)
                                                break
                                            end
                                        end
                                    end
                                end
                            }
                        }
                    },

                    -- Language Penalty dropdown
                    gui.Panel {
                        width = "34%",
                        height = 30,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            gui.Label {
                                text = "Lang:",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = 30,
                                fontSize = 14,
                                bold = false,
                                hmargin = 2,
                                halign = "left",
                                valign = "center"
                            },
                            gui.Dropdown {
                                width = "auto",
                                height = 25,
                                classes = {"DTDropdown", "DTBase"},
                                options = DTUIUtils.ListToDropdownOptions(DTConstants.LANGUAGE_PENALTY),
                                refreshToken = function(element, info)
                                    local project = editor:GetProject()
                                    if project then
                                        element.idChosen = DTConstants.GetDisplayText(DTConstants.LANGUAGE_PENALTY, project:GetProjectSourceLanguagePenalty())
                                    end
                                end,
                                change = function(element)
                                    local project = editor:GetProject()
                                    if project then
                                        for _, constant in ipairs(DTConstants.LANGUAGE_PENALTY) do
                                            if constant.displayText == element.idChosen then
                                                project:SetProjectSourceLanguagePenalty(constant.key)
                                                break
                                            end
                                        end
                                    end
                                end
                            }
                        }
                    },

                    -- Pending Rolls with +/- buttons
                    gui.Panel {
                        width = "33%",
                        height = 30,
                        flow = "horizontal",
                        halign = "left",
                        valign = "center",
                        children = {
                            gui.Label {
                                text = "Pending:",
                                classes = {"DTLabel", "DTBase"},
                                width = "auto",
                                height = 30,
                                fontSize = 14,
                                bold = false,
                                hmargin = 2,
                                halign = "left",
                                valign = "center"
                            },
                            gui.Button{
                                text = "-",
                                width = 25,
                                height = 25,
                                classes = {"DTButton", "DTBase"},
                                click = function(element)
                                    local project = editor:GetProject()
                                    if project then
                                        local current = project:GetPendingRolls()
                                        if current > 0 then
                                            project:SetPendingRolls(current - 1)
                                        end
                                    end
                                end
                            },
                            gui.Label {
                                classes = {"DTLabel", "DTBase"},
                                width = 30,
                                height = 25,
                                fontSize = 14,
                                textAlignment = "center",
                                halign = "center",
                                valign = "center",
                                refreshToken = function(element, info)
                                    local project = editor:GetProject()
                                    if project then
                                        element.text = tostring(project:GetPendingRolls())
                                    end
                                end
                            },
                            gui.Button{
                                text = "+",
                                width = 25,
                                height = 25,
                                classes = {"DTButton", "DTBase"},
                                click = function(element)
                                    local project = editor:GetProject()
                                    if project then
                                        local current = project:GetPendingRolls()
                                        project:SetPendingRolls(current + 1)
                                    end
                                end
                            }
                        }
                    }
                }
            },

            -- Third row: Prerequisite input
            gui.Panel {
                width = "100%",
                height = 30,
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    gui.Label {
                        text = "Prerequisites:",
                        classes = {"DTLabel", "DTBase"},
                        width = 100,
                        height = 30,
                        fontSize = 14,
                        bold = false,
                        hmargin = 2,
                        halign = "left",
                        valign = "center"
                    },
                    gui.Input {
                        width = "100%-100",
                        height = 25,
                        classes = {"DTInput", "DTBase"},
                        placeholderText = "Required items or prerequisites...",
                        editlag = 0.25,
                        refreshToken = function(element, info)
                            local project = editor:GetProject()
                            if project then
                                element.text = project:GetItemPrerequisite() or ""
                            end
                        end,
                        edit = function(element)
                            element:FireEvent("change")
                        end,
                        change = function(element)
                            local project = editor:GetProject()
                            if project then
                                project:SetItemPrerequisite(element.text)
                            end
                        end
                    }
                }
            },

            -- Fourth row: Source input
            gui.Panel {
                width = "100%",
                height = 30,
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    gui.Label {
                        text = "Source:",
                        classes = {"DTLabel", "DTBase"},
                        width = 100,
                        height = 30,
                        fontSize = 14,
                        bold = false,
                        hmargin = 2,
                        halign = "left",
                        valign = "center"
                    },
                    gui.Input {
                        width = "100%-100",
                        height = 25,
                        classes = {"DTInput", "DTBase"},
                        placeholderText = "Book, tutor, or source of project knowledge...",
                        editlag = 0.25,
                        refreshToken = function(element, info)
                            local project = editor:GetProject()
                            if project then
                                element.text = project:GetProjectSource() or ""
                            end
                        end,
                        edit = function(element)
                            element:FireEvent("change")
                        end,
                        change = function(element)
                            local project = editor:GetProject()
                            if project then
                                project:SetProjectSource(element.text)
                            end
                        end
                    }
                }
            },

            -- Fifth row: Milestone threshold (DM only)
            isDM and gui.Panel {
                width = "100%",
                height = 30,
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    gui.Label {
                        text = "Milestone:",
                        classes = {"DTLabel", "DTBase"},
                        width = 100,
                        height = 30,
                        fontSize = 14,
                        bold = false,
                        hmargin = 2,
                        halign = "left",
                        valign = "center"
                    },
                    gui.Input {
                        width = 60,
                        height = 25,
                        classes = {"DTInput", "DTBase"},
                        textAlignment = "center",
                        placeholderText = "0",
                        editlag = 0.25,
                        refreshToken = function(element, info)
                            local project = editor:GetProject()
                            if project then
                                local threshold = project:GetMilestoneThreshold()
                                element.text = threshold and tostring(threshold) or ""
                            end
                        end,
                        edit = function(element)
                            element:FireEvent("change")
                        end,
                        change = function(element)
                            local project = editor:GetProject()
                            if project then
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
        }
    }

    -- Delete button panel
    local deletePanel = gui.Panel {
        width = 60,
        height = "auto",
        halign = "right",
        valign = "top",
        children = {
            gui.DeleteItemButton {
                width = 20,
                height = 20,
                halign = "center",
                valign = "top",
                hmargin = 5,
                vmargin = 5,
                click = function()
                    local project = editor:GetProject()
                    if project then
                        DTUIUtils.ShowDeleteConfirmation("Project", project:GetTitle(), function()
                            local token = CharacterSheet.instance.data.info.token
                            if token and token.properties and token.properties:IsHero() then
                                local downtimeInfo = token.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
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
        width = "95%",
        height = "auto",
        flow = "horizontal",
        hmargin = 5,
        vmargin = 5,
        children = {
            formPanel,
            deletePanel
        }
    }
end
