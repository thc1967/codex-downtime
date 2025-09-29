--- Downtime project containing all project data and progress tracking
--- Represents a complete downtime project with status tracking, rolls, and adjustments
--- @class DTProject
--- @field id string GUID identifier for this project
--- @field sortOrder number The sort order for this objective
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
--- @field projectRolls table Array of DTRoll objects - History of all rolls made on this project
--- @field progressAdjustments table Array of DTAdjustment objects - History of all adjustments made to project progress
--- @field createdBy string GUID identifier of the user who created this project
DTProject = RegisterGameType("DTProject")
DTProject.__index = DTProject


--- Creates a new downtime project instance
--- @param sortOrder number The sort order for this project
--- @return DTProject instance The new project instance
function DTProject:new(sortOrder)
    local instance = setmetatable({}, self)

    instance.id = dmhub.GenerateGuid()
    instance.sortOrder = sortOrder or 1
    instance.title = ""
    instance.itemPrerequisite = ""
    instance.projectSource = ""
    instance.projectSourceLanguagePenalty = DTConstants.LANGUAGE_PENALTY.NONE.key
    instance.testCharacteristic = DTConstants.CHARACTERISTICS.REASON.key
    instance.projectGoal = 1
    instance.status = DTConstants.STATUS.PAUSED.key
    instance.statusReason = "New Project"
    instance.milestoneThreshold = 0
    instance.earnedBreakthroughs = 0
    instance.projectRolls = {}
    instance.progressAdjustments = {}
    instance.createdBy = dmhub.userid

    return instance
end

--- Gets the identifier of this project
--- @return string id GUID id of this project
function DTProject:GetID()
    return self.id
end

--- Gets the title of this project
--- @return string title The project title
function DTProject:GetTitle()
    return self.title or ""
end

--- Sets the title of this project
--- @param title string The new title for the project
--- @return DTProject self For chaining
function DTProject:SetTitle(title)
    self.title = title or ""
    return self
end

--- Gets the item prerequisite for this project
--- @return string itemPrerequisite The item prerequisite
function DTProject:GetItemPrerequisite()
    return self.itemPrerequisite or ""
end

--- Sets the item prerequisite for this project
--- @param prerequisite string The item prerequisite
--- @return DTProject self For chaining
function DTProject:SetItemPrerequisite(prerequisite)
    self.itemPrerequisite = prerequisite or ""
    return self
end

--- Gets the project source
--- @return string projectSource The project source
function DTProject:GetProjectSource()
    return self.projectSource or ""
end

--- Sets the project source
--- @param source string The project source
--- @return DTProject self For chaining
function DTProject:SetProjectSource(source)
    self.projectSource = source or ""
    return self
end

--- Gets the project source language penalty
--- @return string languagePenalty One of DTConstants.LANGUAGE_PENALTY values
function DTProject:GetProjectSourceLanguagePenalty()
    return self.projectSourceLanguagePenalty or DTConstants.LANGUAGE_PENALTY.NONE.key
end

--- Sets the project source language penalty
--- @param penalty string One of DTConstants.LANGUAGE_PENALTY values
--- @return DTProject self For chaining
function DTProject:SetProjectSourceLanguagePenalty(penalty)
    if self:_isValidLanguagePenalty(penalty) then
        self.projectSourceLanguagePenalty = penalty
    end
    return self
end

--- Gets the test characteristic
--- @return string characteristic One of DTConstants.CHARACTERISTICS values
function DTProject:GetTestCharacteristic()
    return self.testCharacteristic or DTConstants.CHARACTERISTICS.REASON.key
end

--- Sets the test characteristic
--- @param characteristic string One of DTConstants.CHARACTERISTICS values
--- @return DTProject self For chaining
function DTProject:SetTestCharacteristic(characteristic)
    if self:_isValidTestCharacteristic(characteristic) then
        self.testCharacteristic = characteristic
    end
    return self
end

--- Gets the project goal
--- @return number goal The total project points needed to complete
function DTProject:GetProjectGoal()
    return self.projectGoal or 1
end

--- Sets the project goal
--- @param goal number The total project points needed to complete
--- @return DTProject self For chaining
function DTProject:SetProjectGoal(goal)
    self.projectGoal = math.max(1, math.floor(goal or 1))
    return self
end

--- Gets the status of this project
--- @return string status One of DTConstants.STATUS values
function DTProject:GetStatus()
    return self.status or DTConstants.STATUS.ACTIVE.key
end

--- Sets the status of this project
--- @param status string One of DTConstants.STATUS values
--- @return DTProject self For chaining
function DTProject:SetStatus(status)
    if self:_isValidStatus(status) then
        self.status = status
    end
    return self
end

--- Gets the status reason
--- @return string reason The status reason
function DTProject:GetStatusReason()
    return self.statusReason or ""
end

