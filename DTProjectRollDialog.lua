--- Project roll dialog for making downtime project rolls
--- @class DTProjectRollDialog
DTProjectRollDialog = RegisterGameType("DTProjectRollDialog")
DTProjectRollDialog.__index = DTProjectRollDialog

--- Creates a project roll dialog for AddChild usage
--- @param roll DTRoll|DTProgressItem The roll instance to edit
--- @param options table Table with data, options, and callback functions
--- @return table|nil panel The GUI panel ready for AddChild
function DTProjectRollDialog.CreateAsChild(roll, options)
    if not options then return end
    if not options.callbacks then options.callbacks = {} end

    options.callbacks.confirmHandler = function(element)
        if options.callbacks and options.callbacks.confirm then
            options.callbacks.callbacks.confirm()
        end
    end

    options.callbacks.cancelHandler = function(element)
        if options.callbacks and options.callbacks.cancel then
            options.callbacks.cancel()
        end
    end

    return DTProjectRollDialog._createPanel(roll, options)
end

--- Private helper to create the roll dialog panel structure
--- @param roll DTRoll|DTProgressItem The roll instance to edit
--- @param options table Table with data, options, and callback functions
--- @return table panel The GUI panel structure
function DTProjectRollDialog._createPanel(roll, options)
    local resultPanel = nil
    resultPanel = gui.Panel {
        classes = {"rollController", "DTDialog"},
        width = 800,
        height = 600,
        styles = DTUtils.GetDialogStyles(),
        floating = true,
        escapePriority = EscapePriority.EXIT_MODAL_DIALOG,
        captureEscape = true,
        data = {
            edges = 0,
            edgeList = {},
            banes = 0,
            baneList = {},
            bonuses = 0,
            roll = roll,
            project = options.data.project,
            close = function()
                resultPanel:DestroySelf()
            end,
            getProject = function(element)
                return element.data.project
            end,
            getEdgeAndBaneLists = function(element)
                return element.data.edgeList, element.data.baneList
            end,
        },

        create = function(element)
            element:FireEvent("updateForm")
        end,

        addBane = function(element, item)
            if item and type(item) == "table" then
                element.data.baneList[item.id] = item
                element:FireEvent("updateForm")
            end
        end,

        removeBane = function(element, itemId)
            if itemId and type(itemId) == "string" and #itemId > 0 then
                if element.data.baneList[itemId] then
                    element.data.baneList [itemId] = nil
                    element:FireEvent("updateForm")
                end
            end
        end,

        addEdge = function(element, item)
            if item and type(item) == "table" then
                element.data.edgeList[item.id] = item
                element:FireEvent("updateForm")
            end
        end,

        removeEdge = function(element, itemId)
            if itemId and type(itemId) == "string" and #itemId > 0 then
                if element.data.edgeList[itemId] then
                    element.data.edgeList [itemId] = nil
                    element:FireEvent("updateForm")
                end
            end
        end,

        updateForm = function(element)
            element.data.banes = 0
            for _, item in pairs(element.data.baneList) do
                element.data.banes = element.data.banes + (item.value or 0)
            end
            element.data.edges = 0
            for _, item in pairs(element.data.edgeList) do
                element.data.edges = element.data.edges + (item.value or 0)
            end
            element:FireEventTree("updateFields")
        end,

        close = function(element)
            element.data.close()
        end,

        escape = function(element)
            options.callbacks.cancelHandler(element)
            element:FireEvent("close")
        end,

        children = {
            -- Header
            gui.Label{
                classes = {"DTLabel", "DTBase"},
                text = "Make A Project Roll",
                fontSize = 24,
                width = "100%",
                height = 30,
                textAlignment = "center",
            },
            gui.Divider { width = "50%" },

            -- Form content
            gui.Panel{
                classes = {"DTPanel", "DTBase"},
                width = "100%",
                height = "100%-110",
                flow = "vertical",
                vmargin = 10,
                borderColor = "red",
                children = {
                    -- Top row
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "100%-10",
                        height = "75%-7",
                        valign = "top",
                        flow = "horizontal",
                        borderColor = "blue",
                        children = {
                            -- Left Side - Edges
                            gui.Panel {
                                classes = {"edgesController", "DTPanel", "DTBase"},
                                width = "33%-5",
                                height = "100%-10",
                                valign = "top",
                                flow = "vertical",
                                borderColor = "yellow",
                                children = {
                                    gui.Label {
                                        classes = {"DTLabel", "DTBase"},
                                        text = "Edges",
                                        width = "100%",
                                        textAlignment = "center",
                                        valign = "top",
                                        updateFields = function(element)
                                            local controller = element:FindParentWithClass("rollController")
                                            if controller then
                                                local edges = controller.data.edges or 0
                                                element.text = string.format("Edges x%d", edges)
                                            end
                                        end,
                                    },
                                    gui.Divider { width = "50%" },
                                    gui.Panel {
                                        classes = {"DTPanel", "DTBase"},
                                        width = "100%-8",
                                        height = "auto",
                                        flow = "vertical",
                                        borderColor = "cyan",
                                        children = {
                                            DTProjectRollDialog._makeExtraAdjustmentCheckText("edge"),
                                            DTProjectRollDialog._makeExtraAdjustmentCheckText("edge"),
                                        }
                                    }
                                }
                            },
                            -- Center - Banes
                            gui.Panel {
                                classes = {"banesController", "DTPanel", "DTBase"},
                                width = "33%-5",
                                height = "100%-10",
                                valign = "top",
                                flow = "vertical",
                                borderColor = "yellow",
                                children = {
                                    gui.Label {
                                        classes = {"DTLabel", "DTBase"},
                                        text = "Banes",
                                        width = "100%",
                                        textAlignment = "center",
                                        valign = "top",
                                        updateFields = function(element)
                                            local controller = element:FindParentWithClass("rollController")
                                            if controller then
                                                local banes = controller.data.banes or 0
                                                element.text = string.format("Banes x%d", banes)
                                            end
                                        end,
                                    },
                                    gui.Divider { width = "50%" },
                                    gui.Panel {
                                        classes = {"DTPanel", "DTBase"},
                                        width = "100%-8",
                                        height = "auto",
                                        flow = "vertical",
                                        vpad = 7,
                                        borderColor = "cyan",
                                        children = {
                                            gui.Check {
                                                classes = {"DTCheck", "DTBase"},
                                                value = false,
                                                text = "Language Penalty",
                                                data = {
                                                    banes = 0,
                                                },
                                                create = function(element)
                                                    local rollController = element:FindParentWithClass("rollController")
                                                    if rollController then
                                                        local project = rollController.data.getProject(rollController)
                                                        if project then
                                                            local langPenalty = project:GetProjectSourceLanguagePenalty()
                                                            if langPenalty then
                                                                if langPenalty == DTConstants.LANGUAGE_PENALTY.RELATED.key then
                                                                    element.data.banes = 1
                                                                    element.value = true
                                                                elseif langPenalty == DTConstants.LANGUAGE_PENALTY.UNKNOWN.key then
                                                                    element.data.banes = 2
                                                                    element.value = true
                                                                end
                                                                element.data.SetText(string.format("Language Penalty (%s x%d)", DTConstants.GetDisplayText(DTConstants.LANGUAGE_PENALTY, langPenalty), element.data.banes))
                                                            end
                                                        end
                                                    end
                                                    element.interactable = (element.data.banes ~= 0)
                                                end,
                                                change = function(element)
                                                    if element.data.banes == 0 then
                                                        if element.value ~= false then element.value = false end
                                                        return
                                                    end
                                                    local rollController = element:FindParentWithClass("rollController")
                                                    if rollController then
                                                        if element.value then
                                                            local baneItem = {
                                                                id = element.id,
                                                                value = element.data.banes,
                                                                description = element.data.GetText(),
                                                            }
                                                            rollController:FireEvent("addBane", baneItem)
                                                        else
                                                            rollController:FireEvent("removeBane", element.id)
                                                        end
                                                    end
                                                end,
                                            },
                                            DTProjectRollDialog._makeExtraAdjustmentCheckText("bane"),
                                            DTProjectRollDialog._makeExtraAdjustmentCheckText("bane"),
                                            -- gui.Panel {
                                            --     classes = {"extraBaneController"},
                                            --     width = "98%",
                                            --     height = "auto",
                                            --     flow = "vertical",
                                            --     pad = 0,
                                            --     margin = 0,
                                            --     data = {
                                            --         isChecked = false,
                                            --         banes = 1,
                                            --         description = "",
                                            --     },
                                            --     updateChecked = function(element, isChecked)
                                            --         element.data.isChecked = isChecked
                                            --         element:FireEvent("updateRollController")
                                            --     end,
                                            --     updateDescription = function(element, description)
                                            --         local s1 = description or ""
                                            --         if element.data.description ~= s1 then
                                            --             element.data.description = s1
                                            --         end
                                            --     end,
                                            --     updateFields = function(element)
                                            --         element:FireEventTree("updateField", element)
                                            --     end,
                                            --     updateRollController = function(element)
                                            --         local rollController = element:FindParentWithClass("rollController")
                                            --         if rollController then
                                            --             if not element.data.isChecked then
                                            --                 rollController:FireEvent("removeBane", element.id)
                                            --             else
                                            --                 local baneItem = {
                                            --                     id = element.id,
                                            --                     value = element.data.banes,
                                            --                     description = element.data.description
                                            --                 }
                                            --                 rollController:FireEvent("addBane", baneItem)
                                            --             end
                                            --         end
                                            --     end,
                                            --     children = {
                                            --         gui.Check {
                                            --             classes = {"DTCheck", "DTBase"},
                                            --             width = "100%",
                                            --             halign = "left",
                                            --             value = false,
                                            --             text = "Additional Bane (x1)",
                                            --             placement = "left",
                                            --             data = {
                                            --                 banes = 1,
                                            --             },
                                            --             change = function(element)
                                            --                 local fieldController = element:FindParentWithClass("extraBaneController")
                                            --                 if fieldController then
                                            --                     fieldController:FireEvent("updateChecked", element.value)
                                            --                 end
                                            --             end,
                                            --         },
                                            --         gui.Input {
                                            --             classes = {"DTInput", "DTBase", "collapsed"},
                                            --             width = "80%",
                                            --             halign="right",
                                            --             placeholderText = "Enter description...",
                                            --             interactable = false,
                                            --             style = {
                                            --                 selectors = {"collapsed"},
                                            --                 height = 0,
                                            --                 hidden = 1
                                            --             },
                                            --             editlag = 0.5,
                                            --             change = function(element)
                                            --                 local fieldController = element:FindParentWithClass("extraBaneController")
                                            --                 if fieldController then
                                            --                     fieldController:FireEvent("updateDescription", element.text)
                                            --                 end
                                            --             end,
                                            --             edit = function(element)
                                            --                 element:FireEvent("change")
                                            --             end,
                                            --             updateField = function(element, controller)
                                            --                 if controller then
                                            --                     element.interactable = controller.data.isChecked
                                            --                     element:SetClass("collapsed", not element.interactable)
                                            --                 end
                                            --             end
                                            --         },
                                            --     }
                                            -- }
                                        }
                                    }
                                }
                            },
                            -- Right - Bonuses
                            gui.Panel {
                                classes = {"bonusesController", "DTPanel", "DTBase"},
                                width = "33%-5",
                                height = "100%-10",
                                valign = "top",
                                flow = "vertical",
                                borderColor = "yellow",
                                data = {
                                    getBonuses = function(element)
                                        local controller = element:FindParentWithClass("rollController")
                                        if controller then
                                            return controller.data.bonuses
                                        end
                                        return 0
                                    end,
                                },
                                children = {
                                    gui.Label {
                                        classes = {"DTLabel", "DTBase"},
                                        text = "Bonuses",
                                        width = "100%",
                                        textAlignment = "center",
                                        valign = "top",
                                        updateFields = function(element)
                                            local bonusesController = element:FindParentWithClass("bonusesController")
                                            local bonuses = bonusesController and bonusesController.data.getBonuses(element) or 0
                                            element.text = string.format("Bonuses: %+d", bonuses)
                                        end,
                                    },
                                    gui.Divider { width = "50%" },
                                    gui.Panel {
                                        classes = {"DTPanel", "DTBase"},
                                        width = "100%-8",
                                        height = "auto",
                                        borderColor = "cyan",
                                        children = {}
                                    }
                                }
                            },
                        }
                    },
                    -- Bottom row
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "100%-10",
                        height = "25%-7",
                        valign = "top",
                        flow = "horizontal",
                        borderColor = "blue",
                        children = {}
                    }
                }
            },

            -- Button panel
            gui.Panel{
                classes = {"DTPanel", "DTBase"},
                width = "100%",
                height = 40,
                vmargin = 10,
                halign = "center",
                valign = "bottom",
                flow = "horizontal",
                borderColor = "red",
                children = {
                    gui.Button{
                        classes = {"DTButton", "DTBase"},
                        text = "Cancel",
                        width = 120,
                        halign = "center",
                        click = function(element)
                            local controller = element:FindParentWithClass("rollController")
                            if controller then
                                controller:FireEvent("escape")
                            end
                        end
                    },
                    gui.Button{
                        classes = {"DTButton", "DTBase"},
                        text = "Roll",
                        width = 120,
                        halign = "center",
                        click = function(element)
                            local controller = element:FindParentWithClass("rollController")
                            if controller then
                                print("THC:: ROLLING::")
                                local rollGuid = dmhub.GenerateGuid()
                                local result = dmhub.Roll {
                                    guid = rollGuid,
                                    -- numDice = 2,
                                    -- numFaces = 10,
                                    roll = "2d10+4",
                                    numKeep = 2,
                                    description = "Testing a roll",
                                    tokenid = CharacterSheet.instance.data.info.token,
                                    -- silent = false,
                                    -- instant = false,
                                    complete = function(rollInfoArg)
                                        print("THC:: ROLLED1::", rollInfoArg)
                                        local rollResult = {
                                            banes = rollInfoArg.banes,
                                            edges = rollInfoArg.boons,
                                            description = rollInfoArg.description,
                                            formattedText = rollInfoArg.formattedText,
                                            naturalRoll = rollInfoArg.naturalRoll,
                                            nick = rollInfoArg.nick,
                                            nickColor = rollInfoArg.nickColor,
                                            playerColor = rollInfoArg.playerColor,
                                            playerName = rollInfoArg.playerName,
                                            result = rollInfoArg.result,
                                            resultInfo = rollInfoArg.resultInfo,
                                            rollStr = rollInfoArg.rollstr,
                                            rolls = rollInfoArg.rolls,
                                            total = rollInfoArg.total,
                                        }
                                        print("THC:: RESULT::", json(rollResult))
                                    end,
                                }
                                print("THC:: ROLLED2::", result)
                                -- confirmHandler(element)
                                -- controller:FireEvent("close")
                            end
                        end
                    }
                }
            }
        },
    }

    return resultPanel
