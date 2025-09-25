--- Downtime project containing all project data and progress tracking
--- Represents a complete downtime project with status tracking, rolls, and adjustments
--- @class DTDowntimeProject
--- @field id string GUID identifier for this project
--- @field title string The name of the project
--- @field itemPrerequisite string Any special items required to start/continue the project
--- @field projectSource string The lore source (book, tutor, etc.) enabling this project
--- @field projectSourceLanguagePenalty string The character's language relationship to the project source language
--- @field testCharacteristic string The characteristic used for project rolls
--- @field projectGoal number The total project points needed to complete the project
--- @field status string Current state of the project
--- @field statusReason string Explanation for why the project is paused (if applicable)
--- @field milestoneThreshold number|nil Progress value at which the project automatically pauses for Director review
--- @field earnedBreakthroughs number Counter for breakthroughs that couldn't be used immediately due to hitting a milestone
--- @field pendingRolls number Number of rolls the player has staged for this project
--- @field projectRolls table Array of DTProjectRoll objects - History of all rolls made on this project
--- @field progressAdjustments table Array of DTProgressAdjustment objects - History of all adjustments made to project progress
--- @field createdBy string GUID identifier of the user who created this project
DTDowntimeProject = RegisterGameType("DTDowntimeProject")
DTDowntimeProject.__index = DTDowntimeProject


--- Creates a new downtime project instance
--- @return DTDowntimeProject instance The new project instance
function DTDowntimeProject:new()
    local instance = setmetatable({}, self)

    instance.id = dmhub.GenerateGuid()
    instance.title = ""
    instance.itemPrerequisite = ""
    instance.projectSource = ""
    instance.projectSourceLanguagePenalty = DTConstants.LANGUAGE_PENALTY.NONE
    instance.testCharacteristic = DTConstants.CHARACTERISTICS.MIGHT
    instance.projectGoal = 1
    instance.status = DTConstants.STATUS.PAUSED
    instance.statusReason = "New Project"
    instance.milestoneThreshold = nil
    instance.earnedBreakthroughs = 0
    instance.pendingRolls = 0
    instance.projectRolls = {}
    instance.progressAdjustments = {}
    instance.createdBy = dmhub.userid

    return instance
end

--- Gets the identifier of this project
--- @return string id GUID id of this project
function DTDowntimeProject:GetID()
    return self.id
end

--- Gets the title of this project
--- @return string title The project title
function DTDowntimeProject:GetTitle()
    return self.title or ""
end

--- Sets the title of this project
--- @param title string The new title for the project
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetTitle(title)
    self.title = title or ""
    return self
end

--- Gets the item prerequisite for this project
--- @return string itemPrerequisite The item prerequisite
function DTDowntimeProject:GetItemPrerequisite()
    return self.itemPrerequisite or ""
end

--- Sets the item prerequisite for this project
--- @param prerequisite string The item prerequisite
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetItemPrerequisite(prerequisite)
    self.itemPrerequisite = prerequisite or ""
    return self
end

--- Gets the project source
--- @return string projectSource The project source
function DTDowntimeProject:GetProjectSource()
    return self.projectSource or ""
end

--- Sets the project source
--- @param source string The project source
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetProjectSource(source)
    self.projectSource = source or ""
    return self
end

--- Gets the project source language penalty
--- @return string languagePenalty One of DTConstants.LANGUAGE_PENALTY values
function DTDowntimeProject:GetProjectSourceLanguagePenalty()
    return self.projectSourceLanguagePenalty or DTConstants.LANGUAGE_PENALTY.NONE
end

--- Sets the project source language penalty
--- @param penalty string One of DTConstants.LANGUAGE_PENALTY values
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetProjectSourceLanguagePenalty(penalty)
    if self:_isValidLanguagePenalty(penalty) then
        self.projectSourceLanguagePenalty = penalty
    end
    return self
end

--- Gets the test characteristic
--- @return string characteristic One of DTConstants.CHARACTERISTICS values
function DTDowntimeProject:GetTestCharacteristic()
    return self.testCharacteristic or DTConstants.CHARACTERISTICS.MIGHT
end

--- Sets the test characteristic
--- @param characteristic string One of DTConstants.CHARACTERISTICS values
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetTestCharacteristic(characteristic)
    if self:_isValidTestCharacteristic(characteristic) then
        self.testCharacteristic = characteristic
    end
    return self
end

--- Gets the project goal
--- @return number goal The total project points needed to complete
function DTDowntimeProject:GetProjectGoal()
    return self.projectGoal or 1
end

--- Sets the project goal
--- @param goal number The total project points needed to complete
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetProjectGoal(goal)
    self.projectGoal = math.max(1, math.floor(goal or 1))
    return self
end

