--- Shared constants for the Downtime Projects system
--- Provides centralized constant definitions used across multiple downtime classes
--- @class DTConstants
DTConstants = RegisterGameType("DTConstants")

--- Valid language penalty values used in downtime projects and rolls
DTConstants.LANGUAGE_PENALTY = {
    DTConstant:new("NONE", 1, "None"),
    DTConstant:new("RELATED", 2, "Related"),
    DTConstant:new("UNKNOWN", 3, "Unknown")
}

--- Valid test characteristics used in downtime projects
DTConstants.CHARACTERISTICS = {
    DTConstant:new("MIGHT", 1, "Might"),
    DTConstant:new("AGILITY", 2, "Agility"),
    DTConstant:new("REASON", 3, "Reason"),
    DTConstant:new("INTUITION", 4, "Intuition"),
    DTConstant:new("PRESENCE", 5, "Presence")
}

--- Valid status values for downtime projects
DTConstants.STATUS = {
    DTConstant:new("ACTIVE", 1, "Active"),
    DTConstant:new("PAUSED", 2, "Paused"),
    DTConstant:new("MILESTONE", 3, "Milestone"),
    DTConstant:new("COMPLETE", 4, "Complete")
}

--- Convenience accessors for direct access to specific constants
DTConstants.LANGUAGE_PENALTY.NONE = DTConstants.LANGUAGE_PENALTY[1]
DTConstants.LANGUAGE_PENALTY.RELATED = DTConstants.LANGUAGE_PENALTY[2]
DTConstants.LANGUAGE_PENALTY.UNKNOWN = DTConstants.LANGUAGE_PENALTY[3]

DTConstants.CHARACTERISTICS.MIGHT = DTConstants.CHARACTERISTICS[1]
DTConstants.CHARACTERISTICS.AGILITY = DTConstants.CHARACTERISTICS[2]
DTConstants.CHARACTERISTICS.REASON = DTConstants.CHARACTERISTICS[3]
DTConstants.CHARACTERISTICS.INTUITION = DTConstants.CHARACTERISTICS[4]
DTConstants.CHARACTERISTICS.PRESENCE = DTConstants.CHARACTERISTICS[5]

DTConstants.STATUS.ACTIVE = DTConstants.STATUS[1]
DTConstants.STATUS.PAUSED = DTConstants.STATUS[2]
DTConstants.STATUS.MILESTONE = DTConstants.STATUS[3]
DTConstants.STATUS.COMPLETE = DTConstants.STATUS[4]