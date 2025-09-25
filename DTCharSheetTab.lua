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
        bgimage = true,
        bgcolor = "clear",
        width = "100%",
        height = "100%",
        flow = "vertical",
        valign = "center",
        halign = "center",

        gui.Label {
            text = "Downtime Activities",
            width = "auto",
            height = "auto",
            fontSize = 24,
            fontWeight = "bold",
            halign = "center",
        },
        gui.Input {
            width = "50%",
            height = 25,
            text = "",
            placeholderText = "enter some info",
            editlag = 0.25,
            edit = function(element)
                local dt = CharacterSheet.instance.data.info.token.properties:get_or_add("downtime_projects", element.text)
                dt = element.text
                CharacterSheet.instance:FireEvent("refreshAll")
            end,
            refreshToken = function(element, info)
                element.text = CharacterSheet.instance.data.info.token.properties:try_get("downtime_projects") or ""
            end,
        },

        gui.Panel {
            height = 20,
            width = "100%"
        },
    }

    return downtimePanel
end

-- Register the Downtime tab at the top level of the character sheet
CharSheet.RegisterTab {
    id = "Downtime",
    text = "Downtime",
	visible = function(c)
		--only visible for characters.
		return c ~= nil and c:IsHero()
	end,
    panel = DTCharSheetTab.CreateDowntimePanel
}