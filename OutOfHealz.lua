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

if OutOfHealzDB.healthPotionWarningEnabled == nil then
    OutOfHealzDB.healthPotionWarningEnabled = true
end

if OutOfHealzDB.healthPotionPoint == nil then
    OutOfHealzDB.healthPotionPoint = "BOTTOMLEFT"
end

if OutOfHealzDB.healthPotionRelativePoint == nil then
    OutOfHealzDB.healthPotionRelativePoint = "BOTTOMLEFT"
end

if OutOfHealzDB.healthPotionXOfs == nil then
    OutOfHealzDB.healthPotionXOfs = 385
end

if OutOfHealzDB.healthPotionYOfs == nil then
    OutOfHealzDB.healthPotionYOfs = 135
end

if OutOfHealzDB.healthstoneWarningEnabled == nil then
    OutOfHealzDB.healthstoneWarningEnabled = true
end

if OutOfHealzDB.healthstonePoint == nil then
    OutOfHealzDB.healthstonePoint = "BOTTOMLEFT"
end

if OutOfHealzDB.healthstoneRelativePoint == nil then
    OutOfHealzDB.healthstoneRelativePoint = "BOTTOMLEFT"
end

if OutOfHealzDB.healthstoneXOfs == nil then
    OutOfHealzDB.healthstoneXOfs = 580
end

if OutOfHealzDB.healthstoneYOfs == nil then
    OutOfHealzDB.healthstoneYOfs = 165
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

local supportedHealthPotions = {
    271884, -- Concentrated Silvermoon Health Potion, higher quality
    271883, -- Concentrated Silvermoon Health Potion, lower quality
    241304, -- Silvermoon Health Potion, higher quality
    241305, -- Silvermoon Health Potion, lower quality
    258138, -- Potent Healing Potion
}

local selectedHealthPotionID = nil

local supportedHealthstones = {
    224464, -- Demonic Healthstone
    5512,   -- Healthstone
}

local selectedHealthstoneID = nil

local CONSUMABLE_GAP = 12

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
-- Health Potion Reminder
--------------------------------------------------

local healthPotionFrame = CreateFrame(
    "Frame",
    "OutOfHealzHealthPotionFrame",
    UIParent
)

healthPotionFrame:SetSize(140, 72)
healthPotionFrame:SetScale(OutOfHealzDB.warningScale or 1)

healthPotionFrame:SetPoint(
    OutOfHealzDB.healthPotionPoint or "BOTTOMLEFT",
    UIParent,
    OutOfHealzDB.healthPotionRelativePoint or "BOTTOMLEFT",
    OutOfHealzDB.healthPotionXOfs or 385,
    OutOfHealzDB.healthPotionYOfs or 135
)

healthPotionFrame:SetFrameStrata("FULLSCREEN_DIALOG")
healthPotionFrame:Hide()

local potionLabel = healthPotionFrame:CreateFontString(nil, "OVERLAY")
potionLabel:SetFont("Fonts\\FRIZQT__.TTF", 26, "OUTLINE")
potionLabel:SetPoint("LEFT", healthPotionFrame, "LEFT", 4, 0)
potionLabel:SetText("USE")
potionLabel:SetTextColor(1, 1, 1, 1)

local potionIcon = healthPotionFrame:CreateTexture(nil, "ARTWORK")
potionIcon:SetSize(56, 56)
potionIcon:SetPoint("LEFT", potionLabel, "RIGHT", 12, 0)
potionIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

local potionBorder = healthPotionFrame:CreateTexture(nil, "OVERLAY")
potionBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
potionBorder:SetPoint("TOPLEFT", potionIcon, "TOPLEFT", -8, 8)
potionBorder:SetPoint("BOTTOMRIGHT", potionIcon, "BOTTOMRIGHT", 8, -8)

local potionCooldown = CreateFrame(
    "Cooldown",
    nil,
    healthPotionFrame,
    "CooldownFrameTemplate"
)