--- Gets the status of this project
--- @return string status One of DTConstants.STATUS values
function DTDowntimeProject:GetStatus()
    return self.status or DTConstants.STATUS.ACTIVE
end

--- Sets the status of this project
--- @param status string One of DTConstants.STATUS values
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetStatus(status)
    if self:_isValidStatus(status) then
        self.status = status
    end
    return self
end

--- Gets the status reason
--- @return string reason The status reason
function DTDowntimeProject:GetStatusReason()
    return self.statusReason or ""
end

--- Sets the status reason
--- @param reason string The status reason
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetStatusReason(reason)
    self.statusReason = reason or ""
    return self
end

--- Gets the milestone threshold
--- @return number|nil threshold The milestone threshold or nil if not set
function DTDowntimeProject:GetMilestoneThreshold()
    return self.milestoneThreshold
end

--- Sets the milestone threshold
--- @param threshold number|nil The milestone threshold or nil to clear
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetMilestoneThreshold(threshold)
    if threshold ~= nil then
        self.milestoneThreshold = math.max(0, math.floor(threshold))
    else
        self.milestoneThreshold = nil
    end
    return self
end

--- Gets the earned breakthroughs count
--- @return number breakthroughs The earned breakthroughs count
function DTDowntimeProject:GetEarnedBreakthroughs()
    return self.earnedBreakthroughs or 0
end

--- Sets the earned breakthroughs count
--- @param count number The earned breakthroughs count
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetEarnedBreakthroughs(count)
    self.earnedBreakthroughs = math.max(0, math.floor(count or 0))
    return self
end

--- Gets the pending rolls count
--- @return number rolls The pending rolls count
function DTDowntimeProject:GetPendingRolls()
    return self.pendingRolls or 0
end

--- Sets the pending rolls count
--- @param count number The pending rolls count
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:SetPendingRolls(count)
    self.pendingRolls = math.max(0, math.floor(count or 0))
    return self
end

--- Gets all project rolls
--- @return table projectRolls Array of DTProjectRoll instances
function DTDowntimeProject:GetProjectRolls()
    return self.projectRolls or {}
end

--- Adds a project roll to this project
--- @param roll DTProjectRoll The roll to add
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:AddProjectRoll(roll)
    if not self.projectRolls then
        self.projectRolls = {}
    end
    self.projectRolls[#self.projectRolls + 1] = roll
    return self
end

--- Gets all progress adjustments
--- @return table adjustments Array of DTProgressAdjustment instances
function DTDowntimeProject:GetProgressAdjustments()
    return self.progressAdjustments or {}
end

--- Adds a progress adjustment to this project
--- @param adjustment DTProgressAdjustment The adjustment to add
--- @return DTDowntimeProject self For chaining
function DTDowntimeProject:AddProgressAdjustment(adjustment)
    if not self.progressAdjustments then
        self.progressAdjustments = {}
    end
    self.progressAdjustments[#self.progressAdjustments + 1] = adjustment
    return self
end

--- Gets who created this project
--- @return string createdBy The Codex player ID of the project creator
function DTDowntimeProject:GetCreatedBy()
    return self.createdBy
end

--- Calculates the current progress of this project
--- Sums all project roll results and progress adjustments
--- @return number progress The total progress points earned on this project
function DTDowntimeProject:GetProgress()
    local progress = 0

    -- Add all roll results
    local rolls = self:GetProjectRolls()
    for _, roll in ipairs(rolls) do
        progress = progress + roll:GetModifiedRoll()
    end

    -- Add all progress adjustments
    local adjustments = self:GetProgressAdjustments()
    for _, adjustment in ipairs(adjustments) do
        progress = progress + adjustment:GetAmount()
    end

    return progress
end

--- Validates if the given status is valid for projects
--- @param status string The status to validate
--- @return boolean valid True if the status is valid
function DTDowntimeProject:_isValidStatus(status)
    for _, validStatus in pairs(DTConstants.STATUS) do
        if status == validStatus then
            return true
        end
    end
    return false
end

--- Validates if the given language penalty is valid
--- @param penalty string The language penalty to validate
--- @return boolean valid True if the penalty is valid
function DTDowntimeProject:_isValidLanguagePenalty(penalty)
    for _, validPenalty in pairs(DTConstants.LANGUAGE_PENALTY) do
        if penalty == validPenalty then
            return true
        end
    end
    return false
end

--- Validates if the given test characteristic is valid
--- @param characteristic string The characteristic to validate
--- @return boolean valid True if the characteristic is valid
function DTDowntimeProject:_isValidTestCharacteristic(characteristic)
    for _, validCharacteristic in pairs(DTConstants.CHARACTERISTICS) do
        if characteristic == validCharacteristic then
            return true
        end
    end
    return false
end
