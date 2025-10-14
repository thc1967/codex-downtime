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
        id = "downtimeController",
        classes = {"downtimeController"},
        bgimage = true,
        bgcolor = "clear",
        width = "100%",
        height = "100%",
        flow = "vertical",
        valign = "top",
        halign = "center",
        styles = DTUtils.GetDialogStyles(),
        data = {
            getDowntimeInfo = function()
                return CharacterSheet.instance.data.info.token.properties:GetDowntimeInfo()
            end,
        },

        deleteProject = function(element, projectId)
            if projectId and type(projectId) == "string" and #projectId then
                local downtimeInfo = element.data.getDowntimeInfo()
                if downtimeInfo then
                    downtimeInfo:RemoveProject(projectId)
                    DTSettings.Touch()
                    element:FireEventTree("refreshToken")
                end
            end
        end,

        adjustRolls = function(element, amount)
            local downtimeInfo = element.data.getDowntimeInfo()
            downtimeInfo:SetAvailableRolls(downtimeInfo:GetAvailableRolls() + amount)
            DTSettings.Touch()
            element:FireEventTree("refreshToken")
        end,

        children = {
            DTCharSheetTab._createHeaderPanel(),
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
                        hmargin = 20,
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
                                create = function(element)
                                    dmhub.Schedule(0.2, function()
                                        element.monitorGame = DTSettings:new():GetDocumentPath()
                                    end)
                                end,
                                refreshGame = function(element)
                                    element:FireEvent("refreshToken")
                                end,
                                refreshToken = function(element)
                                    local status = "UNKNOWN"
                                    local settings = DTSettings:new()
                                    if settings then
                                        status = settings:GetPauseRolls() and "PAUSED" or "AVAILABLE"
                                    end
                                    element.text = status
                                    element:SetClass("DTStatusAvailable", status == "AVAILABLE")
                                    element:SetClass("DTStatusPaused", status ~= "AVAILABLE")
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
                                create = function(element)
                                    dmhub.Schedule(0.2, function()
                                        element.monitorGame = DTSettings:new():GetDocumentPath()
                                    end)
                                end,
                                refreshGame = function(element)
                                    element:FireEvent("refreshToken")
                                end,
                                refreshToken = function(element)
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

            -- Available Rolls
            gui.Panel {
                width = "45%",
                height = "100%",
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    gui.Label {
                        text = "Calculating available rolls...",
                        classes = {"DTLabel", "DTBase"},
                        width = "100%",
                        height = "100%",
                        halign = "left",
                        valign = "center",
                        hmargin = "20",
                        fontSize = 20,
                        create = function(element)
                            dmhub.Schedule(0.2, function()
                                element.monitorGame = DTSettings:new():GetDocumentPath()
                            end)
                        end,
                        refreshGame = function(element)
                            element:FireEvent("refreshToken")
                        end,
                        refreshToken = function(element)
                            local fmt = "Available Rolls: %d%s"
                            local availableRolls = 0
                            local msg = ""
                            if CharacterSheet.instance.data.info then
                                local token = CharacterSheet.instance.data.info.token
                                if token and token.properties and token.properties:IsHero() then
                                    local downtimeInfo = token.properties:try_get(DTConstants.CHARACTER_STORAGE_KEY)
                                    if downtimeInfo then
                                        availableRolls = downtimeInfo:GetAvailableRolls()
                                    else
                                        msg = " (Can't get downtime info)"
                                    end
                                else
                                    msg = " (WTF not a character)"
                                end
                                element.text = string.format(fmt, availableRolls, msg)
                            else
                                print("THC:: BOOM:: DTCharSheetTab._createHeaderPanel refreshToken Avail Rolls Label")
                            end
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
                            if CharacterSheet.instance.data.info then
                                local token = CharacterSheet.instance.data.info.token
                                if token and token.properties and token.properties:IsHero() then
                                    local downtimeInfo = token.properties:get_or_add(DTConstants.CHARACTER_STORAGE_KEY, DTInfo:new())
                                    if downtimeInfo then
                                        downtimeInfo:AddProject()
                                        DTSettings.Touch()
                                        local scrollArea = CharacterSheet.instance:Get("projectScrollArea")
                                        if scrollArea then
                                            scrollArea:FireEventTree("refreshToken")
                                        end
                                    end
                                end
                            else
                                print("THC:: BOOM:: DTCharSheetTab._createHeaderPanel click Add Button")
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
            -- Scrollable projects area
            gui.Panel{
                width = "100%",
                height = "100%",
                valign = "top",
                vscroll = true,
                styles = DTUtils.GetDialogStyles(),
                children = {
                    -- Inner auto-height container that pins content to top
                    gui.Panel{
                        id = "projectScrollArea",
                        classes = {"projectListController"},
                        width = "100%",
                        height = "auto",
                        flow = "vertical",
                        halign = "center",
                        valign = "top",
                        create = function(element)
                            dmhub.Schedule(0.2, function()
                                element.monitorGame = DTShares:new():GetDocumentPath()
                            end)
                        end,
                        refreshGame = function(element)
                            element:FireEvent("refreshToken")
                        end,
                        refreshToken = function(element)
                            DTCharSheetTab._refreshProjectsList(element)
                        end
                    }
                }
            }
        }
    }
end

--- Refreshes the projects list display
--- Reconciles existing editor panels with current project list to avoid expensive panel recreation
--- @param element table The projects list container element
function DTCharSheetTab._refreshProjectsList(element)
    if CharacterSheet.instance.data.info == nil then
        print("THC:: BOOM:: DTCharSheetTab._refreshProjectsList")
        return
    end
    local token = CharacterSheet.instance.data.info.token
    if not token or not token.properties or not token.properties:IsHero() then
        element.children = {}
        return
    end

    local sharedProjects = DTUtils.GetSharedProjectsForRecipient(token.id)

    local downtimeInfo = token.properties:GetDowntimeInfo()
    if not downtimeInfo and #sharedProjects == 0 then
        -- Show "no projects" message only if no shared projects either
        element.children = {
            gui.Label {
                text = "(ERROR: unable to create downtime info)",
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
    if (not projects or #projects == 0) and #sharedProjects == 0 then
        -- Show "no projects" message only if no shared projects either
        element.children = {
            gui.Label {
                text = "No projects yet.\nClick the Add button to create one.",
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

    -- Reconcile existing panels with current projects
    local panels = element.children or {}

    -- Step 1: Remove panels for projects that no longer exist OR have wrong type
    for i = #panels, 1, -1 do
        local panel = panels[i]
        local isSharedPanel = panel:HasClass("sharedProject")
        local shouldRemove = true

        -- Check owned projects (should NOT be shared panel)
        for _, project in ipairs(projects) do
            if project:GetID() == panel.id then
                if not isSharedPanel then
                    shouldRemove = false
                end
                break
            end
        end

        -- If not matched in owned, check shared projects (MUST be shared panel)
        if shouldRemove then
            for _, entry in ipairs(sharedProjects) do
                if entry.project:GetID() == panel.id then
                    if isSharedPanel then
                        shouldRemove = false
                    end
                    break
                end
            end
        end

        if shouldRemove then
            table.remove(panels, i)
        end
    end

    -- Step 2: Add panels for new projects that don't have panels yet

    -- Add panels for owned projects
    for _, project in ipairs(projects) do
        local foundPanel = false
        for _, panel in ipairs(panels) do
            -- Must match ID AND be an owned panel (not shared)
            if panel.id == project:GetID() and not panel:HasClass("sharedProject") then
                foundPanel = true
                break
            end
        end
        if not foundPanel then
            panels[#panels + 1] = DTProjectEditor:new(project):CreateEditorPanel()
        end
    end

    -- Add panels for shared projects
    for _, entry in ipairs(sharedProjects) do
        local foundPanel = false
        for _, panel in ipairs(panels) do
            -- Must match ID AND be a shared panel
            if panel.id == entry.project:GetID() and panel:HasClass("sharedProject") then
                foundPanel = true
                break
            end
        end
        if not foundPanel then
            panels[#panels + 1] = DTProjectEditor:new(entry.project):CreateSharedProjectPanel(entry.ownerName, entry.ownerId)
        end
    end

    -- Step 3: Sort panels - owned projects first (by sort order), then shared projects (by sort order)
    local projectSortOrder = {}

    -- Add owned projects with their natural sort order
    for _, project in ipairs(projects) do
        projectSortOrder[project:GetID()] = project:GetSortOrder()
    end

    -- Add shared projects with offset to ensure they come after owned projects
    for _, entry in ipairs(sharedProjects) do
        -- Offset by 1000000 to ensure shared projects come after owned projects
        projectSortOrder[entry.project:GetID()] = 1000000 + entry.project:GetSortOrder()
    end

    table.sort(panels, function(a, b)
        local aOrder = projectSortOrder[a.id] or 999999
        local bOrder = projectSortOrder[b.id] or 999999
        return aOrder < bOrder
    end)

    element.children = panels
end
