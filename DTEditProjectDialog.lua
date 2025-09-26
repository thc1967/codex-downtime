--- Edit Project Dialog - Tabbed dialog for editing downtime project information
--- Provides interface for editing project details, rolls, and adjustments
--- @class DTEditProjectDialog
--- @field project DTDowntimeProject The project being edited
--- @field dialogElement table Reference to the main dialog GUI panel element
--- @field confirmButton table Reference to the confirm button for enabling/disabling
--- @field formData table Local form state tracking
--- @field currentTab string Current active tab name
DTEditProjectDialog = RegisterGameType("DTEditProjectDialog")
DTEditProjectDialog.__index = DTEditProjectDialog

--- Tab styling following QuestManagerWindow patterns
DTEditProjectDialog.TabsStyles = {
    gui.Style{
        selectors = {"dtEditTabContainer"},
        height = 40,
        width = "100%",
        flow = "horizontal",
        bgcolor = "black",
        bgimage = "panels/square.png",
        borderColor = Styles.textColor,
        border = { y1 = 2 },
        vmargin = 1,
        hmargin = 2,
        halign = "center",
        valign = "top",
    },
    gui.Style{
        selectors = {"dtEditTab"},
        fontFace = "Berling",
        bold = false,
        bgcolor = "#111111ff",
        bgimage = "panels/square.png",
        brightness = 0.4,
        valign = "top",
        halign = "left",
        hpad = 20,
        width = 200,
        height = "100%",
        hmargin = 0,
        color = Styles.textColor,
        fontSize = 20,
        minFontSize = 12,
    },
    gui.Style{
        selectors = {"dtEditTab", "hover"},
        brightness = 1.2,
        transitionTime = 0.2,
    },
    gui.Style{
        selectors = {"dtEditTab", "selected"},
        brightness = 1,
        transitionTime = 0.2,
    },
    gui.Style{
        selectors = {"dtEditTabBorder"},
        width = "100%",
        height = "100%",
        border = {x1 = 2, x2 = 2, y1 = 2},
        borderColor = Styles.textColor,
        bgimage = "panels/square.png",
        bgcolor = "clear",
    },
    gui.Style{
        selectors = {"dtEditTabBorder", "parent:selected"},
        border = {x1 = 2, x2 = 2, y1 = 0}
    },
}

--- Creates a new Edit Project Dialog instance
--- @param project DTDowntimeProject The project to edit
--- @return DTEditProjectDialog instance The new dialog instance
function DTEditProjectDialog:new(project)
    if not project then return nil end

    local instance = setmetatable({}, self)

    -- Core references
    instance.project = project
    instance.dialogElement = nil
    instance.confirmButton = nil
    instance.currentTab = "Project"

    -- Form state tracking
    instance.formData = {
        title = project:GetTitle(),
        itemPrerequisite = project:GetItemPrerequisite(),
        projectSource = project:GetProjectSource(),
        projectSourceLanguagePenalty = project:GetProjectSourceLanguagePenalty(),
        testCharacteristic = project:GetTestCharacteristic(),
        projectGoal = project:GetProjectGoal(),
        status = project:GetStatus(),
        statusReason = project:GetStatusReason(),
        milestoneThreshold = project:GetMilestoneThreshold(),
        pendingRolls = project:GetPendingRolls()
    }

    return instance
end

