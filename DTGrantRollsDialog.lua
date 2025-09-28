--- Grant Rolls Dialog - Dialog for granting downtime rolls to selected characters
--- Provides interface for selecting characters and specifying number of rolls to grant
--- @class DTGrantRollsDialog
--- @field selectedTokens table Array of selected token IDs from the character selector
--- @field numberOfRolls number Current number of rolls to grant (default: 1, must be > 0)
--- @field dialogElement table Reference to the main dialog GUI panel element
--- @field confirmButton table Reference to the confirm button for enabling/disabling
--- @field rollsInput table Reference to the number input field for +/- button access
DTGrantRollsDialog = RegisterGameType("DTGrantRollsDialog")
DTGrantRollsDialog.__index = DTGrantRollsDialog

--- Creates a new Grant Rolls Dialog instance
--- @return DTGrantRollsDialog instance The new dialog instance
function DTGrantRollsDialog:new()
    local instance = setmetatable({}, self)

    -- State tracking
    instance.selectedTokens = {}
    instance.numberOfRolls = 1
    instance.dialogElement = nil
    instance.confirmButton = nil
    instance.rollsInput = nil

    return instance
end

--- Shows the grant rolls dialog modal
function DTGrantRollsDialog:ShowDialog()
    local dialog = self

    -- Build styles array with invalid button styling
    local dialogStyles = DTUIUtils.GetDialogStyles()
    dialogStyles[#dialogStyles + 1] = gui.Style{
        selectors = {'DTButton', 'DTBase', 'invalid'},
        bgcolor = '#222222',
        borderColor = '#444444',
        -- borderWidth = 2
    }

    local grantRollsDialog = gui.Panel{
        width = 520,
        height = 450,
        halign = "center",
        valign = "center",
        bgcolor = "#111111ff",
        borderWidth = 2,
        borderColor = Styles.textColor,
        bgimage = "panels/square.png",
        flow = "vertical",
        hpad = 20,
        vpad = 20,
        styles = dialogStyles,

        children = {
            -- Title
            gui.Label{
                text = "Grant Downtime Rolls to Characters",
                width = "100%",
                height = 30,
                fontSize = 24,
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                halign = "center"
            },

            -- Number of rolls field
            dialog:_buildNumberOfRollsField(),

            -- Character selector
            dialog:_createCharacterSelector(),

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
                    -- Confirm button (stored for enabling/disabling)
                    gui.Button{
                        text = "Grant Rolls",
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
    local dialog = self

    return gui.Panel{
        width = "50%",
        height = 60,
        vmargin = 10,
        halign = "left",
        flow = "vertical",
        children = {
            gui.Label{
                text = "Number of Rolls",
                classes = {"DTLabel", "DTBase"},
                width = "100%",
                height = 20,
                vmargin = 10,
            },
            gui.Panel{
                width = "100%",
                height = 35,
                flow = "horizontal",
                halign = "left",
                valign = "center",
                children = {
                    -- Minus button
                    gui.Button{
                        text = "-",
                        width = 35,
                        height = 35,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            local currentValue = tonumber(dialog.rollsInput.text) or 1
                            if currentValue > 1 then
                                dialog.rollsInput.text = tostring(currentValue - 1)
                                dialog.numberOfRolls = currentValue - 1
                                dialog:_validateForm()
                            end
                        end
                    },
                    -- Number input
                    gui.Input{
                        text = "1",
                        width = 80,
                        height = 35,
                        hmargin = 5,
                        textAlignment = "center",
                        classes = {"DTInput", "DTBase"},
                        lineType = "Single",
                        editlag = 0.25,
                        create = function(element)
                            dialog.rollsInput = element
                        end,
                        edit = function(element)
                            local value = tonumber(element.text) or 0
                            dialog.numberOfRolls = math.max(0, math.floor(value))
                            dialog:_validateForm()
                        end
                    },
                    -- Plus button
                    gui.Button{
                        text = "+",
                        width = 35,
                        height = 35,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            local currentValue = tonumber(dialog.rollsInput.text) or 1
                            dialog.rollsInput.text = tostring(currentValue + 1)
                            dialog.numberOfRolls = currentValue + 1
                            dialog:_validateForm()
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
    local dialog = self
    local tokenPanels = {}

    -- Get available tokens
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

    -- Function to get currently selected token IDs
    local function GetSelectedTokenIds()
        local result = {}
        for i, panel in ipairs(tokenPanels) do
            if panel:HasClass('selected') then
                result[#result + 1] = panel.data.token.id
            end
        end
        return result
    end

    -- Function to track selection without validation (for auto-selection during init)
    local function TrackSelection()
        dialog.selectedTokens = GetSelectedTokenIds()
    end

    -- Function to update selection state with validation (for user interactions)
    local function UpdateSelection()
        dialog.selectedTokens = GetSelectedTokenIds()
        dialog:_validateForm()
    end

    -- Track initially selected tokens for auto-selection
    local startingSelection = {}

    -- Create token panels
    for i, token in ipairs(candidateTokens) do
        tokenPanels[#tokenPanels + 1] = gui.Panel{
            bgimage = 'panels/square.png',
            classes = {'token-panel'},
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
                element:SetClass('selected', not element:HasClass('selected'))
                UpdateSelection()
            end,
        }

        -- Check if this token was selected on the map
        for _, selectedTok in ipairs(selectedTokens) do
            if selectedTok == token then
                startingSelection[#startingSelection + 1] = tokenPanels[#tokenPanels]
                break
            end
        end
    end

    -- Token grid container
    local tokenPool = gui.Panel{
        bgimage = 'panels/square.png',
        bgcolor = 'black',
        cornerRadius = 8,
        border = 2,
        borderColor = '#888888',
        width = "96%",
        height = 210,
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
                create = function(element)
                    -- Auto-select map-selected tokens when dialog opens
                    element:FireEvent("selectStarting")
                end,
                click = function(element)
                    for i, tokenPanel in ipairs(tokenPanels) do
                        tokenPanel:SetClass('selected', true)
                    end
                    UpdateSelection()
                end,
                selectStarting = function(element)
                    for i, tokenPanel in ipairs(startingSelection) do
                        tokenPanel:SetClass('selected', true)
                    end
                    TrackSelection() -- Don't validate during initialization
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
                    UpdateSelection()
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
                    UpdateSelection()
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
                text = "Select Characters",
                classes = {"DTLabel", "DTBase"},
                width = "100%",
                height = 20
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

--- Checks if the form is in a valid state for submission
--- @return boolean isValid True if form can be submitted
function DTGrantRollsDialog:_isFormValid()
    local hasSelectedCharacters = #self.selectedTokens > 0
    local hasValidRolls = self.numberOfRolls > 0
    return hasSelectedCharacters and hasValidRolls
end

--- Validates the form and enables/disables the Confirm button
function DTGrantRollsDialog:_validateForm()
    if self.confirmButton ~= nil then
        local isValid = self:_isFormValid()
        self.confirmButton:SetClass("invalid", not isValid)
        self.confirmButton.interactable = isValid
        -- Future: self.confirmButton.disabled = not isValid (when supported)
    end
end

--- Handles the confirm button click - grants rolls to selected characters
function DTGrantRollsDialog:_onConfirm()
    if not self:_isFormValid() then return end

    for _, tokenId in ipairs(self.selectedTokens) do
        local token = dmhub.GetCharacterById(tokenId)
        if token and token.properties then

            token:ModifyProperties{
                description = "Grant Downtime Rolls",
                execute = function ()
                    local downtimeInfo = token.properties:get_or_add("downtime_info", DTDowntimeInfo:new())
                    if type(downtimeInfo) ~= "table" then downtimeInfo = DTDowntimeInfo:new() end
                    downtimeInfo:AddAvailableRolls(self.numberOfRolls)
                end,
            }
        end
    end

    gui.CloseModal()
end