end

--- Create a field with a checkbox on top and hidden text on bottom
--- such that when checked, it shows the field
--- @param adjustType string Bane or Edge, either case is fine
--- @return Panel panel The panel containing the control
function DTProjectRollDialog._makeExtraAdjustmentCheckText(adjustType)
    local proper = adjustType:sub(1, 1):upper() .. adjustType:sub(2):lower()
    local removeEvent = "remove" .. proper
    local addEvent = "add" .. proper

    return gui.Panel {
        classes = {"extraBaneEdgeController"},
        width = "98%",
        height = "auto",
        flow = "vertical",
        pad = 0,
        margin = 0,
        data = {
            isChecked = false,
            value = 1,
            description = "",
        },
        updateChecked = function(element, isChecked)
            element.data.isChecked = isChecked
            element:FireEvent("updateRollController")
        end,
        updateDescription = function(element, description)
            local s1 = description or ""
            if element.data.description ~= s1 then
                element.data.description = s1
            end
        end,
        updateFields = function(element)
            element:FireEventTree("updateField", element)
        end,
        updateRollController = function(element)
            local rollController = element:FindParentWithClass("rollController")
            if rollController then
                if not element.data.isChecked then
                    rollController:FireEvent(removeEvent, element.id)
                else
                    local item = {
                        id = element.id,
                        value = element.data.value,
                        description = element.data.description
                    }
                    rollController:FireEvent(addEvent, item)
                end
            end
        end,
        children = {
            gui.Check {
                classes = {"DTCheck", "DTBase"},
                width = "100%",
                halign = "left",
                value = false,
                text = string.format("Additional %s (x1)", proper),
                placement = "left",
                change = function(element)
                    local fieldController = element:FindParentWithClass("extraBaneEdgeController")
                    if fieldController then
                        fieldController:FireEvent("updateChecked", element.value)
                    end
                end,
            },
                gui.Input {
                    classes = {"DTInput", "DTBase", "collapsed"},
                    width = "80%",
                    halign="right",
                    placeholderText = "Enter description...",
                    interactable = false,
                    style = {
                        selectors = {"collapsed"},
                        height = 0,
                        hidden = 1
                    },
                    editlag = 0.5,
                    change = function(element)
                        local fieldController = element:FindParentWithClass("extraBaneEdgeController")
                        if fieldController then
                            fieldController:FireEvent("updateDescription", element.text)
                        end
                    end,
                    edit = function(element)
                        element:FireEvent("change")
                    end,
                    updateField = function(element, controller)
                        if controller then
                            element.interactable = controller.data.isChecked
                            element:SetClass("collapsed", not element.interactable)
                        end
                    end
                },
            }
        }
end
