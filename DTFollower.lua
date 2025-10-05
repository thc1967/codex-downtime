--- @class DTFollowerCharacteristic
--- Represents a Characteristic score for a follower
--- @field id "mgt"|"agl"|"rea"|"inu"|"prs" The attribute identifier
--- @field value number The attribute value

--- A follower - Artisan or Retainer - who can participate in downtime proejcts
--- @class DTFollower
--- @field id string GUID identifier for this follower
--- @field type "artisan"|"sage" The type of this follower
--- @field name string The name the player has given the follower
--- @field characteristics DTFollowerCharacteristic[] The follower's characteristic scores
--- @field skills string[] List of skills this follower knows
--- @field languages string[] List of languages this follower knows
--- @field availableRolls number The number of rolls this follower has available
DTFollower = RegisterGameType("DTFollower")
DTFollower.__index = DTFollower

local DEFAULT_FOLLOWER_TYPE = DTConstants.FOLLOWER_TYPE.ARTISAN.key

--- Creates a new DTFollower instance
--- @return DTFollower instance The new follower instance
function DTFollower:new()
    local instance = setmetatable({}, self)

    instance.id = dmhub.GenerateGuid()
    instance.type = DEFAULT_FOLLOWER_TYPE
    instance.name = ""
    instance.characteristics = {}
    for i, c in ipairs(DTConstants.CHARACTERISTICS) do
        instance.characteristics[i] = { id = c.key, value = 0 }
    end
    instance.skills = {}
    instance.languages = {}
    instance.availableRolls = 0

    return instance
end

--- Gets the identifier of this follower
--- @return string id GUID id of this follower
function DTFollower:GetID()
    return self.id
end

--- Gets the type of this follower
--- @return string type One of DTConstants.FOLLOWER_TYPE values
function DTFollower:GetType()
    return self.type or DEFAULT_FOLLOWER_TYPE
end

--- Sets the type of this follower
--- @param followerType string One of DTConstants.FOLLOWER_TYPE values
--- @return DTFollower self For chaining
function DTFollower:SetType(followerType)
    if self:_isValidFollowerType(followerType) then
        self.type = followerType
    end
    return self
end

--- Gets the name of this follower
--- @return string name The follower's name
function DTFollower:GetName()
    return self.name or ""
end

--- Sets the name of this follower
--- @param name string The new name for the follower
--- @return DTFollower self For chaining
function DTFollower:SetName(name)
    self.name = name or ""
    return self
end

--- Gets the characteristics of this follower
--- @return DTFollowerCharacteristic[] characteristics The follower's characteristics
function DTFollower:GetCharacteristics()
    return self.characteristics or {}
end

--- Sets the characteristics of this follower
--- @param characteristics DTFollowerCharacteristic[] The characteristics
--- @return DTFollower self For chaining
function DTFollower:SetCharacteristics(characteristics)
    self.characteristics = characteristics or {}
    return self
end

--- Gets the skills of this follower
--- @return string[] skills The follower's skills
function DTFollower:GetSkills()
    return self.skills or {}
end

--- Sets the skills of this follower
--- @param skills string[] The skills
--- @return DTFollower self For chaining
function DTFollower:SetSkills(skills)
    self.skills = skills or {}
    return self
end

--- Gets the languages of this follower
--- @return string[] languages The follower's languages
function DTFollower:GetLanguages()
    return self.languages or {}
end

--- Sets the languages of this follower
--- @param languages string[] The languages
--- @return DTFollower self For chaining
function DTFollower:SetLanguages(languages)
    self.languages = languages or {}
    return self
end

--- Gets the number of available rolls
--- @return number availableRolls The number of available rolls
function DTFollower:GetAvailableRolls()
    return self.availableRolls or 0
end

--- Sets the number of available rolls
--- @param rolls number The new number of available rolls
--- @return DTFollower self For chaining
function DTFollower:SetAvailableRolls(rolls)
    self.availableRolls = math.max(0, math.floor(rolls or 0))
    return self
end

--- Modifies the available rolls counter
--- @param rolls number The number of rolls to add
--- @return DTFollower self For chaining
function DTFollower:GrantRolls(rolls)
    self.availableRolls = math.max(0, (self.availableRolls or 0) + (rolls or 0))
    return self
end

--- Validates if the given follower type is valid
--- @param followerType string The follower type to validate
--- @return boolean valid True if the type is valid
function DTFollower:_isValidFollowerType(followerType)
    for _, validType in pairs(DTConstants.FOLLOWER_TYPE) do
        if followerType == validType.key then
            return true
        end
    end
    return false
end