--- Downtime follower information - A single follower
--- @class DTFollower
--- @field id string The GUID uniquely identifying the follower
--- @field name string The follower's name
--- @field languages table The list of flags languages
--- @field skills table The list of flags skills
--- @field characteristics table The list of characteristic values for the follower
--- @field portrait string The unique identifier for the follower's portrait
DTFollower = RegisterGameType("DTFollower")
DTFollower.__index = DTFollower

--- Create a new follower object
--- @param follower table A Codex follower structure
--- @param token CharacterToken|nil A Codex character token that is the parent object of the follower
--- @return DTFollower|nil follower A downtime follower object
function DTFollower:new(follower, token)
    if follower == nil then return nil end

    local instance = setmetatable({}, self)

    -- guid might not be there - ensure it is
    instance.id = follower.guid or ""
    if #instance.id == 0 then
        if token == nil or token.properties == nil then return nil end
        token:ModifyProperties{
            description = "Add ID to follower",
            execute = function ()
                follower.guid = dmhub.GenerateGuid()
                instance.id = follower.guid
            end,
        }
    end

    instance.languages = follower.languages or {}
    instance.skills = follower.skills or {}
    instance.name = follower.name or "(unnamed follower)"
    instance.portrait = follower.portrait or ""

    instance.characteristics = {}
    for _, char in ipairs(DTConstants.CHARACTERISTICS) do
        instance.characteristics[char.id] = 0
    end

    return instance
end

--- Returns the follower's unique identifier
--- @return string id The GUID uniquely identifying the follower
function DTFollower:GetID()
    return self.id
end

--- Returns the follower's name
--- @return string name The follower's name
function DTFollower:GetName()
    return self.name
end

--- Returns the follower's languages
--- @return table languages The list of flags languages
function DTFollower:GetLanguages()
    return self.languages
end

--- Returns the follower's skills
--- @return table skills The list of flags skills
function DTFollower:GetSkills()
    return self.skills
end

--- Returns the follower's portrait identifier
--- @return string portrait The unique identifier for the follower's portrait
function DTFollower:GetPortrait()
    return self.portrait
end

--- Returns the follower's characteristics
--- @return table characteristics The list of characteristic values for the follower
function DTFollower:GetCharacteristics()
    return self.characteristics
end
