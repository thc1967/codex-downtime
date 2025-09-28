--- Grant Rolls Dialog - Dialog for granting downtime rolls to selected characters
--- Provides interface for selecting characters and specifying number of rolls to grant
--- @class DTGrantRollsDialog
DTGrantRollsDialog = RegisterGameType("DTGrantRollsDialog")
DTGrantRollsDialog.__index = DTGrantRollsDialog

--- Creates a new Grant Rolls Dialog instance
--- @return DTGrantRollsDialog instance The new dialog instance
function DTGrantRollsDialog:new()
    local instance = setmetatable({}, self)
    return instance
end

--- Shows the grant rolls dialog modal
function DTGrantRollsDialog:ShowDialog()
    local dialog = self

    local grantRollsDialog = gui.Panel{
        classes = {"dtGrantRollsController", "DTDialog"},
        width = 520,
        height = 450,
        styles = DTUIUtils.GetDialogStyles(),

        create = function(element)
            element:FireEvent("validateForm")
        end,

        validateForm = function(element)
            local isValid = false
            local tokenPool = element:Get("tokenPool")
            local txtNumRolls = element:Get("txtNumRolls")
            local numRolls = 0
            if tokenPool and tokenPool.data and tokenPool.data.selectedTokens and txtNumRolls then
                numRolls = tonum(txtNumRolls.text, 0)
                isValid = #tokenPool.data.selectedTokens > 0 and numRolls ~= 0
            end
            element:FireEventTree("enableConfirm", isValid, numRolls >= 0 and "Grant" or "Revoke")
        end,

        saveAndClose = function(element)
            local txtNumRolls = element:Get("txtNumRolls")
            if txtNumRolls then
                local numRolls = tonum(txtNumRolls.text, 0)
                if numRolls ~= 0 then
                    local tokenPool = element:Get("tokenPool")
                    if tokenPool and tokenPool.data and tokenPool.data.selectedTokens and #tokenPool.data.selectedTokens then
                        for _, tokenId in ipairs(tokenPool.data.selectedTokens) do
                            local token = dmhub.GetCharacterById(tokenId)
                            if token and token.properties then
                                token:ModifyProperties{
                                    description = "Grant Downtime Rolls",
                                    execute = function ()
                                        local downtimeInfo = token.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
                                        if type(downtimeInfo) ~= "table" then downtimeInfo = DTDowntimeInfo:new() end
                                        downtimeInfo:GrantRolls(numRolls)
                                    end,
                                }
                            end
                        end
                        DTSettings.Touch()
                        gui.CloseModal()
                    end
                end
            end
        end,

        children = {
            gui.Panel {
                classes = {"DTPanel", "DTBase"},
                height = "100%",
                width = "98%",
                valign = "top",
                halign = "center",
                flow = "vertical",
                borderColor = "red",
                children = {
                    -- Header
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        valign = "top",
                        height = 40,
                        width = "98%",
                        borderColor = "blue",
                        children = {
                            gui.Label{
                                text = "Grant Downtime Rolls",
                                width = "100%",
                                height = 30,
                                fontSize = "24",
                                classes = {"DTLabel", "DTBase"},
                                textAlignment = "center",
                                halign = "center"
                            },
                        }
                    },

                    -- Content
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        height = "100%-124",
                        width = "98%",
                        valign="top",
                        flow = "vertical",
                        borderColor = "blue",
                        children = {
                            gui.Panel {
                                classes = {"DTPanelRow", "DTPanel", "DTBase"},
                                height = "auto",
                                borderColor = "yellow",
                                children = {dialog:_buildNumberOfRollsField()}
                            },
                            gui.Panel {
                                classes = {"DTPanelRow", "DTPanel", "DTBase"},
                                height = "auto",
                                borderColor = "yellow",
                                children = {dialog:_createCharacterSelector()}
                            }
                        }
                    },

                    -- Footer
                    gui.Panel{
                        classes = {"DTPanel", "DTBase"},
                        width = "98%",
                        height = 60,
                        halign = "center",
                        valign = "bottom",
                        flow = "horizontal",
                        borderColor = "blue",
                        children = {
                            -- Cancel button
                            gui.Button{
                                text = "Cancel",
                                width = 120,
                                valign = "bottom",
                                classes = {"DTButton", "DTBase"},
                                click = function(element)
                                    gui.CloseModal()
                                end
                            },
                            -- Confirm button
                            gui.Button{
                                text = "Confirm",
                                width = 120,
                                valign = "bottom",
                                classes = {"DTButton", "DTBase", "DTDisabled"},
                                interactable = false,
                                enableConfirm = function(element, enabled, label)
                                    if label and #label then
                                        element.text = label
                                        element:SetClass("DTDanger", string.lower(label) == "revoke")
                                    end
                                    element:SetClass("DTDisabled", not enabled)
                                    element.interactable = enabled
                                end,
                                click = function(element)
                                    if not element.interactable then return end
                                    local controller = element:FindParentWithClass("dtGrantRollsController")
                                    if controller then
                                        controller:FireEvent("saveAndClose")
                                    end
                                end
                            }
                        }
                    }
                }
            }
        },

        escape = function(element)
            gui.CloseModal()
        end
    }

    dialog.dialogElement = grantRollsDialog
    gui.ShowModal(grantRollsDialog)
