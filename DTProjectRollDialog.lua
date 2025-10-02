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

    options.callbacks.confirmHandler = function(roll)
        if options.callbacks and options.callbacks.confirm then
            options.callbacks.confirm(roll)
        end
    end

    options.callbacks.cancelHandler = function()
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

    local character = CharacterSheet.instance.data.info.token.properties
    local skillList = {}
    for _, skill in ipairs(Skill.SkillsInfo) do
        if character:ProficientInSkill(skill) then
            skillList[#skillList + 1] = { id = skill.name, text = skill.name}
        end
    end

    resultPanel = gui.Panel {
        classes = {"rollController", "DTDialog"},
        width = 800,
        height = 500,
        styles = DTUtils.GetDialogStyles(),
        floating = true,
        escapePriority = EscapePriority.EXIT_MODAL_DIALOG,
        captureEscape = true,
        data = {
            edges = 0,
            banes = 0,
            bonuses = 0,
            itemLists = {
                edges = {},
                banes = {},
                bonuses = {},
            },
            roll = roll,
            project = options.data.project,

            isRolling = false,
            close = function(element, force)
                if force or not element.data.isRolling then
                    resultPanel:DestroySelf()
                end
            end,
            getProject = function(element)
                return element.data.project
            end,
            getItemList = function(element, listName)
                return element.data.itemLists[listName]
            end,
            calculateRoll = function(element)
                local banes = math.min(2, element.data.banes) * -1
                local edges = math.min(2, element.data.edges)
                local edgeVsBane = edges + banes

                local seen, bonuses = {}, 0
                for _, item in pairs(element.data.itemLists.bonuses) do
                    if not seen[item.description] then
                        seen[item.description] = true
                        bonuses = bonuses + item.value
                    end
                end

                local totalBonus = (edgeVsBane * 2) + bonuses
                local rollString = string.format("2d10%+d", totalBonus)

                return rollString
            end,
        },

        create = function(element)
            element:FireEvent("updateForm")
        end,

        addItem = function(element, listName, item)
            element.data.itemLists[listName][item.id] = item
            element:FireEvent("updateForm")
        end,

        removeItem = function(element, listName, itemId)
            if element.data.itemLists[listName][itemId] then
                element.data.itemLists[listName][itemId] = nil
                element:FireEvent("updateForm")
            end
        end,

        updateForm = function(element)
            element.data.banes = 0
            for _, item in pairs(element.data.itemLists.banes) do
                element.data.banes = element.data.banes + (item.value or 0)
            end
            element.data.edges = 0
            for _, item in pairs(element.data.itemLists.edges) do
                element.data.edges = element.data.edges + (item.value or 0)
            end
            element.data.bonuses = 0
            for _, item in pairs(element.data.itemLists.bonuses) do
                element.data.bonuses = element.data.bonuses + (item.value or 0)
            end
            element:FireEventTree("updateFields")
        end,

        executeRoll = function(element)

            local audit = ""
            local adjustDetails = element:GetChildrenWithClassRecursive("adjustDetail")
            if adjustDetails and #adjustDetails > 0 then
                for _, detail in ipairs(adjustDetails) do
                    local label, text = detail.data.getTypeAndText(detail)
                    if #audit > 0 then audit = audit .. "/n" end
                    audit = string.format("%s<b>%s</b> %s", audit, label, text)
                end
            end

            local rollString = element.data.calculateRoll(element)

            local token = CharacterSheet.instance.data.info.token

            -- Prevent closing while rolling
            element.data.isRolling = true

            local rollGuid = dmhub.GenerateGuid()
            dmhub.Roll {
                guid = rollGuid,
                roll = rollString,
                -- numKeep = 2,
                description = "Making a Project Roll",
                tokenid = token,
                complete = function(rollInfoArg)
                    local rollResult = {
                        banes = rollInfoArg.banes,
                        description = rollInfoArg.description,
                        edges = rollInfoArg.boons,
                        formattedText = rollInfoArg.formattedText,
                        key = rollInfoArg.key,
                        message = rollInfoArg.message,
                        naturalRoll = rollInfoArg.naturalRoll,
                        nick = rollInfoArg.nick,
                        nickColor = rollInfoArg.nickColor,
                        playerColor = rollInfoArg.playerColor,
                        playerName = rollInfoArg.playerName,
                        result = rollInfoArg.result,
                        resultInfo = rollInfoArg.resultInfo,
                        rolls = rollInfoArg.rolls,
                        rollStr = rollInfoArg.rollstr,
                        total = rollInfoArg.total,
                    }
                    element.data.roll:SetAudit(audit)
                        :SetRollGuid(rollInfoArg.key)
                        :SetRollString(rollString)
                        :SetRolledBy(token.name or "(unnamed character)")
                        :SetNaturalRoll(rollInfoArg.naturalRoll)
                        :SetBreakthrough(rollInfoArg.naturalRoll >= DTConstants.BREAKTHROUGH_MIN)
                        :SetAmount(math.max(1, rollInfoArg.total))
                    element.data.isRolling = false
                    options.callbacks.confirmHandler(element.data.roll)
                    element:FireEvent("close", true)
                end,
            }
        end,

        close = function(element, force)
            element.data.close(element, force)
        end,

        escape = function(element)
            if element.data.isRolling then return end
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
                    -- Top row - Edges, Banes, Bonuses
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "100%-10",
                        height = "60%-7",
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
                                            DTProjectRollDialog._makeExtraAdjustmentCheckText("edges"),
                                            DTProjectRollDialog._makeExtraAdjustmentCheckText("edges"),
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
                                                    element:FireEvent("change")
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
                                                            local item = {
                                                                id = element.id,
                                                                value = element.data.banes,
                                                                description = element.data.GetText(),
                                                            }
                                                            rollController:FireEvent("addItem", "banes", item)
                                                        else
                                                            rollController:FireEvent("removeItem", "banes", element.id)
                                                        end
                                                    end
                                                end,
                                            },
                                            DTProjectRollDialog._makeExtraAdjustmentCheckText("banes"),
                                            DTProjectRollDialog._makeExtraAdjustmentCheckText("banes"),
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
                                children = {
                                    gui.Label {
                                        classes = {"DTLabel", "DTBase"},
                                        text = "Bonuses",
                                        width = "100%",
                                        textAlignment = "center",
                                        valign = "top",
                                        updateFields = function(element)
                                            local controller = element:FindParentWithClass("rollController")
                                            if controller then
                                                local bonuses = controller.data.bonuses or 0
                                                element.text = string.format("Bonuses: %+d", bonuses)
                                            end
                                        end,
                                    },
                                    gui.Divider { width = "50%" },
                                    gui.Panel {
                                        classes = {"skillListController", "DTPanel", "DTBase"},
                                        width = "100%-8",
                                        height = "auto",
                                        flow = "vertical",
                                        borderColor = "cyan",
                                        children = {
                                            gui.Label {
                                                classes = {"DTLabel", "DTBase"},
                                                width = "100%-10",
                                                height = "30",
                                                textAlignment = "left",
                                                hmargin = 2,
                                                text = "+? (Attribute)",
                                                create = function(element)
                                                    local controller = element:FindParentWithClass("rollController")
                                                    if controller then
                                                        local project = controller.data.project
                                                        local attrId = project:GetTestCharacteristic()
                                                        local attrName = DTConstants.GetDisplayText(DTConstants.CHARACTERISTICS, attrId)
                                                        local attrVal = character:GetBaseAttribute(attrId).baseValue
                                                        local text = string.format("Characteristic: %s (%+d)", attrName, attrVal)
                                                        if text ~= element.text then
                                                            element.text = text
                                                            local item = {
                                                                id = element.id,
                                                                value = attrVal,
                                                                description = text
                                                            }
                                                            controller:FireEvent("addItem", "bonuses", item)
                                                        end
                                                    end
                                                end,
                                            },
                                            DTUtils.Multiselect{
                                                options = skillList,
                                                classes = {"DTDropdown", "DTBase"},
                                                width = "98%",
                                                halign = "left",
                                                vmargin = 4,
                                                textDefault = "Select a skill...",
                                                sort = true,
                                                data = {
                                                    skillsSelected = {},
                                                },
                                                change = function(element)
                                                    local newSelected = element.value
                                                    local curSelected = element.data.skillsSelected or {}
                                                    local changed = DTUtils.SyncArrays(curSelected, newSelected, function(item) return item.id end)
                                                    element.data.skillsSelected = curSelected
                                                    if changed then
                                                        local rollController = element:FindParentWithClass("rollController")
                                                        if rollController then
                                                            rollController:FireEvent("removeItem", "bonuses", element.id)
                                                            if #curSelected > 0 then
                                                                local description = curSelected[1].text
                                                                for i = 2, #curSelected do
                                                                    description = description .. ", " .. curSelected[i].text
                                                                end
                                                                local value = 2 * #curSelected

                                                                local item = {
                                                                    id = element.id,
                                                                    value = value,
                                                                    description = string.format("Skill%s: %s (%+d)", #curSelected > 0 and "s" or "", description, value)
                                                                }
                                                                rollController:FireEvent("addItem", "bonuses", item)
                                                            end
                                                        end
                                                    end
                                                end,
                                            },
                                        }
                                    }
                                }
                            },
                        }
                    },
                    -- Bottom row - Summary
                    gui.Panel {
                        classes = {"DTPanel", "DTBase"},
                        width = "100%-10",
                        height = "40%-7",
                        valign = "top",
                        flow = "vertical",
                        borderColor = "blue",
                        children = {
                            DTProjectRollDialog._makeExtraAdjustmentLabel("edges"),
                            DTProjectRollDialog._makeExtraAdjustmentLabel("banes"),
                            DTProjectRollDialog._makeExtraAdjustmentLabel("bonuses"),
                            gui.Panel {
                                classes = {"DTPanel", "DTBase"},
                                width = "100%-10",
                                height = "auto",
                                valign = "top",
                                flow = "horizontal",
                                borderColor = "yellow",
                                children = {
                                    gui.Label {
                                        classes = {"DTLabel", "DTBase"},
                                        width = 64,
                                        height = 30,
                                        valign = "center",
                                        textAlignment = "left",
                                        text = "Roll:"
                                    },
                                    gui.Label {
                                        classes = {"DTLabel", "DTBase"},
                                        width = "100%-80",
                                        height = 30,
                                        valign = "center",
                                        textAlignment = "left",
                                        bold = false,
                                        text = "Calculating...",
                                        updateFields = function(element)
                                            local controller = element:FindParentWithClass("rollController")
                                            if controller then
                                                element.text = controller.data.calculateRoll(controller)
                                            end
                                        end,
                                    }
                                }
                            }
                        }
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
                                controller:FireEvent("executeRoll")
                            end
                        end
                    }
                }
            }
        },
    }

    return resultPanel
