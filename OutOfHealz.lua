--------------------------------------------------
-- OutOfHealz Core
--------------------------------------------------

print("|cff00ff00OutOfHealz loaded.|r")

local frame = CreateFrame("Frame")

--------------------------------------------------
-- Saved Variables
--------------------------------------------------

OutOfHealzDB = OutOfHealzDB or {}

if OutOfHealzDB.instanceOnly == nil then
    OutOfHealzDB.instanceOnly = true
end

if OutOfHealzDB.soundEnabled == nil then
    OutOfHealzDB.soundEnabled = true
end

if OutOfHealzDB.pvpEnabled == nil then
    OutOfHealzDB.pvpEnabled = false
end

if OutOfHealzDB.warningScale == nil then
    OutOfHealzDB.warningScale = 1
end

if OutOfHealzDB.healthWarningEnabled == nil then
    OutOfHealzDB.healthWarningEnabled = true
end

if OutOfHealzDB.healthThreshold == nil then
    OutOfHealzDB.healthThreshold = 35
end

if OutOfHealzDB.healthPoint == nil then
    OutOfHealzDB.healthPoint = "CENTER"
end

if OutOfHealzDB.healthRelativePoint == nil then
    OutOfHealzDB.healthRelativePoint = "CENTER"
end

if OutOfHealzDB.healthXOfs == nil then
    OutOfHealzDB.healthXOfs = 0
end

if OutOfHealzDB.healthYOfs == nil then
    OutOfHealzDB.healthYOfs = 90
end

--------------------------------------------------
-- Libraries
--------------------------------------------------

local RangeCheck = LibStub("LibRangeCheck-3.0")

--------------------------------------------------
-- State Variables
--------------------------------------------------

local lastState = nil
local lastCheck = 0
local interval = 0.25

local outOfRangeStartTime = nil
local stageThreeTriggered = false

local isFrameUnlocked = false

local cookieSound = "Interface\\AddOns\\OutOfHealz\\Media\\cookie_nom_warning.ogg"
local dangerSound = "Interface\\AddOns\\OutOfHealz\\Media\\Get_Over_Here.ogg"
local lastSoundTime = 0
local soundCooldown = 6

--------------------------------------------------
-- Warning Frame
--------------------------------------------------

local warningFrame = CreateFrame("Frame", "OutOfHealzWarningFrame", UIParent)
warningFrame:SetSize(900, 120)
warningFrame:SetScale(OutOfHealzDB.warningScale or 1)
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

--------------------------------------------------
-- Health Warning Frame
--------------------------------------------------

local healthWarningFrame = CreateFrame("Frame", "OutOfHealzHealthWarningFrame", UIParent)
healthWarningFrame:SetSize(900, 120)
healthWarningFrame:SetScale(OutOfHealzDB.warningScale or 1)
healthWarningFrame:SetPoint(
    OutOfHealzDB.healthPoint or "CENTER",
    UIParent,
    OutOfHealzDB.healthRelativePoint or "CENTER",
    OutOfHealzDB.healthXOfs or 0,
    OutOfHealzDB.healthYOfs or 90
)
healthWarningFrame:SetFrameStrata("FULLSCREEN_DIALOG")
healthWarningFrame:Hide()

local healthOutlineText = healthWarningFrame:CreateFontString(nil, "OVERLAY")
healthOutlineText:SetFont("Fonts\\FRIZQT__.TTF", 68, "OUTLINE")
healthOutlineText:SetPoint("CENTER", healthWarningFrame, "CENTER", 2, -2)
healthOutlineText:SetText("LOW HEALTH")
healthOutlineText:SetTextColor(0.6, 0, 0, 0.8)

local healthWarningText = healthWarningFrame:CreateFontString(nil, "OVERLAY")
healthWarningText:SetFont("Fonts\\FRIZQT__.TTF", 68, "OUTLINE")
healthWarningText:SetPoint("CENTER", healthWarningFrame, "CENTER", 0, 0)
healthWarningText:SetText("LOW HEALTH")
healthWarningText:SetTextColor(1, 1, 1, 1)

local healthFlashTime = 0

healthWarningFrame:SetScript("OnUpdate", function(self, elapsed)
    healthFlashTime = healthFlashTime + elapsed

    local alpha = (math.sin(healthFlashTime * 10) + 1) / 2
    healthOutlineText:SetAlpha(alpha)
    healthWarningText:SetAlpha(alpha)
end)

--------------------------------------------------
-- Helper Functions
--------------------------------------------------

local function ResetWarningState()
    outOfRangeStartTime = nil
    stageThreeTriggered = false
    outlineText:SetText("OUT OF HEAL RANGE")
    warningText:SetText("OUT OF HEAL RANGE")
