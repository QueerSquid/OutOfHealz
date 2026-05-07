print("|cff00ff00OutOfHealz loaded.|r")

local frame = CreateFrame("Frame")

local lastState = nil
local lastCheck = 0
local interval = 1

local function IsHealerInRange()
    local healerInRange = false
    local healerCount = 0

    local function CheckUnit(unit)
        if UnitExists(unit)
            and not UnitIsDeadOrGhost(unit)
            and UnitGroupRolesAssigned(unit) == "HEALER" then

            healerCount = healerCount + 1

            local inRange = CheckInteractDistance(unit, 4)

            if inRange == true then
                 healerInRange = true
            end
        end
    end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            CheckUnit("raid" .. i)
        end
    elseif IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do
            CheckUnit("party" .. i)
        end
    end

    return healerInRange, healerCount
end

frame:SetScript("OnUpdate", function(self, elapsed)
    local now = GetTime()

    if now - lastCheck < interval then
        return
    end

    lastCheck = now

    local inRange, totalHealers = IsHealerInRange()

    local currentState

    if totalHealers == 0 then
        currentState = "NO HEALERS DETECTED"
    elseif inRange then
        currentState = "HEALER IN RANGE"
    else
        currentState = "OUT OF HEAL RANGE"
    end

    if currentState ~= lastState then
        print("|cff00ff00OutOfHealz:|r " .. currentState)
        lastState = currentState
    end
end)
