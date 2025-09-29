--- Downtime information manager for a character
--- Manages available rolls and downtime projects for a single character
--- Stored within the character object in the root node named 'downtimeInfo'
--- @class DTInfo
--- @field availableRolls number Counter that the Director increments via Grant Rolls to All
--- @field downtimeProjects table The list of DTProject records for the character
DTInfo = RegisterGameType("DTInfo")
DTInfo.__index = DTInfo

--- Creates a new downtime info instance
--- @return DTInfo instance The new downtime info instance
function DTInfo:new()
    local instance = setmetatable({}, self)

    instance.availableRolls = 0
    instance.downtimeProjects = {}

    return instance
end

--- Gets the number of available rolls
--- @return number availableRolls The number of available rolls
function DTInfo:GetAvailableRolls()
    return self.availableRolls or 0
end

--- Sets the number of available rolls
--- @param rolls number The new number of available rolls
--- @return DTInfo self For chaining
function DTInfo:SetAvailableRolls(rolls)
    self.availableRolls = math.max(0, math.floor(rolls or 0))
    return self
end

--- Modifies the available rolls counter
--- @param rolls number The number of rolls to add
--- @return DTInfo self For chaining
function DTInfo:GrantRolls(rolls)
    self.availableRolls = math.max(0, (self.availableRolls or 0) + (rolls or 0))
    return self
end

--- Uses available rolls (decrements counter)
--- @param rolls number The number of rolls to use
--- @return DTInfo self For chaining
function DTInfo:UseAvailableRolls(rolls)
    local useCount = math.max(0, math.floor(rolls or 0))
    self.availableRolls = math.max(0, (self.availableRolls or 0) - useCount)
    return self
end

--- Gets all downtime projects for this character
--- @return table downtimeProjects Hash table of DTProject instances keyed by GUID
function DTInfo:GetDowntimeProjects()
    return self.downtimeProjects or {}
end

--- Gets all downtime projects sorted by sort order
--- @return table projectsArray Array of DTProject instances sorted by sortOrder
function DTInfo:GetSortedProjects()
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
--- @return DTProject|nil The project referenced by the key or nil if it doesn't exist
function DTInfo:GetDowntimeProject(projectId)
    return self.downtimeProjects[projectId or ""]
end

--- Adds a new downtime project to this character
--- @param project? DTProject The project to add or nil if we're creating a new one
--- @return DTProject project The newly created project
function DTInfo:AddDowntimeProject(project)
    if project == nil or type(project) ~= table then
        local nextOrder = self:_maxProjectOrder() + 1
        project = DTProject:new(nextOrder)
    end
    self.downtimeProjects[project:GetID()] = project
    return project
end

--- Removes a downtime project from this character
--- @param projectId string The GUID of the project to remove
--- @return DTInfo self For chaining
function DTInfo:RemoveDowntimeProject(projectId)
    if self.downtimeProjects[projectId] then
        self.downtimeProjects[projectId] = nil
    end
    return self
end

--- Gets the highest sort order number among all projects for this character
--- @return number maxOrder The highest sort order number, or 0 if no projects exist
--- @private
function DTInfo:_maxProjectOrder()
    local maxOrder = 0

    for _, project in pairs(self.downtimeProjects or {}) do
        local order = project:GetSortOrder()
        if order > maxOrder then
            maxOrder = order
        end
    end

    return maxOrder
end
