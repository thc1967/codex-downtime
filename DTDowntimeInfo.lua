--- Downtime information manager for a character
--- Manages available rolls and downtime projects for a single character
--- Stored within the character object in the root node named 'downtime_info'
--- @class DTDowntimeInfo
--- @field availableRolls number Counter that the Director increments via Grant Rolls to All
--- @field downtimeProjects table The list of DTDowntimeProject records for the character
DTDowntimeInfo = RegisterGameType("DTDowntimeInfo")
DTDowntimeInfo.__index = DTDowntimeInfo

--- Creates a new downtime info instance
--- @return DTDowntimeInfo instance The new downtime info instance
function DTDowntimeInfo:new()
    local instance = setmetatable({}, self)

    instance.availableRolls = 0
    instance.downtimeProjects = {}

    return instance
end

--- Gets the number of available rolls
--- @return number availableRolls The number of available rolls
function DTDowntimeInfo:GetAvailableRolls()
    return self.availableRolls or 0
end

--- Sets the number of available rolls
--- @param rolls number The new number of available rolls
--- @return DTDowntimeInfo self For chaining
function DTDowntimeInfo:SetAvailableRolls(rolls)
    self.availableRolls = math.max(0, math.floor(rolls or 0))
    return self
end

--- Adds to the available rolls counter
--- @param rolls number The number of rolls to add
--- @return DTDowntimeInfo self For chaining
function DTDowntimeInfo:AddAvailableRolls(rolls)
    self.availableRolls = (self.availableRolls or 0) + math.max(0, math.floor(rolls or 0))
    return self
end

--- Uses available rolls (decrements counter)
--- @param rolls number The number of rolls to use
--- @return DTDowntimeInfo self For chaining
function DTDowntimeInfo:UseAvailableRolls(rolls)
    local useCount = math.max(0, math.floor(rolls or 0))
    self.availableRolls = math.max(0, (self.availableRolls or 0) - useCount)
    return self
end

--- Gets all downtime projects for this character
--- @return table downtimeProjects Hash table of DTDowntimeProject instances keyed by GUID
function DTDowntimeInfo:GetDowntimeProjects()
    return self.downtimeProjects or {}
end

--- Gets all downtime projects sorted by sort order
--- @return table projectsArray Array of DTDowntimeProject instances sorted by sortOrder
function DTDowntimeInfo:GetSortedProjects()
    -- Convert hash table to array
    local projectsArray = {}
    for _, project in pairs(self.downtimeProjects or {}) do
        projectsArray[#projectsArray + 1] = project
    end

    -- Sort the array
    table.sort(projectsArray, function(a, b)
        return a:GetSortOrder() < b:GetSortOrder()
    end)

    return projectsArray
end

--- Returns the project matching the key or nil if not found
--- @param projectId string The GUID identifier of the project to return
--- @return DTDowntimeProject|nil The project referenced by the key or nil if it doesn't exist
function DTDowntimeInfo:GetDowntimeProject(projectId)
    return self.downtimeProjects[projectId or ""]
end

--- Adds a new downtime project to this character
--- @param project? DTDowntimeProject The project to add or nil if we're creating a new one
--- @return DTDowntimeProject project The newly created project
function DTDowntimeInfo:AddDowntimeProject(project)
    if project == nil or type(project) ~= table then
        local nextOrder = self:_maxProjectOrder() + 1
        project = DTDowntimeProject:new(nextOrder)
    end
    self.downtimeProjects[project:GetID()] = project
    return project
end

--- Removes a downtime project from this character
--- @param projectId string The GUID of the project to remove
--- @return DTDowntimeInfo self For chaining
function DTDowntimeInfo:RemoveDowntimeProject(projectId)
    if self.downtimeProjects[projectId] then
        self.downtimeProjects[projectId] = nil
    end
    return self
end

--- Gets the total number of staged rolls across all non-completed projects
--- @return number stagedRolls The total count of staged rolls for active projects
function DTDowntimeInfo:GetStagedRollsCount()
    local totalStagedRolls = 0

    for _, project in pairs(self:GetDowntimeProjects()) do
        if project:GetStatus() ~= DTConstants.STATUS.COMPLETE then
            totalStagedRolls = totalStagedRolls + project:GetPendingRolls()
        end
    end

    return totalStagedRolls
end

--- Gets the highest sort order number among all projects for this character
--- @return number maxOrder The highest sort order number, or 0 if no projects exist
--- @private
function DTDowntimeInfo:_maxProjectOrder()
    local maxOrder = 0

    for _, project in pairs(self.downtimeProjects or {}) do
        local order = project:GetSortOrder()
        if order > maxOrder then
            maxOrder = order
        end
    end

    return maxOrder
end
