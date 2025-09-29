--- Progress adjustment record for tracking manual adjustments to downtime project progress
--- Records manual progress changes made by directors or players with reasoning
--- @class DTProgressAdjustment
--- @field id string GUID identifier for this adjustment
--- @field amount number Progress points to add (negative to subtract)
--- @field reason string Required. The reason for the adjustment
--- @field timestamp string|osdate When the adjustment was created
--- @field createdBy string User ID of the user who made the adjustment
--- @field serverTime number|nil Unity server time when adjustment was committed
DTProgressAdjustment = RegisterGameType("DTProgressAdjustment")
DTProgressAdjustment.__index = DTProgressAdjustment

--- Creates a new progress adjustment instance
--- @param amount number Progress points to add (negative to subtract)
--- @param reason string The reason for the adjustment
--- @return DTProgressAdjustment instance The new progress adjustment instance
function DTProgressAdjustment:new(amount, reason)
    local instance = setmetatable({}, self)

    instance.id = dmhub.GenerateGuid()
    instance.amount = math.floor(amount or 0)
    instance.reason = reason or ""
    instance.timestamp = ""
    instance.createdBy = ""
    instance.serverTime = 0

    return instance
end

--- Gets the identifier of this adjustment
--- @return string id GUID id of this adjustment
function DTProgressAdjustment:GetID()
    return self.id
end

--- Gets the adjustment amount
--- @return number amount Progress points to add (negative to subtract)
function DTProgressAdjustment:GetAmount()
    return self.amount or 0
end

--- Sets the adjustment amount
--- @param amount number Progress points to add (negative to subtract)
--- @return DTProgressAdjustment self For chaining
function DTProgressAdjustment:SetAmount(amount)
    self.amount = math.floor(amount or 0)
    return self
end

--- Gets the reason for the adjustment
--- @return string reason The reason for the adjustment
function DTProgressAdjustment:GetReason()
    return self.reason or ""
end

--- Sets the reason for the adjustment
--- @param reason string The reason for the adjustment
--- @return DTProgressAdjustment self For chaining
function DTProgressAdjustment:SetReason(reason)
    self.reason = reason or ""
    return self
end

--- Gets when this adjustment was created
--- @return string|osdate timestamp ISO 8601 UTC timestamp
function DTProgressAdjustment:GetTimestamp()
    return self.timestamp
end

--- Gets who created this adjustment
--- @return string createdBy The Codex player ID of the adjustment creator
function DTProgressAdjustment:GetCreatedBy()
    return self.createdBy
end

--- Sets all commit information when adjustment is saved to project
--- @return DTProgressAdjustment self For chaining
function DTProgressAdjustment:SetCommitInfo()
    self.serverTime = dmhub.serverTime
    self.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    self.createdBy = dmhub.userid
    return self
end

--- Gets the server time when adjustment was committed
--- @return number|nil serverTime Unity server time or nil if not committed
function DTProgressAdjustment:GetServerTime()
    return self.serverTime
end