potionCooldown:SetSize(56, 56)
potionCooldown:SetPoint("CENTER", potionIcon, "CENTER")

local potionButton = CreateFrame(
    "Button",
    "OutOfHealzHealthPotionButton",
    UIParent,
    "SecureActionButtonTemplate"
)

potionButton:SetSize(56, 56)
potionButton:SetFrameStrata("FULLSCREEN_DIALOG")
potionButton:RegisterForClicks("AnyUp", "AnyDown")

potionButton:SetScript("OnEnter", function(self)
    if selectedHealthPotionID then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(selectedHealthPotionID)
        GameTooltip:Show()
    end
end)

potionButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

--------------------------------------------------
-- Healthstone Reminder
--------------------------------------------------

local healthstoneFrame = CreateFrame(
    "Frame",
    "OutOfHealzHealthstoneFrame",
    UIParent
)

healthstoneFrame:SetSize(140, 72)
healthstoneFrame:SetScale(OutOfHealzDB.warningScale or 1)

healthstoneFrame:SetPoint(
    "LEFT",
    healthPotionFrame,
    "RIGHT",
    CONSUMABLE_GAP,
    0
)

healthstoneFrame:SetFrameStrata("FULLSCREEN_DIALOG")
healthstoneFrame:Hide()

local healthstoneLabel = healthstoneFrame:CreateFontString(nil, "OVERLAY")
healthstoneLabel:SetFont("Fonts\\FRIZQT__.TTF", 26, "OUTLINE")
healthstoneLabel:SetPoint("LEFT", healthstoneFrame, "LEFT", 4, 0)
healthstoneLabel:SetText("USE")
healthstoneLabel:SetTextColor(1, 1, 1, 1)

local healthstoneIcon = healthstoneFrame:CreateTexture(nil, "ARTWORK")
healthstoneIcon:SetSize(56, 56)
healthstoneIcon:SetPoint("LEFT", healthstoneLabel, "RIGHT", 12, 0)
healthstoneIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

local healthstoneBorder = healthstoneFrame:CreateTexture(nil, "OVERLAY")
healthstoneBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
healthstoneBorder:SetPoint("TOPLEFT", healthstoneIcon, "TOPLEFT", -8, 8)
healthstoneBorder:SetPoint("BOTTOMRIGHT", healthstoneIcon, "BOTTOMRIGHT", 8, -8)

local healthstoneCooldown = CreateFrame(
    "Cooldown",
    nil,
    healthstoneFrame,
    "CooldownFrameTemplate"
)

healthstoneCooldown:SetSize(56, 56)
healthstoneCooldown:SetPoint("CENTER", healthstoneIcon, "CENTER")

local healthstoneButton = CreateFrame(
    "Button",
    "OutOfHealzHealthstoneButton",
    UIParent,
    "SecureActionButtonTemplate"
)

healthstoneButton:SetSize(56, 56)
healthstoneButton:SetFrameStrata("FULLSCREEN_DIALOG")
healthstoneButton:RegisterForClicks("AnyUp", "AnyDown")

healthstoneButton:SetScript("OnEnter", function(self)
    if selectedHealthstoneID then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(selectedHealthstoneID)
        GameTooltip:Show()
    end
end)

healthstoneButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
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

local function SyncConsumableButtons()
    if InCombatLockdown() then
        return
    end

    local scale = OutOfHealzDB.warningScale or 1

    local potionX, potionY = potionIcon:GetCenter()

    if potionX and potionY then
        potionButton:ClearAllPoints()
        potionButton:SetScale(scale)
        potionButton:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            potionX,
            potionY
        )
    end

    local healthstoneX, healthstoneY = healthstoneIcon:GetCenter()

    if healthstoneX and healthstoneY then
        healthstoneButton:ClearAllPoints()
        healthstoneButton:SetScale(scale)
        healthstoneButton:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            healthstoneX,
            healthstoneY
        )
    end
