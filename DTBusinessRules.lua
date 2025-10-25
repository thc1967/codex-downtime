--- Business logic and game rule calculations for downtime system
--- Domain-specific operations for projects, characters, and game mechanics
--- @class DTBusinessRules
DTBusinessRules = RegisterGameType("DTBusinessRules")

local mod = dmhub.GetModLoading()

--- Calculates the language penalty based on whether any known language
--- is in the list of required or related to any in the list of required
--- @param required string[] List of candidate required language ids
--- @param known string[] list of known language ids
--- @return string penalty The penalty level
function DTBusinessRules.CalcLangPenalty(required, known)
    local penalty = DTConstants.LANGUAGE_PENALTY.UNKNOWN.key
    local langRels = dmhub.GetTableVisible(LanguageRelation.tableName)

    for _, reqId in ipairs(required) do
        -- Do we know the language?
        if known[reqId]  then
            penalty = DTConstants.LANGUAGE_PENALTY.NONE.key
            break
        -- Or do we have a related language?
        elseif langRels[reqId] then
            for relId, _ in pairs(langRels[reqId].related) do
                if known[relId] then
                    penalty = DTConstants.LANGUAGE_PENALTY.RELATED.key
                    break
                end
            end
        end
    end

    return penalty
end

--- Gets all the tokens in the game that are heroes
--- @param filter? function Filter callback to apply, called on token object, added if return is true
--- @return table heroes The list of heroes in the game
function DTBusinessRules.GetAllHeroTokens(filter)
    if filter and type(filter) ~= "function" then error("arg1 must be nil or a function") end
    local heroes = {}

    local partyTable = dmhub.GetTable(Party.tableName)
    for partyId, _ in pairs(partyTable) do
        local characterIds = dmhub.GetCharacterIdsInParty(partyId)
        for _, characterId in ipairs(characterIds) do
            local character = dmhub.GetCharacterById(characterId)
            if character and character.properties and character.properties:IsHero() then
                if filter == nil or filter(character) then
                    heroes[#heroes + 1] = character
                end
            end
        end
    end

    -- Also get unaffiliated characters (director controlled on current map)
    local unaffiliatedTokens = dmhub.GetTokens{ unaffiliated = true }
    for _, token in ipairs(unaffiliatedTokens) do
        local character = dmhub.GetCharacterById(token.charid)
        if character and character.properties and character.properties:IsHero() then
            if filter == nil or filter(character) then
                heroes[#heroes + 1] = character
            end
        end
    end

    -- Optionally include despawned characters from graveyard
    local despawnedTokens = dmhub.despawnedTokens or {}
    for _, token in ipairs(despawnedTokens) do
        local character = dmhub.GetCharacterById(token.charid)
        if character and character.properties and character.properties:IsHero() then
            if filter == nil or filter(character) then
                heroes[#heroes + 1] = character
            end
        end
    end

    return heroes
end

--- Gets all projects shared with a recipient along with owner information
--- @param recipientId string The token ID of the character receiving shares
--- @return table sharedProjects Array of {project, ownerId, ownerName} or empty array if none
function DTBusinessRules.GetSharedProjectsForRecipient(recipientId)
    -- Validate input
    if not recipientId or type(recipientId) ~= "string" or #recipientId == 0 then
        return {}
    end

    -- Get shares for this recipient
    local shares = DTShares:new()
    local sharedWith = shares:GetSharedWith(recipientId)
    if not sharedWith or not next(sharedWith) then
        return {}
    end

    -- Build array of shared projects with owner info
    local sharedProjects = {}
    for projectId, ownerId in pairs(sharedWith) do
        -- Get owner token (may be nil if character was deleted)
        local ownerToken = dmhub.GetCharacterById(ownerId)
        if ownerToken then
            local ownerName = ownerToken.name
            local ownerColor = ownerToken.playerColor and ownerToken.playerColor.tostring or nil

            -- Get owner's downtime info
            local ownerDTInfo = ownerToken.properties:GetDowntimeInfo()
            if ownerDTInfo then
                -- Get the specific project
                local project = ownerDTInfo:GetProject(projectId)
                if project then
                    sharedProjects[#sharedProjects + 1] = {
                        project = project,
                        ownerId = ownerId,
                        ownerName = ownerName,
                        ownerColor = ownerColor
                    }
                end
            end
        end
    end

    return sharedProjects
end

--- Finds languages in the text and returns their id's
--- @param text string Text that may or may not have language names embedded
--- @return table langIds List of language id's of language names found in the table
function DTBusinessRules.ExtractLanguagesToIds(text)
    local lowerText = string.lower(text or "")
    local langIds = {}

    if #lowerText > 0 then
        local langs = dmhub.GetTableVisible(Language.tableName)

        for id, item in pairs(langs) do
            if item.name and string.find(lowerText, string.lower(item.name), 1, true) then
                langIds[#langIds + 1] = id
            end
        end
    end

    return langIds
end
