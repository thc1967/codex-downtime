if dmhub.isDM then
    local downtimeSettings = DTSettings:new()
    local directorPanel = DTDirectorPanel:new(downtimeSettings)
    if directorPanel then
        directorPanel:Register()
    end
end

creature.GetDowntimeInfo = function(self)
    return self:get_or_add(DTConstants.CHARACTER_STORAGE_KEY, DTInfo:new())
end

CharSheet.RegisterTab {
    id = "Downtime",
    text = "Downtime",
	visible = function(c)
		return c ~= nil and c:IsHero()
	end,
    panel = DTCharSheetTab.CreateDowntimePanel
}

dmhub.RefreshCharacterSheet()
