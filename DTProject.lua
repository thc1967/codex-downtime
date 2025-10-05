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
--- @field testCharacteristics {} The list of potential test characteristics for project rolls
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

local DEFAULT_LANG_PENALTY = DTConstants.LANGUAGE_PENALTY.NONE.key
-- local DEFAULT_CHARACTERISTIC = DTConstants.CHARACTERISTICS.REASON.key
local DEFAULT_STATUS = DTConstants.STATUS.PAUSED.key

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
    instance.projectSourceLanguagePenalty = DEFAULT_LANG_PENALTY
    -- instance.testCharacteristic = DEFAULT_CHARACTERISTIC
    instance.testCharacteristics = {}
    instance.projectGoal = 1
    instance.status = DEFAULT_STATUS
    instance.statusReason = "New Project"
    instance.milestoneThreshold = 0
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
    return self.projectSourceLanguagePenalty or DEFAULT_LANG_PENALTY
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
-- function DTProject:GetTestCharacteristic()
--     return self.testCharacteristic or DEFAULT_CHARACTERISTIC
-- end

--- Sets the test characteristic
--- @param characteristic string One of DTConstants.CHARACTERISTICS values
--- @return DTProject self For chaining
-- function DTProject:SetTestCharacteristic(characteristic)
--     if self:_isValidTestCharacteristic(characteristic) then
--         self.testCharacteristic = characteristic
--     end
--     return self
-- end

--- Gets the list of test characteristics for this project
--- Falls back to legacy single characteristic if list is empty/nil
--- @return table characteristics Array of characteristic keys from DTConstants.CHARACTERISTICS
function DTProject:GetTestCharacteristics()
    if self:try_get("testCharacteristics") and #self.testCharacteristics > 0 then
        return self.testCharacteristics
    end

    local legacy = self:try_get("testCharacteristic")
    if legacy and legacy ~= "" then
        local newValue = {legacy}
        
        local current = self:get_or_add("testCharacteristics", newValue)
        current = legacy

        return newValue
    end

    return {}
end

--- Sets the list of test characteristics for this project
--- Validates and filters to only valid characteristics
--- @param characteristics table Array of characteristic keys from DTConstants.CHARACTERISTICS
--- @return DTProject self For chaining
function DTProject:SetTestCharacteristics(characteristics)
    self.testCharacteristics = self:_ensureValidCharacteristics(characteristics)
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
    return self.status or DEFAULT_STATUS
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

--- Returns the number of Breakthroughs rolled against this project
--- @return number breakthroughs
function DTProject:GetBreakthroughRollCount()
    local i = 0
    for _, r in ipairs(self:GetRolls()) do
        if r:GetBreakthrough() then i = i + 1 end
    end
    return i
end

--- Determines whether the project is active / ready to roll
--- @return boolean active True if active
function DTProject:IsActive()
    return self.status == DTConstants.STATUS.ACTIVE.key
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

    if not self:_isValidTestCharacteristics(self:GetTestCharacteristics()) then
        table.insert(reasons, "Test Characteristics are not set or invalid.")
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
function DTProject:GetRoll(rollId)
    if not rollId or type(rollId) ~= "string" or #rollId == 0 then
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
function DTProject:GetRolls()
    return self.projectRolls or {}
end

--- Sets project status before adding or removing a progress item
--- @param item DTRoll|DTAdjustment|DTProgressItem The progress item to be considered
--- @param direction number The direction of progress: 1 if adding, -1 if removing
function DTProject:_setStateFromProgressChange(item, direction)
    if type(direction) ~= "number" or math.abs(direction) ~= 1 then return end

    local function isRoll() return item.typeName == "DTRoll" end
    local function isAdjustment() return item.typeName == "DTAdjustment" end

    -- if isRoll() then
    --     if direction > 0 then -- Adding a roll
    --         if item:GetBreakthrough() then
    --             self:DecrementEarnedBreakthroughs()
    --         end
    --         if item:GetNaturalRoll() >= DTConstants.BREAKTHROUGH_MIN then
    --             self:IncrementEarnedBreakthroughs()
    --         end
    --     else -- Removing a roll
    --         if item:GetBreakthrough() then
    --             self:IncrementEarnedBreakthroughs()
    --         end
    --         -- If the roll we are removing resulted in a breakthrough,
    --         -- we are not going to try to find the breakthrough that was 
    --         -- rolled as a result of that breakthrough. The user will need 
    --         -- to find and delete that as well.
    --     end
    -- end

    local STATUS = DTConstants.STATUS
    local oldValue = self:GetProgress()
    local newValue = oldValue + (direction * item:GetAmount())
    local currentStatus = self:GetStatus()
    local projectGoal = self:GetProjectGoal()
    local milestoneStop = self:GetMilestoneThreshold()

    if newValue >= projectGoal then
        self:SetStatus(DTConstants.STATUS.COMPLETE.key)
            :SetStatusReason("Project complete.")

    elseif currentStatus == DTConstants.STATUS.COMPLETE.key then
        if newValue < projectGoal then
            self:SetStatus(STATUS.ACTIVE.key)
                :SetStatusReason("")
        end
    elseif currentStatus == DTConstants.STATUS.MILESTONE.key then
        if newValue <= self:GetMilestoneThreshold() then
            self:SetStatus(STATUS.ACTIVE.key)
                :SetStatusReason("")
        end
    else -- Active or Paused; same logic
        if milestoneStop > 0 and oldValue < milestoneStop and newValue >= milestoneStop then
            self:SetStatus(STATUS.MILESTONE.key)
                :SetStatusReason("Milestone achieved! Consult with your Director.")
        end
    end
