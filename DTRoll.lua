--- Project roll record for tracking dice rolls made on downtime projects
--- Records all details of a roll including modifiers, results, and context
--- @class DTRoll
--- @field edges number 0-2. Number of edges applied to the roll
--- @field banes number 0-2. Number of banes applied to the roll
--- @field languagePenalty string Auto-applied based on the setting on the Downtime Project
--- @field skill string|nil Optional. Selected from a drop-down list of available skills
--- @field rolledBy string The name of the character or follower responsible for the roll
--- @field naturalRoll number The unmodified die roll result
--- @field modifiedRoll number The final roll result after applying all modifiers
--- @field breakthrough boolean Whether this roll was triggered by a Breakthrough
DTRoll = RegisterGameType("DTRoll", "DTProgressItem")
DTRoll.__index = DTRoll

--- Creates a new project roll instance
--- @param naturalRoll? number The unmodified die roll result
--- @param modifiedRoll? number The final roll result after applying all modifiers
--- @return DTRoll|DTProgressItem instance The new project roll instance
function DTRoll:new(naturalRoll, modifiedRoll)
    local instance = setmetatable(DTProgressItem:new(modifiedRoll), self)

    instance.edges = 0
    instance.banes = 0
    instance.languagePenalty = DTConstants.LANGUAGE_PENALTY.NONE.key
    instance.skill = nil
    instance.rolledBy = ""
    instance.naturalRoll = math.floor(naturalRoll or 0)
    instance.modifiedRoll = math.floor(modifiedRoll or 0)
    instance.breakthrough = false

    return instance
end

--- Sets the number of edges applied to the roll
--- @param edges number Number of edges (0-2)
--- @return DTRoll self For chaining
function DTRoll:SetEdges(edges)
    self.edges = math.max(0, math.min(2, math.floor(edges or 0)))
    return self
end

--- Gets the number of edges applied to the roll
--- @return number edges Number of edges (0-2)
function DTRoll:GetEdges()
    return self.edges or 0
end

--- Sets the number of banes applied to the roll
--- @param banes number Number of banes (0-2)
--- @return DTRoll self For chaining
function DTRoll:SetBanes(banes)
    self.banes = math.max(0, math.min(2, math.floor(banes or 0)))
    return self
end

--- Gets the number of banes applied to the roll
--- @return number banes Number of banes (0-2)
function DTRoll:GetBanes()
    return self.banes or 0
end

--- Sets the language penalty for this roll
--- @param penalty string One of DTConstants.LANGUAGE_PENALTY values
--- @return DTRoll self For chaining
function DTRoll:SetLanguagePenalty(penalty)
    if self:_isValidLanguagePenalty(penalty) then
        self.languagePenalty = penalty
    end
    return self
end

--- Gets the language penalty for this roll
--- @return string languagePenalty One of DTConstants.LANGUAGE_PENALTY values
function DTRoll:GetLanguagePenalty()
    return self.languagePenalty or DTConstants.LANGUAGE_PENALTY.NONE.key
end

--- Sets the skill used for this roll
--- @param skill string|nil The skill name or nil to clear
--- @return DTRoll self For chaining
function DTRoll:SetSkill(skill)
    self.skill = skill
    return self
end

--- Gets the skill used for this roll
--- @return string|nil skill The skill name or nil if no skill was used
function DTRoll:GetSkill()
    return self.skill
end

--- Gets the name of the entity responsible for this roll
--- @param rolledBy string The name of the entity responsible for this roll
--- @return DTRoll self For chaining
function DTRoll:SetFollowerRoll(rolledBy)
    self.rolledBy = rolledBy or ""
    return self
end

--- Sets the name of the entity responsible for this roll
--- @return string rolledBy The name of the entity responsible for this roll
function DTRoll:GetFollowerRoll()
    return self.rolledBy or ""
end

--- Sets the natural (unmodified) roll result
--- @param roll number The unmodified die roll result
--- @return DTRoll self For chaining
function DTRoll:SetNaturalRoll(roll)
    self.naturalRoll = math.floor(roll or 0)
    return self
end

--- Gets the natural (unmodified) roll result
--- @return number naturalRoll The unmodified die roll result
function DTRoll:GetNaturalRoll()
    return self.naturalRoll or 0
end

--- Sets whether this roll was triggered by a breakthrough
--- @param isBreakthrough boolean True if this was a breakthrough roll
--- @return DTRoll self For chaining
function DTRoll:SetBreakthrough(isBreakthrough)
    self.breakthrough = isBreakthrough or false
    return self
end

--- Gets whether this roll was triggered by a breakthrough
--- @return boolean breakthrough True if this was a breakthrough roll
function DTRoll:GetBreakthrough()
    return self.breakthrough or false
end

--- Validates if the given language penalty is valid
--- @param penalty string The language penalty to validate
--- @return boolean valid True if the penalty is valid
--- @private
function DTRoll:_isValidLanguagePenalty(penalty)
    for _, validPenalty in pairs(DTConstants.LANGUAGE_PENALTY) do
        if penalty == validPenalty.key then
            return true
        end
    end
    return false
end