--- Sets the status reason
--- @param reason string The status reason
--- @return DTProject self For chaining
function DTProject:SetStatusReason(reason)
    self.statusReason = reason or ""
    return self
end

--- Gets the milestone threshold
--- @return number|nil threshold The milestone threshold or nil if not set
function DTProject:GetMilestoneThreshold()
    return self.milestoneThreshold
end

--- Sets the milestone threshold
--- @param threshold number|nil The milestone threshold or nil to clear
--- @return DTProject self For chaining
function DTProject:SetMilestoneThreshold(threshold)
    if threshold ~= nil then
        self.milestoneThreshold = math.max(0, math.floor(threshold))
    else
        self.milestoneThreshold = 0
    end
    return self
end

--- Increments the earned breakthroughs count
--- @return DTProject self For chaining
function DTProject:IncrementEarnedBreakthroughs()
    self.earnedBreakthroughs = self.earnedBreakthroughs + 1
    return self
end

--- Decrements the earned breakthroughs count
--- @return DTProject self For chaining
function DTProject:DecrementEarnedBreakthroughs()
    self.earnedBreakthroughs = math.max(0, self.earnedBreakthroughs - 1)
    return self
end

--- Gets the earned breakthroughs count
--- @return number breakthroughs The earned breakthroughs count
function DTProject:GetEarnedBreakthroughs()
    return self.earnedBreakthroughs or 0
end

--- Sets the earned breakthroughs count
--- @param count number The earned breakthroughs count
--- @return DTProject self For chaining
function DTProject:SetEarnedBreakthroughs(count)
    self.earnedBreakthroughs = math.max(0, math.floor(count or 0))
    return self
end

--- Determines whether this project is in a valid state to roll
--- @return boolean valid True if the project is in a valid state to roll
--- @return table|nil reasons If the state is invalid, the list of reasons it's invalid
function DTProject:IsValidStateToRoll()
    local isValid = true
    local reasons = {}

    if self:GetStatus() ~= DTConstants.STATUS.ACTIVE.key then
        table.insert(reasons, string.format("Project status is not %s.", DTConstants.STATUS.ACTIVE.displayText))
        isValid = false
    end

    if not self:_isValidLanguagePenalty(self:GetProjectSourceLanguagePenalty()) then
        table.insert(reasons, "Source Language Penalty not set or invalid.")
        isValid = false
    end

    if not self:_isValidTestCharacteristic(self:GetTestCharacteristic()) then
        table.insert(reasons, "Test Characteristic is not set or invalid.")
        isValid = false
    end

    if self:GetProjectGoal() <= 0 then
        table.insert(reasons, "Project Goal is not set or is zero.")
        isValid = false
    else
        if self:GetProgress() >= self:GetProjectGoal() then
            table.insert(reasons, "Progress already equals or exceeds goal.")
            isValid = false
        end
    end

    return isValid, #reasons and reasons or nil
end

--- Gets a specific project roll
--- @param rollId string GUID ID of the roll to find
--- @return DTRoll|nil roll The roll object or nil if not found
--- @return number|nil index The index of the roll in the projectRolls table or nil if not found
function DTProject:GetProjectRoll(rollId)
    if not rollId or type(rollId) ~= string or #rollId == 0 then
        return nil, nil
    end

    for i = #self.projectRolls, 1, -1 do
        local roll = self.projectRolls[i]
        if roll and roll:GetID() == rollId then
            return self.projectRolls[i], i
        end
    end

    return nil, nil
end

--- Gets all project rolls
--- @return table projectRolls Array of DTRoll instances
function DTProject:GetProjectRolls()
    return self.projectRolls or {}
end

--- Sets project status before adding or removing a roll
--- @param roll DTRoll The roll to be considered
--- @param direction number The direction of the roll: 1 if adding, -1 if removing
function DTProject:_setStateFromRollChange(roll, direction)
    if type(direction) ~= "number" or math.abs(direction) ~= 1 then return end

    local STATUS = DTConstants.STATUS
    local oldValue = self:GetProgress()
    local newValue = oldValue + (direction * roll:GetTotalRoll())
    if direction == 1 then -- Adding the roll

        if roll:GetBreakthrough() then
            self:DecrementEarnedBreakthroughs()
        end

        if roll:GetNaturalRoll() >= DTConstants.BREAKTHROUGH_MIN then
            self:IncrementEarnedBreakthroughs()
        end

        if newValue >= self:GetProjectGoal() then
            self:SetStatus(STATUS.COMPLETE.key)
        else
            local milestoneStop = self:GetMilestoneThreshold()
            if milestoneStop > 0 and newValue > milestoneStop and oldValue < milestoneStop then
                self:SetStatus(STATUS.MILESTONE.key)
                    :SetStatusReason("Achieved milestone! Consult with your Director.")
            end
        end
    else -- Removing the roll
        if roll:GetBreakthrough() then
            self:IncrementEarnedBreakthroughs()
        end

        -- If the roll we are removing resulted in a breakthrough, we
        -- are not going to try to find the breakthrough that was rolled
        -- as a result of that breakthrough. The user will need to find
        -- and delete that as well.

        local currentStatus = self:GetStatus()
        if currentStatus == STATUS.COMPLETE.key then
            if newValue < self:GetProjectGoal() then
                self:SetStatus(STATUS.ACTIVE.key)
            end
        else
            if currentStatus == STATUS.MILESTONE.key then
                local milestoneStop = self:GetMilestoneThreshold()
                if oldValue > milestoneStop and newValue < milestoneStop then
                    self:SetStatus(STATUS.ACTIVE.key)
                        :SetStatusReason("")
                end
            end
        end
    end