end

OutOfHealz_SyncConsumableButtons = SyncConsumableButtons

local function FindBestHealthPotion()
    for _, itemID in ipairs(supportedHealthPotions) do
        local count = C_Item.GetItemCount(itemID, false, false, false)

        if count and count > 0 then
            return itemID
        end
    end

    return nil
end

local function ConfigureHealthPotion()
    if InCombatLockdown() then
        return
    end

    selectedHealthPotionID = FindBestHealthPotion()

    if not selectedHealthPotionID then
        potionButton:SetAttribute("type", nil)
        potionButton:SetAttribute("item", nil)
        potionIcon:SetTexture(nil)
        potionButton:Hide()
        return
    end

    potionButton:SetAttribute("type", "item")
    potionButton:SetAttribute(
        "item",
        "item:" .. selectedHealthPotionID
    )

    local itemIcon = C_Item.GetItemIconByID(selectedHealthPotionID)

    if itemIcon then
        potionIcon:SetTexture(itemIcon)
    end

    SyncConsumableButtons()

    if OutOfHealzDB.healthPotionWarningEnabled and not isFrameUnlocked then
        potionButton:Show()
    else
        potionButton:Hide()
    end
end

local function FindBestHealthstone()
    for _, itemID in ipairs(supportedHealthstones) do
        local count = C_Item.GetItemCount(itemID, false, false, false)

        if count and count > 0 then
            return itemID
        end
    end

    return nil
end

local function ConfigureHealthstone()
    if InCombatLockdown() then
        return
    end

    selectedHealthstoneID = FindBestHealthstone()

    if not selectedHealthstoneID then
        healthstoneButton:SetAttribute("type", nil)
        healthstoneButton:SetAttribute("item", nil)
        healthstoneIcon:SetTexture(nil)
        healthstoneButton:Hide()
        return
    end

    healthstoneButton:SetAttribute("type", "item")
    healthstoneButton:SetAttribute(
        "item",
        "item:" .. selectedHealthstoneID
    )

    local itemIcon = C_Item.GetItemIconByID(selectedHealthstoneID)

    if itemIcon then
        healthstoneIcon:SetTexture(itemIcon)
    end

    SyncConsumableButtons()

    if OutOfHealzDB.healthstoneWarningEnabled and not isFrameUnlocked then
        healthstoneButton:Show()
    else
        healthstoneButton:Hide()
    end
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

local function IsPotionWarningAllowed()
    if not OutOfHealzDB.healthPotionWarningEnabled then
        return false
    end

    if not InCombatLockdown() then
        return false
    end

    if not selectedHealthPotionID then
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

local function IsSelectedPotionReady()
    if not selectedHealthPotionID then
        return false
    end

    local count = C_Item.GetItemCount(
        selectedHealthPotionID,
        false,
        false,
        false
    )

    if not count or count <= 0 then
        return false
    end

    local startTime, duration, enableCooldownTimer =
        C_Item.GetItemCooldown(selectedHealthPotionID)

    if not enableCooldownTimer then
        return false
    end

    if duration and duration > 0 then
        local remaining = (startTime + duration) - GetTime()

        if remaining > 0 then
            return false
        end
    end

    return true
end

local function IsHealthstoneWarningAllowed()
    if not OutOfHealzDB.healthstoneWarningEnabled then
        return false
    end

    if not InCombatLockdown() then
        return false
    end

    if not selectedHealthstoneID then
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

local function IsSelectedHealthstoneReady()
    if not selectedHealthstoneID then
        return false
    end

    local count = C_Item.GetItemCount(
        selectedHealthstoneID,
        false,
        false,
        false
    )

    if not count or count <= 0 then
        return false
    end

    local startTime, duration, enableCooldownTimer =
        C_Item.GetItemCooldown(selectedHealthstoneID)

    if not enableCooldownTimer then
        return false
    end

    if duration and duration > 0 then
        local remaining = (startTime + duration) - GetTime()

        if remaining > 0 then
            return false
        end
    end

    return true
