--- Shared constants for the Downtime Projects system
--- Provides centralized constant definitions used across multiple downtime classes
--- @class DTConstants
DTConstants = RegisterGameType("DTConstants")

--- Valid language penalty values used in downtime projects and rolls
DTConstants.LANGUAGE_PENALTY = {
    NONE = "None",
    RELATED = "Related",
    UNKNOWN = "Unknown"
}

--- Valid test characteristics used in downtime projects
DTConstants.CHARACTERISTICS = {
    MIGHT = "Might",
    AGILITY = "Agility",
    REASON = "Reason",
    INTUITION = "Intuition",
    PRESENCE = "Presence"
}

--- Valid status values for downtime projects
DTConstants.STATUS = {
    ACTIVE = "Active",
    PAUSED = "Paused",
    MILESTONE = "Milestone",
    COMPLETE = "Complete"
}