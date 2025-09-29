--- Project roll record for tracking dice rolls made on downtime projects
--- Records all details of a roll including modifiers, results, and context
--- @class DTProjectRoll
--- @field id string GUID identifier for this roll
--- @field timestamp string|osdate When the roll occurred
--- @field edges number 0-2. Number of edges applied to the roll
--- @field banes number 0-2. Number of banes applied to the roll
--- @field languagePenalty string Auto-applied based on the setting on the Downtime Project
--- @field skill string|nil Optional. Selected from a drop-down list of available skills
--- @field followerRoll boolean Whether this roll was made by a follower on behalf of the character
--- @field naturalRoll number The unmodified die roll result
--- @field modifiedRoll number The final roll result after applying all modifiers
--- @field breakthrough boolean Whether this roll was triggered by a Breakthrough
--- @field createdBy string User ID of the user who made the roll
--- @field serverTime number|nil Unity server time when roll was committed
DTProjectRoll = RegisterGameType("DTProjectRoll")
DTProjectRoll.__index = DTProjectRoll


--- Creates a new project roll instance
--- @param naturalRoll number The unmodified die roll result
--- @param modifiedRoll number The final roll result after applying all modifiers
--- @return DTProjectRoll instance The new project roll instance
function DTProjectRoll:new(naturalRoll, modifiedRoll)
    local instance = setmetatable({}, self)

    instance.id = dmhub.GenerateGuid()
    instance.edges = 0
    instance.banes = 0
    instance.languagePenalty = DTConstants.LANGUAGE_PENALTY.NONE.key
    instance.skill = nil
    instance.followerRoll = false
    instance.naturalRoll = math.floor(naturalRoll or 0)
    instance.modifiedRoll = math.floor(modifiedRoll or 0)
    instance.breakthrough = false
    instance.timestamp = ""
    instance.createdBy = ""
    instance.serverTime = 0

    return instance
end

--- Gets the identifier of this roll
--- @return string id GUID id of this roll
function DTProjectRoll:GetID()
    return self.id
end

--- Gets when this roll occurred
--- @return string|osdate timestamp ISO 8601 UTC timestamp
function DTProjectRoll:GetTimestamp()
    return self.timestamp
end

--- Gets the number of edges applied to the roll
--- @return number edges Number of edges (0-2)
function DTProjectRoll:GetEdges()
    return self.edges or 0
end

--- Sets the number of edges applied to the roll
--- @param edges number Number of edges (0-2)
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetEdges(edges)
    self.edges = math.max(0, math.min(2, math.floor(edges or 0)))
    return self
end

--- Gets the number of banes applied to the roll
--- @return number banes Number of banes (0-2)
function DTProjectRoll:GetBanes()
    return self.banes or 0
end

--- Sets the number of banes applied to the roll
--- @param banes number Number of banes (0-2)
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetBanes(banes)
    self.banes = math.max(0, math.min(2, math.floor(banes or 0)))
    return self
end

--- Gets the language penalty for this roll
--- @return string languagePenalty One of DTConstants.LANGUAGE_PENALTY values
function DTProjectRoll:GetLanguagePenalty()
    return self.languagePenalty or DTConstants.LANGUAGE_PENALTY.NONE
end

--- Sets the language penalty for this roll
--- @param penalty string One of DTConstants.LANGUAGE_PENALTY values
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetLanguagePenalty(penalty)
    if self:_isValidLanguagePenalty(penalty) then
        self.languagePenalty = penalty
    end
    return self
end

--- Gets the skill used for this roll
--- @return string|nil skill The skill name or nil if no skill was used
function DTProjectRoll:GetSkill()
    return self.skill
end

--- Sets the skill used for this roll
--- @param skill string|nil The skill name or nil to clear
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetSkill(skill)
    self.skill = skill
    return self
end

--- Gets whether this was a follower roll
--- @return boolean followerRoll True if this roll was made by a follower
function DTProjectRoll:GetFollowerRoll()
    return self.followerRoll or false
end

--- Sets whether this was a follower roll
--- @param isFollowerRoll boolean True if this roll was made by a follower
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetFollowerRoll(isFollowerRoll)
    self.followerRoll = isFollowerRoll or false
    return self
end

--- Gets the natural (unmodified) roll result
--- @return number naturalRoll The unmodified die roll result
function DTProjectRoll:GetNaturalRoll()
    return self.naturalRoll or 0
end

--- Sets the natural (unmodified) roll result
--- @param roll number The unmodified die roll result
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetNaturalRoll(roll)
    self.naturalRoll = math.floor(roll or 0)
    return self
end

--- Gets the modified roll result
--- @return number modifiedRoll The final roll result after applying all modifiers
function DTProjectRoll:GetModifiedRoll()
    return self.modifiedRoll or 0
end

--- Sets the modified roll result
--- @param roll number The final roll result after applying all modifiers
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetModifiedRoll(roll)
    self.modifiedRoll = math.floor(roll or 0)
    return self
end

--- Gets whether this roll was triggered by a breakthrough
--- @return boolean breakthrough True if this was a breakthrough roll
function DTProjectRoll:GetBreakthrough()
    return self.breakthrough or false
end

--- Sets whether this roll was triggered by a breakthrough
--- @param isBreakthrough boolean True if this was a breakthrough roll
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetBreakthrough(isBreakthrough)
    self.breakthrough = isBreakthrough or false
    return self
end

--- Gets who created this roll
--- @return string createdBy The Codex player ID of the roll creator
function DTProjectRoll:GetCreatedBy()
    return self.createdBy
end

--- Sets all commit information when roll is saved to project
--- @return DTProjectRoll self For chaining
function DTProjectRoll:SetCommitInfo()
    self.serverTime = dmhub.serverTime
    self.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    self.createdBy = dmhub.userid
    return self
end

--- Gets the server time when roll was committed
--- @return number|nil serverTime Unity server time or nil if not committed
function DTProjectRoll:GetServerTime()
    return self.serverTime
end

--- Validates if the given language penalty is valid
--- @param penalty string The language penalty to validate
--- @return boolean valid True if the penalty is valid
--- @private
function DTProjectRoll:_isValidLanguagePenalty(penalty)
    for _, validPenalty in pairs(DTConstants.LANGUAGE_PENALTY) do
        if penalty == validPenalty then
            return true
        end
    end
    return false
end