end

local function UpdatePotionWarning()
    if isFrameUnlocked then
        healthPotionFrame:Show()
        healthPotionFrame:SetAlpha(1)
        return
    end

    if not IsPotionWarningAllowed() then
        healthPotionFrame:Hide()
        healthPotionFrame:SetAlpha(1)
        return
    end

    if not IsSelectedPotionReady() then
        healthPotionFrame:Hide()
        healthPotionFrame:SetAlpha(1)
        return
    end

    local curve = GetHealthThresholdCurve()

    local color = UnitHealthPercent(
        "player",
        true,
        curve
    )

    healthPotionFrame:Show()

    healthPotionFrame:SetAlpha(
        select(4, color:GetRGBA())
    )
end

OutOfHealz_UpdatePotionWarning = UpdatePotionWarning

local function UpdateHealthstoneWarning()
    if isFrameUnlocked then
        healthstoneFrame:Show()
        healthstoneFrame:SetAlpha(1)
        return
    end

    if not IsHealthstoneWarningAllowed() then
        healthstoneFrame:Hide()
        healthstoneFrame:SetAlpha(1)
        return
    end

    if not IsSelectedHealthstoneReady() then
        healthstoneFrame:Hide()
        healthstoneFrame:SetAlpha(1)
        return
    end

    local curve = GetHealthThresholdCurve()

    local color = UnitHealthPercent(
        "player",
        true,
        curve
    )

    healthstoneFrame:Show()

    healthstoneFrame:SetAlpha(
        select(4, color:GetRGBA())
    )
end

OutOfHealz_UpdateHealthstoneWarning = UpdateHealthstoneWarning

local function UpdateHealthWarning()
    if isFrameUnlocked then
        healthWarningFrame:Show()
        healthWarningFrame:SetAlpha(1)
        return
    end

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

healthPotionFrame:SetMovable(true)
healthPotionFrame:EnableMouse(false)
healthPotionFrame:RegisterForDrag("LeftButton")

healthPotionFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

healthPotionFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    OutOfHealzDB.healthPotionPoint = point
    OutOfHealzDB.healthPotionRelativePoint = relativePoint
    OutOfHealzDB.healthPotionXOfs = xOfs
    OutOfHealzDB.healthPotionYOfs = yOfs

    if not InCombatLockdown() then
        SyncConsumableButtons()
    end

    print("|cff00ff00OutOfHealz:|r Health potion reminder position saved.")
end)

healthstoneFrame:EnableMouse(false)
healthstoneFrame:RegisterForDrag("LeftButton")

healthstoneFrame:SetScript("OnDragStart", function()
    healthPotionFrame:StartMoving()
end)

healthstoneFrame:SetScript("OnDragStop", function()
    healthPotionFrame:StopMovingOrSizing()

    local point, _, relativePoint, xOfs, yOfs =
        healthPotionFrame:GetPoint()

    OutOfHealzDB.healthPotionPoint = point
    OutOfHealzDB.healthPotionRelativePoint = relativePoint
    OutOfHealzDB.healthPotionXOfs = xOfs
    OutOfHealzDB.healthPotionYOfs = yOfs

    if not InCombatLockdown() then
        SyncConsumableButtons()
    end

    print("|cff00ff00OutOfHealz:|r Consumable reminder position saved.")
end)

--------------------------------------------------
-- Healer Detection
--------------------------------------------------

