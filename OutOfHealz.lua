print("|cff00ff00OutOfHealz loaded.|r")

local frame = CreateFrame("Frame")
OutOfHealzDB = OutOfHealzDB or {}

local RangeCheck = LibStub("LibRangeCheck-3.0")

local lastState = nil
local lastCheck = 0
local interval = 0.25

local isFrameUnlocked = false

local cookieSound = "Interface\\AddOns\\OutOfHealz\\Media\\cookie_nom_warning.ogg"
local lastSoundTime = 0
local soundCooldown = 6

local warningFrame = CreateFrame("Frame", "OutOfHealzWarningFrame", UIParent)
warningFrame:SetSize(700, 120)
if OutOfHealzDB.point then
    warningFrame:SetPoint(OutOfHealzDB.point, UIParent, OutOfHealzDB.relativePoint, OutOfHealzDB.xOfs, OutOfHealzDB.yOfs)
else
    warningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
end
warningFrame:SetFrameStrata("FULLSCREEN_DIALOG")
warningFrame:Hide()

local outlineText = warningFrame:CreateFontString(nil, "OVERLAY")
outlineText:SetFont("Fonts\\FRIZQT__.TTF", 68, "OUTLINE")
outlineText:SetPoint("CENTER", warningFrame, "CENTER", 2, -2)
outlineText:SetText("OUT OF HEAL RANGE")
outlineText:SetTextColor(0.6, 0, 0, 0.8)

local warningText = warningFrame:CreateFontString(nil, "OVERLAY")
warningText:SetFont("Fonts\\FRIZQT__.TTF", 68, "OUTLINE")
warningText:SetPoint("CENTER", warningFrame, "CENTER", 0, 0)
warningText:SetText("OUT OF HEAL RANGE")
warningText:SetTextColor(1, 1, 1, 1)

local flashTime = 0

warningFrame:SetScript("OnUpdate", function(self, elapsed)
    flashTime = flashTime + elapsed

    local alpha = (math.sin(flashTime * 10) + 1) / 2
    outlineText:SetAlpha(alpha)
    warningText:SetAlpha(alpha)
end)

warningFrame:SetMovable(true)
warningFrame:EnableMouse(false)
warningFrame:RegisterForDrag("LeftButton")

warningFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

warningFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()

    OutOfHealzDB.point = point
    OutOfHealzDB.relativePoint = relativePoint
    OutOfHealzDB.xOfs = xOfs
    OutOfHealzDB.yOfs = yOfs

    print("|cff00ff00OutOfHealz:|r Frame position saved.")
end)

local function IsHealerInRange()
    local healerInRange = false
    local healerCount = 0

    local function CheckUnit(unit)
        if UnitExists(unit)
            and not UnitIsUnit(unit, "player")
            and not UnitIsDeadOrGhost(unit)
            and UnitGroupRolesAssigned(unit) == "HEALER" then

            healerCount = healerCount + 1

            local minRange, maxRange = RangeCheck:GetRange(unit)
            -- print("Debug:", InCombatLockdown(), unit, UnitName(unit), tostring(inRange))
            -- print("RangeCheck:", unit, minRange, maxRange)

            if maxRange and maxRange <= 40 then
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

    if not InCombatLockdown() then
        if not isFrameUnlocked then
            warningFrame:Hide()
        end
        return
    end

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

        if currentState == "OUT OF HEAL RANGE" then
            warningFrame:Show()
        else
            warningFrame:Hide()
        end

        lastState = currentState
    end

    if currentState == "OUT OF HEAL RANGE" then
        local soundNow = GetTime()

        if soundNow - lastSoundTime >= soundCooldown then
            PlaySoundFile(cookieSound, "Master")
            lastSoundTime = soundNow
        end
    end
end)

SLASH_OUTOFHEALZ1 = "/outofhealz"
SLASH_OUTOFHEALZ2 = "/ooh"

SlashCmdList["OUTOFHEALZ"] = function(msg)
    msg = string.lower(strtrim(msg or ""))

    if msg == "test" then
        warningFrame:Show()
        PlaySoundFile(cookieSound, "Master")
        print("|cff00ff00OutOfHealz:|r Test warning shown.")
    elseif msg == "hide" then
        warningFrame:Hide()
        print("|cff00ff00OutOfHealz:|r Warning hidden.")
    elseif msg == "unlock" then
        isFrameUnlocked = true
        warningFrame:Show()
        warningFrame:EnableMouse(true)
        print("|cff00ff00OutOfHealz:|r Frame unlocked. Drag to move.")
    elseif msg == "lock" then
        isFrameUnlocked = false
        warningFrame:EnableMouse(false)
        warningFrame:Hide()
        print("|cff00ff00OutOfHealz:|r Frame locked.")
    elseif msg == "reset" then
        warningFrame:ClearAllPoints()
        warningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
        print("|cff00ff00OutOfHealz:|r Frame reset to center.")
    else
        print("|cff00ff00OutOfHealz commands:|r")
        print("/ooh test - Show warning and play sound")
        print("/ooh hide - Hide warning")
        print("/ooh unlock - Unlock and move warning frame")
        print("/ooh lock - Lock warning frame")
        print("/ooh reset - Reset warning frame to center")
    end
end