end

local healthThresholdCurve = nil
local healthThresholdCurveValue = nil

local function GetHealthThresholdCurve()
    local threshold = OutOfHealzDB.healthThreshold or 35

    if healthThresholdCurve and healthThresholdCurveValue == threshold then
        return healthThresholdCurve
    end

    healthThresholdCurveValue = threshold

    local thresholdFraction = threshold / 100

    healthThresholdCurve = C_CurveUtil.CreateColorCurve()
    healthThresholdCurve:SetType(Enum.LuaCurveType.Linear)

    -- Visible at or below the configured threshold.
    healthThresholdCurve:AddPoint(
        0,
        CreateColor(1, 1, 1, 1)
    )

    -- Remain visible through the configured threshold.
    healthThresholdCurve:AddPoint(
        thresholdFraction,
        CreateColor(1, 1, 1, 1)
    )

    -- Immediately hide once health rises above the threshold.
        healthThresholdCurve:AddPoint(
        math.min(thresholdFraction + 0.0001, 1),
        CreateColor(1, 1, 1, 0)
    )

    return healthThresholdCurve
end

local function IsHealthWarningAllowed()
    if not OutOfHealzDB.healthWarningEnabled then
        return false
    end

    if not InCombatLockdown() then
        return false
    end

    if OutOfHealzDB.instanceOnly then
        local inInstance, instanceType = IsInInstance()

        if not inInstance or (instanceType ~= "party" and instanceType ~= "raid") then
            return false
        end
    end

    return true
end

local function UpdateHealthWarning()
    if not IsHealthWarningAllowed() then
        healthWarningFrame:Hide()
        healthWarningFrame:SetAlpha(1)
        return
    end

    local curve = GetHealthThresholdCurve()

    local color = UnitHealthPercent(
        "player",
        true,
        curve
    )

    healthWarningFrame:Show()

    healthWarningFrame:SetAlpha(
        select(4, color:GetRGBA())
    )
end

OutOfHealz_UpdateHealthWarning = UpdateHealthWarning

warningFrame:SetScript("OnUpdate", function(self, elapsed)
    flashTime = flashTime + elapsed

    local alpha = (math.sin(flashTime * 10) + 1) / 2
    outlineText:SetAlpha(alpha)
    warningText:SetAlpha(alpha)
end)

--------------------------------------------------
-- Warning Frame Movement
--------------------------------------------------

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

healthWarningFrame:SetMovable(true)
healthWarningFrame:EnableMouse(false)
healthWarningFrame:RegisterForDrag("LeftButton")

healthWarningFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

healthWarningFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()

    OutOfHealzDB.healthPoint = point
    OutOfHealzDB.healthRelativePoint = relativePoint
    OutOfHealzDB.healthXOfs = xOfs
    OutOfHealzDB.healthYOfs = yOfs

    print("|cff00ff00OutOfHealz:|r Health warning position saved.")
end)

--------------------------------------------------
-- Healer Detection
--------------------------------------------------

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

--------------------------------------------------
-- Health Detection
--------------------------------------------------

local healthEventFrame = CreateFrame("Frame")

healthEventFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
healthEventFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
healthEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
healthEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
healthEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
healthEventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

healthEventFrame:SetScript("OnEvent", function(self, event, unit)
    if unit and unit ~= "player" then
        return
    end

    UpdateHealthWarning()
end)

--------------------------------------------------
-- Core Detection Logic
--------------------------------------------------

frame:SetScript("OnUpdate", function(self, elapsed)
    local now = GetTime()

    if now - lastCheck < interval then
        return
    end

    lastCheck = now

    if not InCombatLockdown() then
        ResetWarningState()

        if not isFrameUnlocked then
            warningFrame:Hide()
        end

        return
    end

    if OutOfHealzDB.instanceOnly then
        local inInstance, instanceType = IsInInstance()

        if not inInstance or (instanceType ~= "party" and instanceType ~= "raid") then
            if not isFrameUnlocked then
                warningFrame:Hide()
            end
            return
        end
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

    if currentState == "OUT OF HEAL RANGE" then
        if not outOfRangeStartTime then
            outOfRangeStartTime = GetTime()
        end

        local outTime = GetTime() - outOfRangeStartTime
        local warningMessage = "OUT OF HEAL RANGE"

        if outTime >= 12 then
            warningMessage = "IF YOU DIE, IT'S YOUR FAULT"
            stageThreeTriggered = true

        elseif outTime >= 6 then
            warningMessage = "STILL OUT OF HEAL RANGE"
        end

        outlineText:SetText(warningMessage)
        warningText:SetText(warningMessage)
    else
        outOfRangeStartTime = nil
        stageThreeTriggered = false

        outlineText:SetText("OUT OF HEAL RANGE")
        warningText:SetText("OUT OF HEAL RANGE")
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

    if currentState == "OUT OF HEAL RANGE" and OutOfHealzDB.soundEnabled then
        local soundNow = GetTime()

        if soundNow - lastSoundTime >= soundCooldown then
            if stageThreeTriggered then
                PlaySoundFile(dangerSound, "Master")
            else
                PlaySoundFile(cookieSound, "Master")
            end

            lastSoundTime = soundNow
        end
    end
end)