local function GetHealerRangeState()
    local healerCount = 0
    local anyHealerInRange = false
    local anyHealerUnknown = false

    local function CheckUnit(unit)
        if UnitExists(unit)
            and not UnitIsUnit(unit, "player")
            and not UnitIsDeadOrGhost(unit)
            and UnitGroupRolesAssigned(unit) == "HEALER" then

            healerCount = healerCount + 1

            local minRange, maxRange = RangeCheck:GetRange(unit)

            -- Definitely in range:
            -- the entire estimated range is at or below 40 yards.
            if maxRange and maxRange <= 40 then
                anyHealerInRange = true
                return
            end

            -- Definitely out of range:
            -- LibRangeCheck has established the healer is beyond 40 yards.
            if minRange and minRange >= 40 then
                return
            end

            -- Anything else is ambiguous, such as 0-46 or nil/nil.
            anyHealerUnknown = true
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

    if healerCount == 0 then
        return "NO_HEALERS", healerCount
    elseif anyHealerInRange then
        return "IN_RANGE", healerCount
    elseif anyHealerUnknown then
        return "UNKNOWN", healerCount
    else
        return "OUT_OF_RANGE", healerCount
    end
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
healthEventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
healthEventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
healthEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")

healthEventFrame:SetScript("OnEvent", function(self, event, unit)
    if unit and unit ~= "player" then
        return
    end

    if not InCombatLockdown() then
        ConfigureHealthPotion()
        ConfigureHealthstone()
    end

    UpdateHealthWarning()
    UpdatePotionWarning()
    UpdateHealthstoneWarning()
end)

ConfigureHealthPotion()
ConfigureHealthstone()

--------------------------------------------------
-- Core Detection Logic
--------------------------------------------------

frame:SetScript("OnUpdate", function(self, elapsed)
    local now = GetTime()

    if now - lastCheck < interval then
        return
    end

    lastCheck = now

    UpdatePotionWarning()
    UpdateHealthstoneWarning()

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

    local healerRangeState, totalHealers = GetHealerRangeState()

    local currentState

    if healerRangeState == "NO_HEALERS" then
        currentState = "NO HEALERS DETECTED"

    elseif healerRangeState == "IN_RANGE" then
        currentState = "HEALER IN RANGE"

    elseif healerRangeState == "OUT_OF_RANGE" then
        currentState = "OUT OF HEAL RANGE"

    else
        currentState = "HEALER RANGE UNKNOWN"
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

        healthPotionFrame:Show()
        healthPotionFrame:SetAlpha(1)
        healthPotionFrame:EnableMouse(true)

        healthstoneFrame:Show()
        healthstoneFrame:SetAlpha(1)
        healthstoneFrame:EnableMouse(true)

        if not InCombatLockdown() then
            potionButton:Hide()
            healthstoneButton:Hide()
        end

        print("|cff00ff00OutOfHealz:|r Warning frames unlocked. Drag to move.")
    elseif msg == "lock" then
        isFrameUnlocked = false

        warningFrame:EnableMouse(false)
        warningFrame:Hide()

        healthWarningFrame:EnableMouse(false)
        healthWarningFrame:Hide()
        healthWarningFrame:SetAlpha(1)

        healthPotionFrame:EnableMouse(false)
        healthPotionFrame:Hide()
        healthPotionFrame:SetAlpha(1)

        healthstoneFrame:EnableMouse(false)
        healthstoneFrame:Hide()
        healthstoneFrame:SetAlpha(1)

        if not InCombatLockdown() then
            ConfigureHealthPotion()
            ConfigureHealthstone()
        end

        UpdateHealthWarning()
        UpdatePotionWarning()
        UpdateHealthstoneWarning()

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

        OutOfHealzDB.healthPotionPoint = "BOTTOMLEFT"
        OutOfHealzDB.healthPotionRelativePoint = "BOTTOMLEFT"
        OutOfHealzDB.healthPotionXOfs = 385
        OutOfHealzDB.healthPotionYOfs = 135

        healthstoneFrame:ClearAllPoints()
        healthstoneFrame:SetPoint(
            "LEFT",
            healthPotionFrame,
            "RIGHT",
            CONSUMABLE_GAP,
            0
        )

        if not InCombatLockdown() then
            SyncConsumableButtons()
        end

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