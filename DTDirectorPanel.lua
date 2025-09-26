local mod = dmhub.GetModLoading()
local DEBUG_MODE = false

--- Downtime Director Panel - Main dockable panel for downtime project management
--- Provides the primary interface for directors to manage downtime projects and settings
--- @class DTDirectorPanel
--- @field downtimeSettings DTSettings The downtime settings for shared data management
DTDirectorPanel = RegisterGameType("DTDirectorPanel")
DTDirectorPanel.__index = DTDirectorPanel

--- Clean toggle-style tab styles (no backgrounds, borders, or lines)
DTDirectorPanel.TabsStyles = {
    gui.Style{
        selectors = {"dtTabContainer"},
        height = 24,
        width = "100%",
        flow = "horizontal",
        halign = "left",
        valign = "center",
        hmargin = 5,
    },
    gui.Style{
        selectors = {"dtTab"},
        fontFace = "Berling",
        bold = false,
        valign = "center",
        halign = "center",
        hpad = 6,
        vpad = 4,
        width = 75,
        height = "100%",
        hmargin = 8,
        bgimage = "panels/square.png",
        borderColor = Styles.textColor,
        border = { y1 = 0, y2 = 0, x1 = 0, x2 = 0 },
        color = "#666666",  -- Dim gray for unselected
        textAlignment = "center",
        fontSize = 12,
        transitionTime = 0.2,
    },
    gui.Style{
        selectors = {"dtTab", "hover"},
        color = "#aaaaaa",  -- Medium gray on hover
        borderColor = "#aaaaaa",
        border = { y1 = 1, y2 = 0, x1 = 0, x2 = 0 },
        transitionTime = 0.2,
    },
    gui.Style{
        selectors = {"dtTab", "selected"},
        color = Styles.textColor,  -- Bright white for selected
        bold = true,
        border = { y1 = 1, y2 = 0, x1 = 0, x2 = 0 },
        fontSize = 13,  -- Slightly larger when selected
        transitionTime = 0.2,
    },
}

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
            -- Settings panel - edit button & state
            gui.Panel {
                width = "50%",
                height = "100%",
                flow = "horizontal",
                halign = "left",
                valign = "center",
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
                        width = "100%-20",
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
                }
            },
            -- Buttons panel - roll by default, maybe edit & init if debug
            gui.Panel{
                width = "50%",
                height = "100%",
                flow = "horizontal",
                halign = "right",
                valign = "center",
                children = {
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
                        text = "C",
                        width = 30,
                        height = 30,
                        halign = "right",
                        valign = "center",
                        hmargin = 5,
                        classes = {"DTButton", "DTBase"},
                        linger = function(element)
                            gui.Tooltip("Test categorization")(element)
                        end,
                        click = function(element)
                            self:_debugCategorization()
                        end
                    },
                    gui.Button{
                        text = "I",
                        width = 30,
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
                    gui.Button{
                        text = "D",
                        width = 30,
                        height = 30,
                        halign = "right",
                        valign = "center",
                        hmargin = 5,
                        classes = {"DTButton", "DTBase"},
                        linger = function(element)
                            gui.Tooltip("Clear all data.")(element)
                        end,
                        click = function(element)
                            self:_debugDocument()
                        end
                    },
                }
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

--- Gets all hero characters in the game that have downtime projects
--- @return table characters Array of hero character tokens with downtime projects
function DTDirectorPanel:_getAllCharactersWithDowntimeProjects()
    local allCharacters = {}

    -- Local validation function to check if character meets criteria
    local function isHeroWithDowntime(character)
        if character and character.properties and character.properties:IsHero() then
            local dti = character.properties:try_get("downtime_info")
            if dti and next(dti:GetDowntimeProjects()) then return true end
        end
        return false
    end

    local partyTable = dmhub.GetTable(Party.tableName)
    for partyId, _ in pairs(partyTable) do
        local characterIds = dmhub.GetCharacterIdsInParty(partyId)
        for _, characterId in ipairs(characterIds) do
            local character = dmhub.GetCharacterById(characterId)
            if isHeroWithDowntime(character) then
                allCharacters[#allCharacters + 1] = character
            end
        end
    end

    -- Also get unaffiliated characters (director controlled on current map)
    local unaffiliatedTokens = dmhub.GetTokens{ unaffiliated = true }
    for _, token in ipairs(unaffiliatedTokens) do
        local character = dmhub.GetCharacterById(token.charid)
        if isHeroWithDowntime(character) then
            allCharacters[#allCharacters + 1] = character
        end
    end

    -- Optionally include despawned characters from graveyard
    local despawnedTokens = dmhub.despawnedTokens or {}
    for _, token in ipairs(despawnedTokens) do
        local character = dmhub.GetCharacterById(token.charid)
        if isHeroWithDowntime(character) then
            allCharacters[#allCharacters + 1] = character
        end
    end

    return allCharacters
end

--- Categorizes downtime projects from characters into 4 status-based buckets for tab display
--- @param characters table Array of character objects with downtime projects
--- @return table categorizedProjects Object with attention, milestones, active, completed arrays
function DTDirectorPanel:_categorizeDowntimeProjects(characters)
    local categorized = {
        attention = {},   -- PAUSED projects
        milestones = {},  -- MILESTONE projects
        active = {},      -- ACTIVE and other projects
        completed = {}    -- COMPLETE projects
    }

    for _, character in ipairs(characters) do
        if character and character.properties then
            local characterId = character.id
            local characterName = character.description or "Unknown Character"

            local downtimeInfo = character.properties:try_get("downtime_info")
            if downtimeInfo then
                local projects = downtimeInfo:GetDowntimeProjects()

                for projectId, project in pairs(projects) do
                    local projectEntry = {
                        characterId = characterId,
                        characterName = characterName,
                        projectId = projectId,
                        projectTitle = project:GetTitle(),
                        progress = project:GetProgress(),
                        goal = project:GetProjectGoal(),
                        milestoneThreshold = project:GetMilestoneThreshold()
                    }

                    local status = project:GetStatus()
                    if status == DTConstants.STATUS.PAUSED then
                        categorized.attention[#categorized.attention + 1] = projectEntry
                    elseif status == DTConstants.STATUS.MILESTONE then
                        categorized.milestones[#categorized.milestones + 1] = projectEntry
                    elseif status == DTConstants.STATUS.COMPLETE then
                        categorized.completed[#categorized.completed + 1] = projectEntry
                    else
                        -- ACTIVE or any other status goes to active
                        categorized.active[#categorized.active + 1] = projectEntry
                    end
                end
            end
        end
    end

    return categorized
end

--- Debug method to test the categorization functionality
function DTDirectorPanel:_debugCategorization()
    print("THC:: Testing categorization...")
    local characters = self:_getAllCharactersWithDowntimeProjects()
    print("THC:: Found " .. #characters .. " characters with downtime projects")

    local categorized = self:_categorizeDowntimeProjects(characters)
    print("THC:: Attention projects: " .. #categorized.attention)
    print("THC:: Milestones projects: " .. #categorized.milestones)
    print("THC:: Active projects: " .. #categorized.active)
    print("THC:: Completed projects: " .. #categorized.completed)

    -- Print details for first project in each category
    if #categorized.attention > 0 then
        local p = categorized.attention[1]
        print("THC:: Sample attention project: " .. p.characterName .. " - " .. p.projectTitle .. " (" .. p.progress .. "/" .. p.goal .. ")")
    end
    if #categorized.milestones > 0 then
        local p = categorized.milestones[1]
        print("THC:: Sample milestone project: " .. p.characterName .. " - " .. p.projectTitle .. " (" .. p.progress .. "/" .. p.goal .. ")")
    end
    if #categorized.active > 0 then
        local p = categorized.active[1]
        print("THC:: Sample active project: " .. p.characterName .. " - " .. p.projectTitle .. " (" .. p.progress .. "/" .. p.goal .. ")")
    end
    if #categorized.completed > 0 then
        local p = categorized.completed[1]
        print("THC:: Sample completed project: " .. p.characterName .. " - " .. p.projectTitle .. " (" .. p.progress .. "/" .. p.goal .. ")")
    end
end

--- Builds the main content panel with tabs
--- @return table panel The tabbed content panel
function DTDirectorPanel:_buildContentPanel()
    local directorPanel = self

    -- Create placeholder content panels for each tab
    local attentionPanel = gui.Panel {
        width = "100%",
        height = "auto",
        flow = "vertical",
        children = {
            gui.Label {
                text = "Attention Tab\n\nPlaceholder content.",
                width = "100%",
                height = "100%",
                halign = "center",
                valign = "center",
                textAlignment = "center",
                classes = {"DTLabel", "DTBase"},
                wrap = true
            }
        }
    }

    local milestonesPanel = gui.Panel {
        width = "100%",
        height = "auto",
        flow = "vertical",
        classes = {"hidden"},
        children = {
            gui.Label {
                text = "Milestones Tab\n\nPlaceholder content.",
                width = "100%",
                height = "100%",
                halign = "center",
                valign = "center",
                textAlignment = "center",
                classes = {"DTLabel", "DTBase"},
                wrap = true
            }
        }
    }

    local activePanel = gui.Panel {
        width = "100%",
        height = "auto",
        flow = "vertical",
        classes = {"hidden"},
        children = {
            gui.Label {
                text = "Active Tab\n\nPlaceholder content.",
                width = "100%",
                height = "100%",
                halign = "center",
                valign = "center",
                textAlignment = "center",
                classes = {"DTLabel", "DTBase"},
                wrap = true
            }
        }
    }

    local completedPanel = gui.Panel {
        width = "100%",
        height = "auto",
        flow = "vertical",
        classes = {"hidden"},
        children = {
            gui.Label {
                text = "Completed Tab\n\nPlaceholder content.",
                width = "100%",
                height = "100%",
                halign = "center",
                valign = "center",
                textAlignment = "center",
                classes = {"DTLabel", "DTBase"},
                wrap = true
            }
        }
    }

    local tabPanels = {attentionPanel, milestonesPanel, activePanel, completedPanel}

    -- Content panel that holds all tab panels
    local contentPanel = gui.Panel{
        width = "100%",
        height = "100%-70",
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

    -- Tab selection function
    local selectTab = function(tabName)
        local index = tabName == "Attention" and 1 or
                      tabName == "Milestones" and 2 or
                      tabName == "Active" and 3 or 4

        contentPanel:FireEventTree("showTab", index)

        for _, tab in ipairs(tabsPanel.children) do
            if tab.data and tab.data.tabName then
                tab:SetClass("selected", tab.data.tabName == tabName)
            end
        end
    end

    -- Create tabs panel
    tabsPanel = gui.Panel{
        classes = {"dtTabContainer"},
        styles = {DTDirectorPanel.TabsStyles},
        children = {
            gui.Label{
                classes = {"dtTab", "selected"},
                text = "Attention",
                data = {tabName = "Attention"},
                press = function() selectTab("Attention") end,
            },
            gui.Label{
                classes = {"dtTab"},
                text = "Milestones",
                data = {tabName = "Milestones"},
                press = function() selectTab("Milestones") end,
            },
            gui.Label{
                classes = {"dtTab"},
                text = "Active",
                data = {tabName = "Active"},
                press = function() selectTab("Active") end,
            },
            gui.Label{
                classes = {"dtTab"},
                text = "Completed",
                data = {tabName = "Completed"},
                press = function() selectTab("Completed") end,
            }
        }
    }

    return gui.Panel {
        width = "100%",
        height = "auto",
        flow = "vertical",
        styles = {DTDirectorPanel.TabsStyles},
        children = {
            tabsPanel,
            contentPanel
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

--- Debug method to print the raw document contents from persistence
function DTDirectorPanel:_debugDocument()
    local doc = self.downtimeSettings.mod:GetDocumentSnapshot(self.downtimeSettings.documentName)
    print("THC:: PERSISTED::", json(doc.data))
end