end

--- Adds a project roll to this project
--- **NOTE:** This method automatically calculates status
--- @param roll DTRoll The roll to add
--- @return DTProject self For chaining
function DTProject:AddProjectRoll(roll)
    if not self:IsValidStateToRoll() then return self end

    if not self.projectRolls then
        self.projectRolls = {}
    end

    self:_setStateFromRollChange(roll, 1)
    roll:SetCommitInfo()
    self.projectRolls[#self.projectRolls + 1] = roll

    return self
end

--- Removes a project roll from this project by ID
--- **NOTE:** This method automatically calculates status
--- @param rollId string The GUID of the roll to remove
--- @return DTProject self For chaining
function DTProject:RemoveProjectRoll(rollId)
    if not self.projectRolls or not rollId then
        return self
    end

    local roll, index = self:GetProjectRoll(rollId)
    if roll then
        self:_setStateFromRollChange(roll, -1)
        table.remove(self.projectRolls, index)
    end

    return self
end

--- Gets all progress adjustments
--- @return table adjustments Array of DTAdjustment instances
function DTProject:GetProgressAdjustments()
    return self.progressAdjustments or {}
end

--- Adds a progress adjustment to this project
--- **NOTE:** This method automatically calculates status
--- @param adjustment DTAdjustment The adjustment to add
--- @return DTProject self For chaining
function DTProject:AddProgressAdjustment(adjustment)
    if not self.progressAdjustments then
        self.progressAdjustments = {}
    end

    adjustment:SetCommitInfo()
    self.progressAdjustments[#self.progressAdjustments + 1] = adjustment
    return self
end

--- Removes a progress adjustment from this project by ID
--- **NOTE:** This method automatically calculates status
--- @param adjustmentId string The GUID of the adjustment to remove
--- @return DTProject self For chaining
function DTProject:RemoveProgressAdjustment(adjustmentId)
    if not self.progressAdjustments or not adjustmentId then
        return self
    end

    for i = #self.progressAdjustments, 1, -1 do
        local adjustment = self.progressAdjustments[i]
        if adjustment and adjustment:GetID() == adjustmentId then
            table.remove(self.progressAdjustments, i)
            break
        end
    end

    return self
end

--- Gets who created this project
--- @return string createdBy The Codex player ID of the project creator
function DTProject:GetCreatedBy()
    return self.createdBy
end

--- Gets the sort order of this project
--- @return number sortOrder The sort order position
function DTProject:GetSortOrder()
    return self.sortOrder or 1
end

--- Sets the sort order of this project
--- @param sortOrder number The new sort order position
--- @return DTProject self For chaining
function DTProject:SetSortOrder(sortOrder)
    self.sortOrder = sortOrder or 1
    return self
end

--- Calculates the current progress of this project
--- Sums all project roll results and progress adjustments
--- **NOTE:** This operation iterates two tables and can be expensive.
--- @return number progress The total progress points earned on this project
function DTProject:GetProgress()
    local progress = 0

    -- Add all roll results
    local rolls = self:GetProjectRolls()
    for _, roll in ipairs(rolls) do
        progress = progress + roll:GetTotalRoll()
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
function DTProject:_isValidStatus(status)
    for _, validStatus in pairs(DTConstants.STATUS) do
        if status == validStatus.key then
            return true
        end
    end
    return false
end

--- Validates if the given language penalty is valid
--- @param penalty string The language penalty to validate
--- @return boolean valid True if the penalty is valid
function DTProject:_isValidLanguagePenalty(penalty)
    for _, validPenalty in pairs(DTConstants.LANGUAGE_PENALTY) do
        if penalty == validPenalty.key then
            return true
        end
    end
    return false
end

--- Validates if the given test characteristic is valid
--- @param characteristic string The characteristic to validate
--- @return boolean valid True if the characteristic is valid
function DTProject:_isValidTestCharacteristic(characteristic)
    for _, validCharacteristic in pairs(DTConstants.CHARACTERISTICS) do
        if characteristic == validCharacteristic.key then
            return true
        end
    end
    return false
end
