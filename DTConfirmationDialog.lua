local mod = dmhub.GetModLoading()

--- Confirmation Dialog - Reusable confirmation dialog for modal windows
--- Provides consistent confirmation UI with standardized styling
--- @class DTConfirmationDialog
DTConfirmationDialog = {}

--- Shows a generic confirmation dialog with customizable title and message
--- @param title string The title text for the dialog header
--- @param message string The main confirmation message text
--- @param confirmButtonText string Optional text for the confirm button (default: "OK")
--- @param cancelButtonText string Optional text for the cancel button (default: "Cancel")
--- @param onConfirm function Callback function to execute if user confirms
--- @param onCancel function|nil Optional callback function to execute if user cancels (default: just close dialog)
function DTConfirmationDialog.ShowModal(title, message, confirmButtonText, cancelButtonText, onConfirm, onCancel)
    -- Set default button text if not provided or empty
    confirmButtonText = (confirmButtonText and confirmButtonText ~= "") and confirmButtonText or "Confirm"
    cancelButtonText = (cancelButtonText and cancelButtonText ~= "") and cancelButtonText or "Cancel"

    local confirmationWindow = gui.Panel{
        width = 400,
        height = 200,
        halign = "center",
        valign = "center",
        bgcolor = "#111111ff",
        borderWidth = 2,
        borderColor = Styles.textColor,
        bgimage = "panels/square.png",
        flow = "vertical",
        hpad = 20,
        vpad = 20,
        styles = DTUtils.GetDialogStyles(),

        children = {
            -- Header
            gui.Label{
                text = title,
                fontSize = 24,
                width = "100%",
                height = 30,
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                halign = "center"
            },

            -- Confirmation message
            gui.Label{
                text = message,
                width = "100%",
                height = 80,
                classes = {"DTLabel", "DTBase"},
                textAlignment = "center",
                textWrap = true,
                halign = "center",
                valign = "center"
            },

            -- Button panel
            gui.Panel{
                width = "100%",
                height = 40,
                flow = "horizontal",
                halign = "center",
                valign = "center",
                children = {
                    -- Cancel button (first)
                    gui.Button{
                        text = cancelButtonText,
                        width = 120,
                        height = 40,
                        hmargin = 10,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            gui.CloseModal()
                            if onCancel then
                                onCancel()
                            end
                        end
                    },
                    -- Confirm button (second)
                    gui.Button{
                        text = confirmButtonText,
                        width = 120,
                        height = 40,
                        hmargin = 10,
                        classes = {"DTButton", "DTBase"},
                        click = function(element)
                            gui.CloseModal()
                            if onConfirm then
                                onConfirm()
                            end
                        end
                    }
                }
            }
        },

        escape = function(element)
            gui.CloseModal()
            if onCancel then
                onCancel()
            end
        end
    }

    gui.ShowModal(confirmationWindow)
end

--- Shows a standardized delete confirmation dialog
--- @param itemType string The type of item being deleted ("quest", "note", "objective")
--- @param itemTitle string The display name/title of the item being deleted
--- @param onConfirm function Callback function to execute if user confirms deletion
--- @param onCancel function Optional callback function to execute if user cancels (default: just close dialog)
function DTConfirmationDialog.ShowDeleteModal(itemType, itemTitle, onConfirm, onCancel)
    local title = "Delete Confirmation"
    local message = "Are you sure you want to delete " .. itemType .. " \"" .. (itemTitle or "Untitled") .. "\"?"

    DTConfirmationDialog.ShowModal(title, message, "Delete", "Cancel", onConfirm, onCancel)
end