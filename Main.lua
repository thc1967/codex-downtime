if dmhub.isDM then
    local downtimeSettings = DTSettings:new()
    local directorPanel = DTDirectorPanel:new(downtimeSettings)
    if directorPanel then
        directorPanel:Register()
    end
end

CharSheet.RegisterTab {
    id = "Downtime",
    text = "Downtime",
	visible = function(c)
		return c ~= nil and c:IsHero()
	end,
    panel = DTCharSheetTab.CreateDowntimePanel
}

if DTConstants.DEVMODE then
    CharSheet.defaultSheet = "Downtime"
end
dmhub.RefreshCharacterSheet()