end

--- Builds the number of rolls input field with +/- buttons
--- @return table panel The number of rolls input panel
function DTGrantRollsDialog:_buildNumberOfRollsField()

    return gui.Panel{
        classes = {"dtNumRollsController", "DTPanel", "DTBase"},
        width = "50%",
        height = "auto",
        halign = "left",
        flow = "vertical",

        children = {
            gui.Label{
                text = "Number of Rolls",
                classes = {"DTLabel", "DTBase"},
                width = "100%",
            },
            gui.Panel{
                width = "100%",
                height = "auto",
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    -- Decrement
                    gui.Button{
                        text = "-",
                        width = 35,
                        height = 35,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            local controller = element:FindParentWithClass("dtNumRollsController")
                            if controller then
                                controller:FireEventTree("adjustNumRolls", -1)
                            end
                        end
                    },
                    -- Display
                    gui.Label {
                        id = "txtNumRolls",
                        text = "1",
                        width = 80,
                        height = 35,
                        hmargin = 5,
                        cornerRadius = 4,
                        bgimage = "panels/square.png",
                        border = 1,
                        textAlignment = "center",
                        classes = {"DTInput", "DTBase"},
                        adjustNumRolls = function(element, n)
                            if n and n ~= 0 then
                                local controller = element:FindParentWithClass("dtGrantRollsController")
                                if controller then
                                    local n1 = tonum(element.text, 1)
                                    element.text = tostring(n1 + n)
                                    controller:FireEvent("validateForm")
                                end
                            end
                        end,
                    },
                    -- Increment
                    gui.Button{
                        text = "+",
                        width = 35,
                        height = 35,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            local controller = element:FindParentWithClass("dtNumRollsController")
                            if controller then
                                controller:FireEventTree("adjustNumRolls", 1)
                            end
                        end
                    }
                }
            }
        }
    }
end

