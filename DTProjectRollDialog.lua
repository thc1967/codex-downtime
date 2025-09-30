--- Project roll dialog for making downtime project rolls
--- @class DTProjectRollDialog
DTProjectRollDialog = RegisterGameType("DTProjectRollDialog")
DTProjectRollDialog.__index = DTProjectRollDialog

--- Creates a project roll dialog for AddChild usage
--- @param roll DTRoll|DTProgressItem The roll instance to edit
--- @param callbacks table Table with confirm and cancel callback functions
--- @return table panel The GUI panel ready for AddChild
function DTProjectRollDialog.CreateAsChild(roll, callbacks)
    local confirmHandler = function(element)
        if callbacks.confirm then
            callbacks.confirm()
        end
    end

    local cancelHandler = function(element)
        if callbacks.cancel then
            callbacks.cancel()
        end
    end

    return DTProjectRollDialog._createPanel(roll, confirmHandler, cancelHandler)
end

--- Private helper to create the roll dialog panel structure
--- @param roll DTRoll|DTProgressItem The roll instance to edit
--- @param confirmHandler function Handler function for confirm button click
--- @param cancelHandler function Handler function for cancel button click and escape
--- @return table panel The GUI panel structure
function DTProjectRollDialog._createPanel(roll, confirmHandler, cancelHandler)
    local resultPanel = nil
    resultPanel = gui.Panel {
        classes = {"projectRollDialogController", "DTDialog"},
        width = 800,
        height = 600,
        styles = DTUtils.GetDialogStyles(),
        floating = true,
        escapePriority = EscapePriority.EXIT_MODAL_DIALOG,
        captureEscape = true,
        data = {
            roll = roll,
            close = function()
                resultPanel:DestroySelf()
            end,
        },

        close = function(element)
            element.data.close()
        end,

        escape = function(element)
            cancelHandler(element)
            element:FireEvent("close")
        end,

        children = {
            -- Header
            gui.Label{
                text = "Make A Project Roll",
                fontSize = 24,
                width = "100%",
                height = 30,
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                halign = "center"
            },

            -- Form content (empty)
            gui.Panel{
                classes = {"DTPanel", "DTBase"},
                width = "100%",
                height = "100%-110",
                flow = "vertical",
                vmargin = 10,
                children = {
                }
            },

            -- Button panel
            gui.Panel{
                classes = {"DTPanel", "DTBase"},
                width = "100%",
                height = 40,
                halign = "center",
                valign = "center",
                children = {
                    gui.Button{
                        text = "Cancel",
                        width = 120,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            local controller = element:FindParentWithClass("projectRollDialogController")
                            if controller then
                                controller:FireEvent("escape")
                            end
                        end
                    },
                    gui.Button{
                        text = "Roll",
                        width = 120,
                        halign = "right",
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            local controller = element:FindParentWithClass("projectRollDialogController")
                            if controller then
                                confirmHandler(element)
                                controller:FireEvent("close")
                            end
                        end
                    }
                }
            }
        },
    }

    return resultPanel
end
