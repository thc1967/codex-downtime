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
        classes = {"rollController", "DTDialog"},
        width = 800,
        height = 600,
        styles = DTUtils.GetDialogStyles(),
        floating = true,
        escapePriority = EscapePriority.EXIT_MODAL_DIALOG,
        captureEscape = true,
        data = {
            edges = 0,
            banes = 0,
            roll = roll,
            close = function()
                resultPanel:DestroySelf()
            end,
        },

        create = function(element)
            element:FireEventTree("updateForm")
        end,

        setBanes = function(element, banes)
            element.data.banes = banes
            element:FireEventTree("updateForm")
        end,

        setEdges = function(element, edges)
            element.data.edges = edges
            element:FireEventTree("updateForm")
        end,

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
                classes = {"DTLabel", "DTBase"},
                text = "Make A Project Roll",
                fontSize = 24,
                width = "100%",
                height = 30,
                textAlignment = "center",
                -- halign = "center",
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
                        width = "99%",
                        height = "48%",
                        valign = "top",
                        flow = "horizontal",
                        borderColor = "blue",
                        children = {
                            -- Left Side - Edges
                            gui.Panel {
                                classes = {"edgesController", "DTPanel", "DTBase"},
                                width = "49%",
                                height = "98%",
                                valign = "top",
                                flow = "vertical",
                                borderColor = "yellow",
                                data = {
                                    getEdges = function(element)
                                        local controller = element:FindParentWithClass("rollController")
                                        if controller then
                                            return controller.data.edges
                                        end
                                        return 0
                                    end,
                                },
                                children = {
                                    gui.Label {
                                        classes = {"DTLabel", "DTBase"},
                                        text = "Edges",
                                        width = "100%",
                                        textAlignment = "center",
                                        valign = "top",
                                        updateForm = function(element)
                                            local edgesController = element:FindParentWithClass("edgesController")
                                            local edges = edgesController and edgesController.data.getEdges(element) or 0
                                            element.text = string.format("Edges x%d", edges)
                                        end,
                                    },
                                    gui.Divider { width = "50%" },
                                    gui.Panel {
                                        classes = {"DTPanel", "DTBase"},
                                        width = "98%",
                                        height = "84%",
                                        borderColor = "cyan",
                                        children = {}
                                    }
                                }
                            },
                            -- Right Side - Banes
                            gui.Panel {
                                classes = {"banesController", "DTPanel", "DTBase"},
                                width = "49%",
                                height = "98%",
                                valign = "top",
                                flow = "vertical",
                                borderColor = "yellow",
                                data = {
                                    getBanes = function(element)
                                        local controller = element:FindParentWithClass("rollController")
                                        if controller then
                                            return controller.data.banes
                                        end
                                        return 0
                                    end,
                                },
                                children = {
                                    gui.Label {
                                        classes = {"DTLabel", "DTBase"},
                                        text = "Banes",
                                        width = "100%",
                                        textAlignment = "center",
                                        valign = "top",
                                        updateForm = function(element)
                                            local banesController = element:FindParentWithClass("banesController")
                                            local banes = banesController and banesController.data.getBanes(element) or 0
                                            element.text = string.format("Banes x%d", banes)
                                        end,
                                    },
                                    gui.Divider { width = "50%" },
                                    gui.Panel {
                                        classes = {"DTPanel", "DTBase"},
                                        width = "98%",
                                        height = "84%",
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
                        width = "99%",
                        height = "48%",
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
                halign = "center",
                valign = "bottom",
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