end

--- Create a row showing either Edges or Banes descriptions
--- @param adjustType string Bane or Edge, either case is fine
--- @return Panel panel The panel containing the description
function DTProjectRollDialog._makeExtraAdjustmentLabel(adjustType)

    local lower, proper = adjustType:lower(), adjustType:sub(1, 1):upper() .. adjustType:sub(2):lower()
    local defaultLabel = string.format("No %s selected.", proper)

    return gui.Panel {
        classes = {"adjustDetail", "DTPanel", "DTBase"},
        width = "100%-10",
        height = "auto",
        valign = "top",
        flow = "horizontal",
        borderColor = "yellow",
        data = {
            getTypeAndText = function(element)
                local labelField = element:GetChildrenWithClass("adjustLabel")[1]
                local textField = element:GetChildrenWithClass("adjustText")[1]
                return labelField.text, textField.text
            end
        },
        children = {
            gui.Label {
                classes = {"adjustLabel", "DTLabel", "DTBase"},
                width = 64,
                height = 30,
                valign = "center",
                textAlignment = "left",
                text = proper .. ":"
            },
            gui.Label {
                classes = {"adjustText", "DTLabel", "DTBase"},
                width = "100%-80",
                height = 30,
                valign = "center",
                textAlignment = "left",
                bold = false,
                text = defaultLabel,
                updateFields = function(element)
                    local controller = element:FindParentWithClass("rollController")
                    if controller then
                        local items = controller.data.getItemList(controller, lower)
                        local text = ""
                        for _, item in pairs(items) do
                            local description = #item.description > 0 and item.description or "(no description)"
                            if #text > 0 then text = text .. ", " end
                            text = string.format("%s%s", text, description)
                        end
                        if #text == 0 then text = defaultLabel end
                        if text ~= element.text then element.text = text end
                    end
                end,
            }
        }
    }
end

--- Create a field with a checkbox on top and hidden text on bottom
--- such that when checked, it shows the field
--- @param adjustType string Bane or Edge, either case is fine
--- @return Panel panel The panel containing the control
function DTProjectRollDialog._makeExtraAdjustmentCheckText(adjustType)
    local lower, proper = adjustType:lower(), adjustType:sub(1, 1):upper() .. adjustType:sub(2):lower()

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
                element:FireEvent("updateRollController")
            end
        end,
        updateFields = function(element)
            element:FireEventTree("updateField", element)
        end,
        updateRollController = function(element)
            local rollController = element:FindParentWithClass("rollController")
            if rollController then
                if not element.data.isChecked then
                    rollController:FireEvent("removeItem", lower, element.id)
                else
                    local item = {
                        id = element.id,
                        value = element.data.value,
                        description = string.format("%s (x%d)", #element.data.description > 0 and element.data.description or "(no description)" , element.data.value)
                    }
                    rollController:FireEvent("addItem", lower, item)
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