--- Shows the edit project dialog modal
--- @param onSave function Callback function called with project when user saves
--- @param onCancel function|nil Optional callback function called when user cancels
function DTEditProjectDialog:ShowDialog(onSave, onCancel)
    local dialog = self

    -- Store callbacks
    dialog.onSaveCallback = onSave
    dialog.onCancelCallback = onCancel

    -- Build styles array with invalid button styling
    local dialogStyles = DTUIUtils.GetDialogStyles()
    dialogStyles[#dialogStyles + 1] = gui.Style{
        selectors = {'DTButton', 'DTBase', 'invalid'},
        bgcolor = '#222222',
        borderColor = '#444444',
    }

    -- Add tab styles
    for _, style in ipairs(DTEditProjectDialog.TabsStyles) do
        dialogStyles[#dialogStyles + 1] = style
    end

    local editProjectDialog = gui.Panel{
        width = 800,
        height = 600,
        halign = "center",
        valign = "center",
        bgcolor = "#111111ff",
        borderWidth = 2,
        borderColor = Styles.textColor,
        bgimage = "panels/square.png",
        flow = "vertical",
        styles = dialogStyles,

        children = {
            -- Title
            gui.Label{
                text = "Edit Downtime Project",
                width = "100%",
                height = 30,
                fontSize = 24,
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                halign = "center",
                vmargin = 10
            },

            -- Main content area with tabs
            dialog:_createMainContent(),

            -- Button panel
            gui.Panel{
                width = "100%",
                height = 50,
                halign = "center",
                valign = "center",
                flow = "horizontal",
                children = {
                    -- Cancel button
                    gui.Button{
                        text = "Cancel",
                        width = 120,
                        height = 40,
                        hmargin = 20,
                        classes = {"DTButton", "DTBase"},
                        escapePriority = EscapePriority.EXIT_DIALOG,
                        click = function(element)
                            if dialog:try_get("onCancelCallback") then
                                dialog.onCancelCallback()
                            end
                            gui.CloseModal()
                        end
                    },
                    -- Confirm button (stored for enabling/disabling)
                    gui.Button{
                        text = "Confirm",
                        width = 120,
                        height = 40,
                        hmargin = 20,
                        classes = {"DTButton", "DTBase"},
                        create = function(element)
                            dialog.confirmButton = element
                            dialog:_validateForm()
                        end,
                        click = function(element)
                            dialog:_onConfirm()
                        end
                    }
                }
            }
        },

        -- escape = function(element)
        --     if dialog:try_get("onCancelCallback") then
        --         dialog.onCancelCallback()
        --     end
        --     gui.CloseModal()
        -- end
    }

    dialog.dialogElement = editProjectDialog
    gui.ShowModal(editProjectDialog)
end

--- Creates the main content area with tabs
--- @return table panel The main content panel with tabs
function DTEditProjectDialog:_createMainContent()
    local dialog = self

    -- Tab content panels
    local projectPanel = dialog:_createProjectTab()

    local rollsPanel = dialog:_createRollsTab()
    rollsPanel.classes = {"hidden"}

    local adjustmentsPanel = dialog:_createAdjustmentsTab()
    adjustmentsPanel.classes = {"hidden"}

    local tabPanels = {projectPanel, rollsPanel, adjustmentsPanel}

    -- Content panel that holds all tab panels
    local contentPanel = gui.Panel{
        width = "100%",
        height = "100%-100",
        flow = "none",
        valign = "top",
        children = tabPanels,

        showTab = function(element, tabIndex)
            for i, p in ipairs(tabPanels) do
                if p ~= nil then
                    local hidden = (tabIndex ~= i)
                    p:SetClass("hidden", hidden)
                end
            end
        end,
    }

    local tabsPanel

    local selectTab = function(tabName)
        dialog.currentTab = tabName
        local index = tabName == "Project" and 1 or tabName == "Rolls" and 2 or 3

        contentPanel:FireEventTree("showTab", index)

        for _, tab in ipairs(tabsPanel.children) do
            if tab.data and tab.data.tabName then
                tab:SetClass("selected", tab.data.tabName == tabName)
            end
        end
    end

    -- Create tabs panel
    tabsPanel = gui.Panel{
        classes = {"dtEditTabContainer"},
        children = {
            gui.Label{
                classes = {"dtEditTab", "selected"},
                text = "Project",
                data = {tabName = "Project"},
                press = function() selectTab("Project") end,
                gui.Panel{classes = {"dtEditTabBorder"}},
            },
            gui.Label{
                classes = {"dtEditTab"},
                text = "Rolls",
                data = {tabName = "Rolls"},
                press = function() selectTab("Rolls") end,
                gui.Panel{classes = {"dtEditTabBorder"}},
            },
            gui.Label{
                classes = {"dtEditTab"},
                text = "Adjustments",
                data = {tabName = "Adjustments"},
                press = function() selectTab("Adjustments") end,
                gui.Panel{classes = {"dtEditTabBorder"}},
            }
        }
    }

    return gui.Panel{
        width = "100%",
        height = "100%",
        flow = "vertical",
        children = {
            tabsPanel,
            contentPanel
        }
    }
end

--- Creates the Project tab panel
--- @return table panel The project tab panel
function DTEditProjectDialog:_createProjectTab()
    return gui.Panel{
        id = "projectTabPanel",
        width = "100%",
        height = "100%",
        flow = "vertical",
        valign = "top",
        children = {
            self:_buildProjectForm()
        }
    }
end

--- Creates the Rolls tab panel (placeholder)
--- @return table panel The rolls tab panel
function DTEditProjectDialog:_createRollsTab()
    return gui.Panel{
        id = "rollsTabPanel",
        width = "100%",
        height = "100%",
        flow = "vertical",
        children = {
            gui.Label{
                text = "Rolls Tab\n\nPlaceholder content for project rolls history and management.",
                width = "100%",
                height = "100%",
                halign = "center",
                valign = "center",
                textAlignment = "center",
                classes = {"DTLabel", "DTBase"},
                textWrap = true
            }
        }
    }
end

--- Creates the Adjustments tab panel (placeholder)
--- @return table panel The adjustments tab panel
function DTEditProjectDialog:_createAdjustmentsTab()
    return gui.Panel{
        id = "adjustmentsTabPanel",
        width = "100%",
        height = "100%",
        flow = "vertical",
        children = {
            gui.Label{
                text = "Adjustments Tab\n\nPlaceholder content for project progress adjustments history and management.",
                width = "100%",
                height = "100%",
                halign = "center",
                valign = "center",
                textAlignment = "center",
                classes = {"DTLabel", "DTBase"},
                textWrap = true
            }
        }
    }
end

--- Builds the project form for the Project tab
--- @return table panel The project form panel
function DTEditProjectDialog:_buildProjectForm()
    local dialog = self
    local isDM = dmhub.isDM

    -- Dropdown options
    local languagePenaltyOptions = DTUIUtils.ListToDropdownOptions(DTConstants.LANGUAGE_PENALTY)
    local characteristicOptions = DTUIUtils.ListToDropdownOptions(DTConstants.CHARACTERISTICS)
    print("THC:: CHAROPTS::", json(characteristicOptions))
    local statusOptions = DTUIUtils.ListToDropdownOptions(DTConstants.STATUS)

    return gui.Panel{
        width = "100%",
        height = "100%",
        flow = "vertical",
        valign = "top",
        hpad = 20,
        vpad = 10,
        children = {
            -- Row 1: Title field
            gui.Panel{
                width = "100%",
                height = 50,
                flow = "vertical",
                vmargin = 2,
                children = {
                    gui.Label{
                        text = "Title:",
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = 20
                    },
                    gui.Input{
                        width = "100%",
                        height = 25,
                        classes = {"DTInput", "DTBase"},
                        text = dialog.formData.title,
                        placeholderText = "Enter project title...",
                        editlag = 0.25,
                        edit = function(element)
                            dialog.formData.title = element.text
                            dialog:_validateForm()
                        end
                    }
                }
            },

            -- Row 2: Item Prerequisite field
            gui.Panel{
                width = "100%",
                height = 50,
                flow = "vertical",
                vmargin = 2,
                children = {
                    gui.Label{
                        text = "Item Prerequisite:",
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = 20
                    },
                    gui.Input{
                        width = "100%",
                        height = 25,
                        classes = {"DTInput", "DTBase"},
                        text = dialog.formData.itemPrerequisite,
                        placeholderText = "Required items or prerequisites...",
                        editlag = 0.25,
                        edit = function(element)
                            dialog.formData.itemPrerequisite = element.text
                        end
                    }
                }
            },

            -- Row 3: Project Source field
            gui.Panel{
                width = "100%",
                height = 50,
                flow = "vertical",
                vmargin = 2,
                children = {
                    gui.Label{
                        text = "Project Source:",
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = 20
                    },
                    gui.Input{
                        width = "100%",
                        height = 25,
                        classes = {"DTInput", "DTBase"},
                        text = dialog.formData.projectSource,
                        placeholderText = "Book, tutor, or source of project knowledge...",
                        editlag = 0.25,
                        edit = function(element)
                            dialog.formData.projectSource = element.text
                        end
                    }
                }
            },

            -- Row 4: Source Language Penalty | Test Characteristic
            gui.Panel{
                width = "100%",
                height = 60,
                flow = "horizontal",
                vmargin = 2,
                children = {
                    gui.Panel{
                        width = "50%",
                        height = 60,
                        flow = "vertical",
                        hmargin = 5,
                        children = {
                            gui.Label{
                                text = "Language Penalty:",
                                classes = {"DTLabel", "DTBase"},
                                width = "100%",
                                height = 20
                            },
                            gui.Dropdown{
                                width = "90%",
                                height = 25,
                                classes = {"DTDropdown", "DTBase"},
                                options = languagePenaltyOptions,
                                idChosen = dialog.formData.projectSourceLanguagePenalty,
                                change = function(element)
                                    dialog.formData.projectSourceLanguagePenalty = element.idChosen
                                end
                            }
                        }
                    },
                    gui.Panel{
                        width = "50%",
                        height = 60,
                        flow = "vertical",
                        hmargin = 5,
                        children = {
                            gui.Label{
                                text = "Test Characteristic:",
                                classes = {"DTLabel", "DTBase"},
                                width = "100%",
                                height = 20
                            },
                            gui.Dropdown{
                                width = "90%",
                                height = 25,
                                classes = {"DTDropdown", "DTBase"},
                                options = characteristicOptions,
                                idChosen = dialog.formData.testCharacteristic,
                                change = function(element)
                                    dialog.formData.testCharacteristic = element.idChosen
                                    dialog:_validateForm()
                                end
                            }
                        }
                    }
                }
            },

            -- Row 5: Project Goal | Progress Display | Pending Rolls
            gui.Panel{
                width = "100%",
                height = 60,
                flow = "horizontal",
                vmargin = 2,
                children = {
                    gui.Panel{
                        width = "33%",
                        height = 60,
                        flow = "vertical",
                        hmargin = 2,
                        children = {
                            gui.Label{
                                text = "Project Goal:",
                                classes = {"DTLabel", "DTBase"},
                                width = "100%",
                                height = 20
                            },
                            gui.Input{
                                width = "90%",
                                height = 25,
                                classes = {"DTInput", "DTBase"},
                                text = tostring(dialog.formData.projectGoal),
                                placeholderText = "Goal points...",
                                editlag = 0.25,
                                edit = function(element)
                                    local value = tonumber(element.text) or 0
                                    dialog.formData.projectGoal = math.max(1, math.floor(value))
                                    dialog:_validateForm()
                                end
                            }
                        }
                    },
                    gui.Panel{
                        width = "34%",
                        height = 60,
                        flow = "vertical",
                        hmargin = 2,
                        children = {
                            gui.Label{
                                text = "Progress:",
                                classes = {"DTLabel", "DTBase"},
                                width = "100%",
                                height = 20
                            },
                            gui.Label{
                                text = string.format("%d / %d", dialog.project:GetProgress(), dialog.formData.projectGoal),
                                classes = {"DTLabel", "DTBase"},
                                width = "90%",
                                height = 25,
                                fontSize = 16,
                                halign = "left",
                                valign = "center"
                            }
                        }
                    },
                    gui.Panel{
                        width = "33%",
                        height = 60,
                        flow = "vertical",
                        hmargin = 2,
                        children = {
                            gui.Label{
                                text = "Pending Rolls:",
                                classes = {"DTLabel", "DTBase"},
                                width = "100%",
                                height = 20
                            },
                            dialog:_buildPendingRollsField()
                        }
                    }
                }
            },

            -- Row 6: Status | Status Reason
            gui.Panel{
                width = "100%",
                height = 60,
                flow = "horizontal",
                vmargin = 2,
                children = {
                    gui.Panel{
                        width = "50%",
                        height = 60,
                        flow = "vertical",
                        hmargin = 5,
                        children = {
                            gui.Label{
                                text = "Status:",
                                classes = {"DTLabel", "DTBase"},
                                width = "100%",
                                height = 20
                            },
                            isDM and gui.Dropdown{
                                width = "90%",
                                height = 25,
                                classes = {"DTDropdown", "DTBase"},
                                options = statusOptions,
                                idChosen = dialog.formData.status,
                                change = function(element)
                                    dialog.formData.status = element.idChosen
                                end
                            } or gui.Label{
                                text = dialog.formData.status,
                                classes = {"DTLabel", "DTBase"},
                                width = "90%",
                                height = 25,
                                fontSize = 16,
                                halign = "left",
                                valign = "center"
                            }
                        }
                    },
                    gui.Panel{
                        width = "50%",
                        height = 60,
                        flow = "vertical",
                        hmargin = 5,
                        children = {
                            gui.Label{
                                text = "Status Reason:",
                                classes = {"DTLabel", "DTBase"},
                                width = "100%",
                                height = 20
                            },
                            isDM and gui.Input{
                                width = "90%",
                                height = 25,
                                classes = {"DTInput", "DTBase"},
                                text = dialog.formData.statusReason,
                                placeholderText = "Reason for current status...",
                                editlag = 0.25,
                                edit = function(element)
                                    dialog.formData.statusReason = element.text
                                end
                            } or (function()
                                local shouldShow = dialog.formData.status ~= DTConstants.STATUS.ACTIVE and
                                                  dialog.formData.status ~= DTConstants.STATUS.COMPLETE
                                return shouldShow and gui.Label{
                                    text = dialog.formData.statusReason,
                                    classes = {"DTLabel", "DTBase"},
                                    width = "90%",
                                    height = 25,
                                    fontSize = 16,
                                    halign = "left",
                                    valign = "center"
                                } or gui.Panel{width = "90%", height = 25}
                            end)()
                        }
                    }
                }
            },

            -- Row 7: Directors only - Milestone Threshold
            isDM and gui.Panel{
                width = "100%",
                height = 50,
                flow = "vertical",
                vmargin = 2,
                children = {
                    gui.Label{
                        text = "Milestone Threshold:",
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = 20
                    },
                    gui.Input{
                        width = "100%",
                        height = 25,
                        classes = {"DTInput", "DTBase"},
                        text = dialog.formData.milestoneThreshold and tostring(dialog.formData.milestoneThreshold) or "",
                        placeholderText = "Progress threshold for milestone pause (optional)...",
                        editlag = 0.25,
                        edit = function(element)
                            if element.text == "" then
                                dialog.formData.milestoneThreshold = nil
                            else
                                local value = tonumber(element.text) or 0
                                dialog.formData.milestoneThreshold = math.max(0, math.floor(value))
                            end
                        end
                    }
                }
            } or gui.Panel{height = 1}
        }
    }
end

--- Builds the pending rolls input field with +/- buttons
--- @return table panel The pending rolls input panel
function DTEditProjectDialog:_buildPendingRollsField()
    local dialog = self

    return gui.Panel{
        width = "90%",
        height = 25,
        flow = "horizontal",
        halign = "left",
        valign = "center",
        children = {
            -- Minus button
            gui.Button{
                text = "-",
                width = 25,
                height = 25,
                classes = {"DTButton", "DTBase"},
                click = function(element)
                    if dialog.formData.pendingRolls > 0 then
                        dialog.formData.pendingRolls = dialog.formData.pendingRolls - 1
                        dialog:_refreshPendingRollsDisplay()
                    end
                end
            },
            -- Number display
            gui.Label{
                text = tostring(dialog.formData.pendingRolls),
                width = 40,
                height = 25,
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                halign = "center",
                valign = "center",
                fontSize = 16,
                create = function(element)
                    dialog.pendingRollsLabel = element
                end
            },
            -- Plus button
            gui.Button{
                text = "+",
                width = 25,
                height = 25,
                classes = {"DTButton", "DTBase"},
                click = function(element)
                    dialog.formData.pendingRolls = dialog.formData.pendingRolls + 1
                    dialog:_refreshPendingRollsDisplay()
                end
            }
        }
    }
end

--- Refreshes the pending rolls display
function DTEditProjectDialog:_refreshPendingRollsDisplay()
    if self.pendingRollsLabel then
        self.pendingRollsLabel.text = tostring(self.formData.pendingRolls)
    end
end

--- Validates the form and enables/disables the Confirm button
function DTEditProjectDialog:_validateForm()
    if self.confirmButton ~= nil then
        local isValid = self:_isFormValid()
        self.confirmButton:SetClass("invalid", not isValid)
        self.confirmButton.interactable = isValid
    end
end

--- Checks if the form data is valid
--- @return boolean valid True if form is valid
function DTEditProjectDialog:_isFormValid()
    local hasTitle = self.formData.title and self.formData.title:trim() ~= ""
    local hasCharacteristic = self.formData.testCharacteristic and self.formData.testCharacteristic ~= ""
    local hasValidGoal = self.formData.projectGoal and tonumber(self.formData.projectGoal) and tonumber(self.formData.projectGoal) > 0

    return hasTitle and hasCharacteristic and hasValidGoal
end

--- Handles the confirm button click - saves changes and closes dialog
function DTEditProjectDialog:_onConfirm()
    print("THC:: DLGONCONFIRM::")
    if not self:_isFormValid() then return end

    -- Apply form data to project
    self.project:SetTitle(self.formData.title)
    self.project:SetItemPrerequisite(self.formData.itemPrerequisite)
    self.project:SetProjectSource(self.formData.projectSource)
    self.project:SetProjectSourceLanguagePenalty(self.formData.projectSourceLanguagePenalty)
    self.project:SetTestCharacteristic(self.formData.testCharacteristic)
    self.project:SetProjectGoal(self.formData.projectGoal)
    self.project:SetStatus(self.formData.status)
    self.project:SetStatusReason(self.formData.statusReason)
    self.project:SetMilestoneThreshold(self.formData.milestoneThreshold)
    self.project:SetPendingRolls(self.formData.pendingRolls)

    -- Call onSave callback with the modified project
    if self.onSaveCallback then
        self.onSaveCallback(self.project)
    end

    gui.CloseModal()
end