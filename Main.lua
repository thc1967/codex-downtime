--- Register the Director panel if we're a Director
if dmhub.isDM then
    local downtimeSettings = DTSettings:new()
    local directorPanel = DTDirectorPanel:new(downtimeSettings)
    if directorPanel then
        directorPanel:Register()
    end
end

--- Extend creature to support our data
creature.GetDowntimeInfo = function(self)
    return self:get_or_add(DTConstants.CHARACTER_STORAGE_KEY, DTInfo:new())
end

--- Our tab in the character sheet
CharSheet.RegisterTab {
    id = "Downtime",
    text = "Downtime",
	visible = function(c)
		return c ~= nil and c:IsHero()
	end,
    panel = DTCharSheetTab.CreateDowntimePanel
}
dmhub.RefreshCharacterSheet()