--------------------------------------------------
-- Slash Commands
--------------------------------------------------

SLASH_OUTOFHEALZ1 = "/outofhealz"
SLASH_OUTOFHEALZ2 = "/ooh"

SlashCmdList["OUTOFHEALZ"] = function(msg)
    msg = string.lower(strtrim(msg or ""))

    if msg == "hide" then
        warningFrame:Hide()
        print("|cff00ff00OutOfHealz:|r Warning hidden.")
    elseif msg == "unlock" then
        isFrameUnlocked = true

        warningFrame:Show()
     warningFrame:EnableMouse(true)

     healthWarningFrame:Show()
        healthWarningFrame:SetAlpha(1)
     healthWarningFrame:EnableMouse(true)

     print("|cff00ff00OutOfHealz:|r Warning frames unlocked. Drag to move.")
    elseif msg == "lock" then
        isFrameUnlocked = false

     warningFrame:EnableMouse(false)
     warningFrame:Hide()

     healthWarningFrame:EnableMouse(false)
     healthWarningFrame:Hide()
     healthWarningFrame:SetAlpha(1)

     print("|cff00ff00OutOfHealz:|r Warning frames locked.")
    elseif msg == "reset" then
        OutOfHealzDB.point = "CENTER"
        OutOfHealzDB.relativePoint = "CENTER"
        OutOfHealzDB.xOfs = 0
        OutOfHealzDB.yOfs = 200

        warningFrame:ClearAllPoints()
        warningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

        OutOfHealzDB.healthPoint = "CENTER"
        OutOfHealzDB.healthRelativePoint = "CENTER"
        OutOfHealzDB.healthXOfs = 0
        OutOfHealzDB.healthYOfs = 90

        healthWarningFrame:ClearAllPoints()
        healthWarningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 90)

        print("|cff00ff00OutOfHealz:|r Warning frames reset.")
    elseif msg == "config" or msg == "options" or msg == "settings" then
        if Settings and Settings.OpenToCategory then
            Settings.OpenToCategory(OutOfHealzSettingsCategory.ID)
        else
            InterfaceOptionsFrame_OpenToCategory("OutOfHealz")
            InterfaceOptionsFrame_OpenToCategory("OutOfHealz")
        end

    elseif string.sub(msg, 1, 8) == "instance" then
        local setting = string.match(msg, "^instance%s+(%S+)$")

        if setting == "on" then
            OutOfHealzDB.instanceOnly = true

        elseif setting == "off" then
            OutOfHealzDB.instanceOnly = false

        else
            OutOfHealzDB.instanceOnly = not OutOfHealzDB.instanceOnly
        end

        if OutOfHealzDB.instanceOnly then
            print("|cff00ff00OutOfHealz:|r Instance-only mode enabled.")
        else
            print("|cff00ff00OutOfHealz:|r Instance-only mode disabled for testing.")
        end

    elseif string.sub(msg, 1, 5) == "sound" then
        local setting = string.match(msg, "^sound%s+(%S+)$")

        if setting == "on" then
            OutOfHealzDB.soundEnabled = true

        elseif setting == "off" then
            OutOfHealzDB.soundEnabled = false

        else
            OutOfHealzDB.soundEnabled = not OutOfHealzDB.soundEnabled
        end

        if OutOfHealzDB.soundEnabled then
            print("|cff00ff00OutOfHealz:|r Sound enabled.")
        else
            print("|cff00ff00OutOfHealz:|r Sound disabled.")
        end

    else
        print("|cff00ff00OutOfHealz commands:|r")
        print("/ooh hide - Hide warning")
        print("/ooh unlock - Unlock and move warning frame")
        print("/ooh lock - Lock warning frame")
        print("/ooh reset - Reset warning frame to center")
        print("/ooh instance - Toggle instance-only mode")
        print("/ooh instance on - Enable instance-only mode")
        print("/ooh instance off - Disable instance-only mode")
        print("/ooh sound - Toggle sound alerts")
        print("/ooh sound on - Enable sound alerts")
        print("/ooh sound off - Disable sound alerts")
        print("/ooh config - Open options")
        print("/ooh options - Open options")
        print("/ooh settings - Open options")
    end
end