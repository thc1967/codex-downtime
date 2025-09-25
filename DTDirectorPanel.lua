local mod = dmhub.GetModLoading()

--- Downtime Director Panel - Main dockable panel for downtime project management
--- Provides the primary interface for directors to manage downtime projects and settings
--- @class DTDirectorPanel
--- @field downtimeSettings DTSettings The downtime settings for shared data management
DTDirectorPanel = RegisterGameType("DTDirectorPanel")
DTDirectorPanel.__index = DTDirectorPanel

--- Creates a new Downtime Director Panel instance
--- @param downtimeSettings DTSettings The downtime settings instance for shared data management
--- @return DTDirectorPanel|nil instance The new panel instance
function DTDirectorPanel:new(downtimeSettings)
    if not downtimeSettings then return nil end

    local instance = setmetatable({}, self)
    instance.downtimeSettings = downtimeSettings
    return instance
end

--- Registers the dockable panel with the Codex UI system
--- Creates and configures the main downtime director interface
function DTDirectorPanel:Register()
    local directorPanel = self
    DockablePanel.Register {
        name = "Downtime Projects",
        icon = mod.images.downtimeProjects,
        minHeight = 100,
        maxHeight = 600,
        content = function()
            local panel = directorPanel:_buildMainPanel()
            directorPanel.panelElement = panel
            return panel
        end
    }
end

--- Builds the main panel structure for the downtime director
--- @return table panel The main GUI panel containing all downtime director elements
function DTDirectorPanel:_buildMainPanel()
    local directorPanel = self
    return gui.Panel {
        width = "100%",
        height = "auto",
        flow = "vertical",
        monitorGame = directorPanel.downtimeSettings:GetDocumentPath(),
        refreshGame = function(element)
            directorPanel:_refreshPanelContent(element)
        end,
        children = {
            self:_buildHeaderPanel(),
            self:_buildContentPanel()
        }
    }
end

--- Builds the header panel containing title and settings summary
--- @return table panel The header panel with title and settings summary
function DTDirectorPanel:_buildHeaderPanel()
    local isPaused = self.downtimeSettings:GetPauseRolls()
    local pauseReason = self.downtimeSettings:GetPauseRollsReason()

    local statusText = string.format("Rolling: %s", isPaused and "Paused" or "Active")

    return gui.Panel {
        width = "100%",
        height = "40",
        flow = "horizontal",
        halign = "left",
        valign = "center",
        styles = DTUIUtils.GetDialogStyles(),
        children = {
            gui.SettingsButton {
                width = 20,
                height = 20,
                halign = "right",
                valign = "center",
                hmargin = 5,
                classes = {"downtime-edit-button"},
                linger = function(element)
                    gui.Tooltip("Edit dowmtime settings")(element)
                end,
                press = function()
                    self:ShowSettingsEditDialog()
                end
            },
            gui.Panel {
                width = "50%",
                height = "100%",
                flow = "vertical",
                halign = "left",
                valign = "center",
                children = {
                    gui.Label {
                        text = statusText,
                        classes = {"DTLabel", "DTBase"},
                        width = "auto",
                        height = "auto",
                        halign = "left",
                        valign = "center"
                    },
                    gui.Label {
                        text = pauseReason,
                        classes = {"DTLabel", "DTBase", (not isPaused) and "collapsed" or nil},
                        fontSize = 12,
                        width = "auto",
                        height = "auto",
                        halign = "left",
                        valign = "center"
                    }
                },
            },
            gui.Button {
                icon = "panels/initiative/initiative-dice.png",
                width = "30",
                height = "30",
                halign = "right",
                valign = "center",
                hmargin = 5,
                borderWidth = 0,
                linger = function(element)
                    gui.Tooltip("Grant rolls to characters")(element)
                end,
                click = function(element)
                    DTGrantRollsDialog:new():ShowDialog()
                end,
            },
            gui.Button {
                text = "DBG",
                width = 60,
                height = 30,
                halign = "right",
                valign = "center",
                hmargin = 5,
                classes = {"DTButton", "DTBase"},
                linger = function(element)
                    gui.Tooltip("Debug document contents")(element)
                end,
                click = function(element)
                    self:_debugDocument()
                end
            },
            gui.Button{
                text = "INIT",
                width = 60,
                height = 30,
                halign = "right",
                valign = "center",
                hmargin = 5,
                classes = {"DTButton", "DTBase"},
                linger = function(element)
                    gui.Tooltip("Clear all data.")(element)
                end,
                click = function(element)
                    self.downtimeSettings:InitializeDocument()
                end
            },
        }
    }
end

--- Shows the settings edit dialog for downtime configuration
--- Allows editing pause rolls setting and reason
function DTDirectorPanel:ShowSettingsEditDialog()
    local isPaused = self.downtimeSettings:GetPauseRolls()
    local pauseReason = self.downtimeSettings:GetPauseRollsReason()

    -- Local variables to track form state
    local newPauseState = isPaused
    local newPauseReason = pauseReason

    local settingsDialog = gui.Panel{
        width = 500,
        height = 300,
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
            -- Title
            gui.Label{
                text = "Edit Downtime Settings",
                width = "100%",
                height = 30,
                fontSize = "24",
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                halign = "center"
            },

            -- Pause rolls checkbox
            DTUIUtils.CreateLabeledCheckbox({
                text = "Pause Rolls",
                value = isPaused,
                change = function(element)
                    newPauseState = element.value
                end
            }, {
                width = "100%",
                height = 60,
                vmargin = 10
            }),

            -- Pause reason input
            DTUIUtils.CreateLabeledInput("Pause Reason", {
                text = pauseReason,
                placeholderText = "Enter reason for pausing rolls...",
                lineType = "Single",
                editlag = 0.25,
                edit = function(element)
                    newPauseReason = element.text or ""
                end
            }, {
                width = "100%",
                height = 60,
                vmargin = 10
            }),

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
                        click = function(element)
                            gui.CloseModal()
                        end
                    },
                    -- Confirm button
                    gui.Button{
                        text = "Save",
                        width = 120,
                        height = 40,
                        hmargin = 20,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            -- Use SetData to minimize server round-trips
                            self.downtimeSettings:SetData(newPauseState, newPauseReason)
                            gui.CloseModal()
                        end
                    }
                }
            }
        },

        escape = function(element)
            gui.CloseModal()
        end
    }

    gui.ShowModal(settingsDialog)
end

--- Debug method to print the raw document contents from persistence
function DTDirectorPanel:_debugDocument()
    local doc = self.downtimeSettings.mod:GetDocumentSnapshot(self.downtimeSettings.documentName)
    print("THC:: PERSISTED::", json(doc.data))
end

--- Builds the main content panel
--- @return table panel The content panel (empty for now)
function DTDirectorPanel:_buildContentPanel()
    return gui.Panel {
        width = "100%",
        height = "auto",
        flow = "vertical",
        children = {
            gui.Label {
                text = "Downtime Projects Panel\n\nReady for implementation.",
                width = "100%",
                height = "100%",
                halign = "center",
                valign = "center",
                textAlignment = "center",
                wrap = true
            }
        }
    }
end

--- Refreshes the panel content (used by both refreshGame and show events)
--- @param element table The main panel element to refresh
function DTDirectorPanel:_refreshPanelContent(element)
    local headerPanel = self:_buildHeaderPanel()
    local contentPanel = self:_buildContentPanel()
    element.children = {headerPanel, contentPanel}
end
