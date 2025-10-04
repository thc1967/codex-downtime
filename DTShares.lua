--- Project shares manager for downtime system configuration
--- Handles document-based storage of global downtime project shares
--- @class DTShares
--- @field mod table The Codex mod loading instance
--- @field documentName string The name of the document used for project shares storage
DTShares = RegisterGameType("DTShares")
DTShares.__index = DTShares

-- Module-level document monitor for persistence (timing-critical)
local mod = dmhub.GetModLoading()
local documentName = "DTShares"

--- Creates a new project shares manager instance
--- @return DTShares instance The new project shares manager instance
function DTShares:new()
    local instance = setmetatable({}, self)
    instance.mod = mod
    instance.documentName = documentName
    return instance
end

--- Gets the path for document monitoring in UI
--- @return string path The document path for monitoring
function DTShares:GetDocumentPath()
    return self.mod:GetDocumentSnapshot(documentName).path
end

--- Initializes the project shares document with default structure
--- WARNING!!! All data will be lost!
--- @return table doc The initialized document
function DTShares:InitializeDocument()
    local doc = self.mod:GetDocumentSnapshot(self.documentName)
    doc:BeginChange()
    doc.data = {
        senders = {},
        recipients = {},
        modifiedAt = dmhub.serverTime,
    }
    doc:CompleteChange("Initialize downtime project shares", {undoable = false})
    return doc
end

--- Return the projects shared by a token or nil if none
--- @param tokenId string The token for which to get shares
--- @return table|nil projects The list of projects shared by the token
function DTShares:GetSharedBy(tokenId)
    if tokenId == nil or type(tokenId) ~= "string" or #tokenId == 0 then return nil end
    local doc = self:_safeDoc()
    if doc then
        return doc.data.senders[tokenId]
    end
    return nil
end

--- Return the list of projects shared with a token or nil if none
--- @param tokenId string The token for which to get the shares
--- @return table|nil projects The list of projects shared with the token
function DTShares:GetSharedWith(tokenId)
    if tokenId == nil or type(tokenId) ~= "string" or #tokenId == 0 then return nil end
    local doc = self:_safeDoc()
    if doc then
        return doc.data.recipients[tokenId]
    end
    return nil
end

--- Return the list of all shares
--- @return table|nil shares The list of all shares
function DTShares:GetShares()
    local doc = self:_safeDoc()
    if doc then
        return doc.data
    end
    return nil
end

--- Revokes a project share
--- @param sharedBy string VTT Token ID of the character who shared the project
--- @param sharedWith string VTT Token ID of the character who received the project
--- @param projectId string Unique identifier of the project being shared
function DTShares:Revoke(sharedBy, sharedWith, projectId)
    local doc = self:_safeDoc()
    if doc then
        local data = doc.data
        local hasChange = data.senders[sharedBy]
            and data.senders[sharedBy][projectId]
            and data.senders[sharedBy][projectId][sharedWith]
        if hasChange then
            doc:BeginChange()
            data.senders[sharedBy][projectId][sharedWith] = nil
            if next(data.senders[sharedBy][projectId]) == nil then
                data.senders[sharedBy][projectId] = nil
            end
            if next(data.senders[sharedBy]) == nil then
                data.senders[sharedBy] = nil
            end
            data.recipients[sharedWith][projectId] = nil
            if next(data.recipients[sharedWith]) == nil then
                data.recipients[sharedWith] = nil
            end
            doc:CompleteChange("Removed project share", {undoable = false})
        end
    end
end

--- Shares a project
--- @param sharedBy string VTT Token ID of the character sharing the project
--- @param sharedWith string VTT Token ID of the character receiving the project
--- @param projectId string Unique identifier of the project being shared
function DTShares:Share(sharedBy, sharedWith, projectId)
    local doc = self:_safeDoc()
    if doc then
        local data = doc.data
        local hasChange = not data.senders[sharedBy]
            or not data.senders[sharedBy][projectId]
            or not data.senders[sharedBy][projectId][sharedWith]
        if hasChange then
            doc:BeginChange()
            if not data.senders[sharedBy] then
                data.senders[sharedBy] = {}
            end
            if not data.senders[sharedBy][projectId] then
                data.senders[sharedBy][projectId] = {}
            end
            data.senders[sharedBy][projectId][sharedWith] = true
            if not data.recipients[sharedWith] then
                data.recipients[sharedWith] = {}
            end
            data.recipients[sharedWith][projectId] = sharedBy
            doc:CompleteChange("Added project share", {undoable = false})
        end
    end
end

--- Static method to touch the settings document without requiring callers to manage instances
--- Triggers network refresh by updating the modifiedAt timestamp
function DTShares.Touch()
    DTShares:new():TouchDoc()
end

--- Touches the document to trigger network refresh
function DTShares:TouchDoc()
    local doc = self:_safeDoc()
    if doc then
        doc:BeginChange()
        doc.data.modifiedAt = dmhub.serverTime
        doc:CompleteChange("touch timestamp", {undoable = false})
    end
end

--- Initializes the settings document with default structure if it's not already set
--- @return table doc The document
function DTShares:_ensureDocInitialized()
    local doc = self.mod:GetDocumentSnapshot(self.documentName)
    if DTShares._validDoc(doc) then
        return doc
    end
    return self:InitializeDocument()
end

--- Return a document object that is guaranteed to be valid or nil
--- @return table|nil doc The doc if it's valid
function DTShares:_safeDoc()
    local doc = self:_ensureDocInitialized()
    if DTShares._validDoc(doc) then
        return doc
    end
    return nil
end

--- Determine whether the document has the valid / expected structure
--- @param doc table The document to validate
--- @return boolean isValid Whether the document has the expected structure
function DTShares._validDoc(doc)
    local isValid = doc.data and type(doc.data) == "table"
        and doc.data.senders and type(doc.data.senders) == "table"
        and doc.data.recipients and type(doc.data.recipients) == "table"
    return isValid
end

if DTConstants.DEVMODE then
    Commands.thcdtshares = function(args)
        local shares = DTShares:new()
        if shares then
            print("THC:: SHARES::", json(shares:GetShares()))
        end
    end
end