end

--- Adds a project roll to this project
--- **NOTE:** This method automatically calculates status
--- @param roll DTRoll|DTProgressItem The roll to add
--- @return DTProject self For chaining
function DTProject:AddRoll(roll)
    if not self:IsValidStateToRoll() then return self end

    if not self.projectRolls then
        self.projectRolls = {}
    end

    self:_setStateFromProgressChange(roll, 1)
    roll:SetCommitInfo()
    self.projectRolls[#self.projectRolls + 1] = roll

    return self
end

--- Adds several rolls to this project
--- **NOTE:** This method automatically calculates status
--- @param rolls DTRoll[] The rolls to add to the project
--- @return DTProject self For chaining
function DTProject:AddRolls(rolls)
    if rolls and type(rolls) == "table" then
        for _, roll in ipairs(rolls) do
            self:AddRoll(roll)
        end
    end
    return self
end

--- Removes a project roll from this project by ID
--- **NOTE:** This method automatically calculates status
--- @param rollId string The GUID of the roll to remove
--- @return DTProject self For chaining
function DTProject:RemoveRoll(rollId)
    if not self.projectRolls or not rollId then
        return self
    end

    local roll, index = self:GetRoll(rollId)
    if roll then
        self:_setStateFromProgressChange(roll, -1)
        table.remove(self.projectRolls, index)
    end

    return self
end

--- Gets all progress adjustments
--- @return table adjustments Array of DTAdjustment instances
function DTProject:GetAdjustments()
    return self.progressAdjustments or {}
end

--- Adds a progress adjustment to this project
--- **NOTE:** This method automatically calculates status
--- @param adjustment DTAdjustment|DTProgressItem The adjustment to add
--- @return DTProject self For chaining
function DTProject:AddAdjustment(adjustment)
    if not self.progressAdjustments then
        self.progressAdjustments = {}
    end

    self:_setStateFromProgressChange(adjustment, 1)
    adjustment:SetCommitInfo()
    self.progressAdjustments[#self.progressAdjustments + 1] = adjustment
    return self
end

--- Removes a progress adjustment from this project by ID
--- **NOTE:** This method automatically calculates status
--- @param adjustmentId string The GUID of the adjustment to remove
--- @return DTProject self For chaining
function DTProject:RemoveAdjustment(adjustmentId)
    if not self.progressAdjustments or not adjustmentId then
        return self
    end

    for i = #self.progressAdjustments, 1, -1 do
        local adjustment = self.progressAdjustments[i]
        if adjustment and adjustment:GetID() == adjustmentId then
            self:_setStateFromProgressChange(adjustment, -1)
            table.remove(self.progressAdjustments, i)
            break
        end
    end

    return self
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
    local rolls = self:GetRolls()
    for _, roll in ipairs(rolls) do
        progress = progress + roll:GetAmount()
    end

    -- Add all progress adjustments
    local adjustments = self:GetAdjustments()
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
-- function DTProject:_isValidTestCharacteristic(characteristic)
--     for _, validCharacteristic in pairs(DTConstants.CHARACTERISTICS) do
--         if characteristic == validCharacteristic.key then
--             return true
--         end
--     end
--     return false
-- end

--- Validates if the project has at least one valid test characteristic
--- @param characteristics table The characteristics list to validate
--- @return boolean valid True if at least one valid characteristic exists
function DTProject:_isValidTestCharacteristics(characteristics)
    local c = self:_ensureValidCharacteristics(self:GetTestCharacteristics())
    return #c > 0
end

--- Validates and filters a characteristics list to only valid entries
--- @param characteristics table Array of characteristic keys to validate
--- @return table validCharacteristics Filtered array containing only valid characteristic keys
function DTProject:_ensureValidCharacteristics(characteristics)
    local validList = {}

    if type(characteristics) ~= "table" then
        return validList
    end

    for _, char in ipairs(characteristics) do
        for _, validChar in pairs(DTConstants.CHARACTERISTICS) do
            if char == validChar.key then
                table.insert(validList, char)
                break
            end
        end
    end

    return validList
end
