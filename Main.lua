if dmhub.isDM then
    local downtimeSettings = DTSettings:new()
    local directorPanel = DTDirectorPanel:new(downtimeSettings)
    if directorPanel then
        directorPanel:Register()
    end
end

-- TODO: This is debug remove it.
CharSheet.defaultSheet = "Downtime"
dmhub.RefreshCharacterSheet()