--- Creates the character selector with token grid and All/Party/None controls
--- @return table panel The character selector panel
function DTGrantRollsDialog:_createCharacterSelector()
    local tokenPanels = {}

    -- Get available tokens
    -- TODO: Get all characters; not just tokens on the map
    local candidateTokens = dmhub.GetTokens{ playerControlled = true, haveProperties = true }
    local selectedTokens = dmhub.selectedTokens

    -- Add selected tokens to candidates if not already present
    for _, tok in ipairs(selectedTokens) do
        local found = false
        for _, existing in ipairs(candidateTokens) do
            if existing == tok then
                found = true
                break
            end
        end
        if not found then
            candidateTokens[#candidateTokens + 1] = tok
        end
    end

    -- Track initially selected tokens for auto-selection
    local startingSelection = {}

    -- Create token panels
    for i, token in ipairs(candidateTokens) do
        local isSelected = false
        -- Check if this token was selected on the map
        for _, selectedTok in ipairs(selectedTokens) do
            if selectedTok == token then
                startingSelection[#startingSelection + 1] = tokenPanels[#tokenPanels]
                isSelected = true
                break
            end
        end
        tokenPanels[#tokenPanels + 1] = gui.Panel{
            bgimage = "panels/square.png",
            classes = {"token-panel", isSelected and "selected" or nil},
            data = {
                token = token,
            },
            children = {
                gui.CreateTokenImage(token)
            },
            linger = function(element)
                gui.Tooltip(token.description)(element)
            end,
            press = function(element)
                element:SetClass("selected", not element:HasClass("selected"))
                local controller = element:FindParentWithClass("tokenPool")
                if controller then controller:FireEvent("updateSelected") end
            end,
        }
    end

    -- Token grid container
    local tokenPool = gui.Panel {
        id = "tokenPool",
        classes = {"tokenPool"},
        bgimage = 'panels/square.png',
        bgcolor = 'black',
        cornerRadius = 8,
        border = 2,
        borderColor = '#888888',
        width = "96%",
        height = 130,
        pad = 4,
        vscroll = true,
        vmargin = 8,
        flow = 'horizontal',
        wrap = true,
        styles = {
            {
                classes = {'token-panel'},
                bgcolor = 'black',
                cornerRadius = 8,
                width = 64,
                height = 64,
                halign = 'left',
            },
            {
                classes = {'token-panel', 'hover'},
                borderColor = 'grey',
                borderWidth = 2,
                bgcolor = '#441111',
            },
            {
                classes = {'token-panel', 'selected'},
                borderColor = 'white',
                borderWidth = 2,
                bgcolor = '#882222',
            },
        },
        data = {
            selectedTokens = {}
        },
        create = function(element)
            element:FireEvent("updateSelected")
        end,
        updateSelected = function(element)
            element.data.selectedTokens = {}
            for _, panel in ipairs(element.children) do
                if panel:HasClass('selected') then
                    element.data.selectedTokens[#element.data.selectedTokens + 1] = panel.data.token.id
                end
            end
            local controller = element:FindParentWithClass("dtGrantRollsController")
            if controller then controller:FireEvent("validateForm") end
        end,
        children = tokenPanels
    }

    -- Selection shortcuts menu
    local tokenPoolSelection = gui.Panel{
        flow = 'horizontal',
        halign = 'center',
        width = 'auto',
        height = 'auto',
        styles = {
            {
                classes = {'token-pool-shortcut'},
                color = '#aaaaaa',
                fontSize = 16,
                width = 'auto',
                height = 'auto',
                valign = 'center',
                halign = 'center',
            },
            {
                classes = {'token-pool-shortcut', 'hover'},
                color = 'white',
            },
            {
                classes = {'shortcut-divider'},
                bgimage = 'panels/square.png',
                halign = 'center',
                valign = 'center',
                margin = 4,
                width = 2,
                height = 16,
                bgcolor = '#aaaaaa',
            },
        },
        children = {
            -- All button
            gui.Label{
                classes = {'token-pool-shortcut'},
                text = 'All',
                click = function(element)
                    for i, tokenPanel in ipairs(tokenPanels) do
                        tokenPanel:SetClass('selected', true)
                    end
                    local controller = element:FindParentWithClass("tokenPool")
                    if controller then controller:FireEvent("updateSelected") end
                end,
            },
            gui.Panel{
                classes = {'shortcut-divider'},
            },
            -- Party button (heroes only)
            gui.Label{
                classes = {'token-pool-shortcut'},
                text = 'Party',
                click = function(element)
                    for i, tokenPanel in ipairs(tokenPanels) do
                        local isHero = tokenPanel.data.token.properties and tokenPanel.data.token.properties:IsHero()
                        tokenPanel:SetClass('selected', isHero == true)
                    end
                    local controller = element:FindParentWithClass("tokenPool")
                    if controller then controller:FireEvent("updateSelected") end
                end,
            },
            gui.Panel{
                classes = {'shortcut-divider'},
            },
            -- None button
            gui.Label{
                classes = {'token-pool-shortcut'},
                text = 'None',
                click = function(element)
                    for i, tokenPanel in ipairs(tokenPanels) do
                        tokenPanel:SetClass('selected', false)
                    end
                    local controller = element:FindParentWithClass("tokenPool")
                    if controller then controller:FireEvent("updateSelected") end
                end,
            },
        }
    }

    return gui.Panel{
        width = "100%",
        height = "auto",
        flow = "vertical",
        vmargin = 10,
        children = {
            gui.Label{
                text = "Select Characters:",
                classes = {"DTLabel", "DTBase"},
                width = "100%",
            },
            gui.Panel{
                width = "100%",
                height = "auto",
                flow = "vertical",
                halign = "center",
                children = {
                    tokenPool,
                    tokenPoolSelection
                }
            }
        }
    }
end