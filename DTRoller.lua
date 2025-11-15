--- Downtime Roller information - abstraction of an entity that can roll on a project
--- @class DTRoller
--- @field name string The name of the roller
--- @field attributes table The list of attributes for the roller as attrId = value
--- @field languages table Flag list of language id's known
--- @field skills table List of skills the roller knows in id,text pairs 
DTRoller = RegisterGameType("DTRoller")
DTRoller.__index = DTRoller

--- Creates a new downtime roller instance
--- @param object character|DTFollower The entity to abstract for the roll
--- @return DTRoller|nil instance The new downtime roller instance
function DTRoller:new(object)
    local instance = setmetatable({}, self)
    local objType = string.lower(object.typeName or "")
    print("THC:: DTROLLER:: LANGS::", json(object:LanguagesKnown()))

    if objType == "character" then
        local token = dmhub.LookupToken(object)
        instance.name = (token.name and #token.name > 0 and token.name) or "(unnamed character)"
        instance.attributes = DTRoller._charAttrsToList(c)
        instance.languages = object:LangagesKnown()
        instance.skills = DTRoller._charSkillsToList(object)
    elseif objType == "dtfollower" or objType == "dtfollowerartisan" or objType == "dtfollowersage" then
        instance.name = object:GetName()
        instance.attributes = object:GetCharacteristics()
        instance.languages = object:GetLanguages()
        instance.skills = DTRoller._followerSkillsToList(object)
    else
        return nil
    end

    return instance
end

--- Return the roller's name
--- @return string name The roller's name
function DTRoller:GetName()
    return self.name
end

--- Return the roller's languages known
--- @return table skills Flag list of languages known
function DTRoller:GetLanguagesKnown()
    return self.languages
end

--- Return the roller's skills known
--- @return table skills The skills known
function DTRoller:GetSkillsKnown()
    return self.skills
end

--- Calcualte the list of attributes given a character
--- @param c character The character
--- @return table attributes List of attributes as attrId = value pairs
function DTRoller._charAttrsToList(c)
    local attrList = {}
    for _, char in ipairs(DTConstants.CHARACTERISTICS) do
        attrList[char.id] = c:GetAttribute(char):Modifier()
    end
    return attrList
end

--- Determine the list of skills given a character
--- @param c character The character
--- @return table skills List of skills the character knows in id,text pairs
function DTRoller._charSkillsToList(c)
    local skillList = {}
    for _, skill in ipairs(Skill.SkillsInfo) do
        if c:ProficientInSkill(skill) then
            skillList[#skillList + 1] = { id = skill.name, text = skill.name}
        end
    end
    return skillList
end

--- Determine the list of skills given a follower
--- @param f DTFollower The follower
--- @return table skills List of skills the follower knows in id,text pairs
function DTRoller._followerSkillsToList(f)
    local skillList = {}
    local skillTable = Skill.SkillsInfo
    for id,_ in pairs(f:GetSkills()) do
        skillList[#skillList + 1] = { id = id, text = skillTable[id].name}
    end
    return skillTable
end