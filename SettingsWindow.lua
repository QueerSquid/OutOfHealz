
--------------------------------------------------
-- OutOfHealz Standalone Settings Window
--------------------------------------------------

local addonName = "OutOfHealz"

local settingsFrame = CreateFrame(
    "Frame",
    "OutOfHealzSettingsWindow",
    UIParent,
    "BackdropTemplate"
)

settingsFrame:SetSize(820, 500)
settingsFrame:SetPoint("CENTER", UIParent, "CENTER", 100, 0)
settingsFrame:SetFrameStrata("DIALOG")
settingsFrame:SetToplevel(true)
settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag("LeftButton")

settingsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    if not OutOfHealzDB then
        return
    end

    local centerX, centerY = self:GetCenter()
    local parentX, parentY = UIParent:GetCenter()

    if centerX and centerY and parentX and parentY then
        OutOfHealzDB.settingsWindowX = centerX - parentX
        OutOfHealzDB.settingsWindowY = centerY - parentY
    end
end)

settingsFrame:SetClampedToScreen(true)
settingsFrame:Hide()

settingsFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }
})

settingsFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

--------------------------------------------------
-- Header
--------------------------------------------------

local title = settingsFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalLarge"
)

title:SetPoint("TOPLEFT", 20, -20)
title:SetText("OutOfHealz")

local version = C_AddOns.GetAddOnMetadata(
    addonName,
    "Version"
) or "Unknown"

local versionText = settingsFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
)

versionText:SetPoint("LEFT", title, "RIGHT", 12, 0)
versionText:SetText("v" .. version)

--------------------------------------------------
-- Close Button
--------------------------------------------------

local closeButton = CreateFrame(
    "Button",
    nil,
    settingsFrame,
    "UIPanelCloseButton"
)

closeButton:SetPoint("TOPRIGHT", -4, -4)

--------------------------------------------------
-- Sidebar
--------------------------------------------------

local sidebar = CreateFrame(
    "Frame",
    nil,
    settingsFrame
)

sidebar:SetPoint("TOPLEFT", 16, -65)
sidebar:SetPoint("BOTTOMLEFT", 16, 16)
sidebar:SetWidth(170)

local content = CreateFrame(
    "Frame",
    nil,
    settingsFrame
)

content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 20, 0)
content:SetPoint("BOTTOMRIGHT", -20, 20)

--------------------------------------------------
-- Sidebar Navigation
--------------------------------------------------

local pages = {}
local buttons = {}

local function SelectPage(pageName)
    for name, page in pairs(pages) do
        page:SetShown(name == pageName)
    end

    for name, button in pairs(buttons) do
        button:SetEnabled(name ~= pageName)
    end
end

local function AddPage(pageName, index)
    local button = CreateFrame(
        "Button",
        nil,
        sidebar,
        "UIPanelButtonTemplate"
    )

    button:SetSize(160, 28)
    button:SetPoint("TOPLEFT", 0, -(index - 1) * 36)
    button:SetText(pageName)

    local page = CreateFrame("Frame", nil, content)
    page:SetAllPoints(content)
    page:Hide()

    local heading = page:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalLarge"
    )

    heading:SetPoint("TOPLEFT", 10, -10)
    heading:SetText(pageName)

    button:SetScript("OnClick", function()
        SelectPage(pageName)
    end)

    pages[pageName] = page
    buttons[pageName] = button

    return page
end

local generalPage = AddPage("General", 1)
local healthPage = AddPage("Health", 2)
local consumablesPage = AddPage("Consumables", 3)
local displayPage = AddPage("Display", 4)

SelectPage("General")


--------------------------------------------------
-- General Settings
--------------------------------------------------

local function CreateGeneralCheckbox(label, tooltip, yOffset, dbKey)
    local checkbox = CreateFrame(
        "CheckButton",
        nil,
        generalPage,
        "UICheckButtonTemplate"
    )

    checkbox:SetPoint("TOPLEFT", 12, yOffset)
    checkbox:SetSize(26, 26)

    checkbox.Text:SetText(label)
    checkbox.tooltipText = tooltip

    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(label)
        GameTooltip:AddLine(tooltip, 1, 1, 1, true)
        GameTooltip:Show()
    end)

    checkbox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    checkbox:SetScript("OnClick", function(self)
        OutOfHealzDB[dbKey] = self:GetChecked()
        
        if dbKey == "showMinimapButton"
            and OutOfHealz_UpdateMinimapButton then
            OutOfHealz_UpdateMinimapButton()
        end
    end)

    return checkbox
end

local soundCheckbox = CreateGeneralCheckbox(
    "Enable Sound Alerts",
    "Enable or disable OutOfHealz audio warnings.",
    -50,
    "soundEnabled"
)

local instanceCheckbox = CreateGeneralCheckbox(
    "Instance Only",
    "Only enable warnings in dungeon and raid instances.",
    -95,
    "instanceOnly"
)

local pvpCheckbox = CreateGeneralCheckbox(
    "Enable in PvP",
    "Allow OutOfHealz warnings in battlegrounds and arenas.",
    -140,
    "pvpEnabled"
)

local minimapCheckbox = CreateGeneralCheckbox(
    "Show Minimap Button",
    "Show or hide the OutOfHealz minimap launcher.",
    -185,
    "showMinimapButton"
)

--------------------------------------------------
-- Refresh General Settings
--------------------------------------------------

local function RefreshGeneralSettings()
    soundCheckbox:SetChecked(OutOfHealzDB.soundEnabled)
    instanceCheckbox:SetChecked(OutOfHealzDB.instanceOnly)
    pvpCheckbox:SetChecked(OutOfHealzDB.pvpEnabled)
    minimapCheckbox:SetChecked(
        OutOfHealzDB.showMinimapButton ~= false
    )

end

settingsFrame:HookScript("OnShow", function()
    RefreshGeneralSettings()
end)


--------------------------------------------------
-- Health Settings
--------------------------------------------------

local healthCheckbox = CreateFrame(
    "CheckButton",
    nil,
    healthPage,
    "UICheckButtonTemplate"
)

healthCheckbox:SetPoint("TOPLEFT", 12, -50)
healthCheckbox:SetSize(26, 26)
healthCheckbox.Text:SetText("Enable Low Health Warning")

healthCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.healthWarningEnabled = self:GetChecked()

    if OutOfHealz_UpdateHealthWarning then
        OutOfHealz_UpdateHealthWarning()
    end
end)

--------------------------------------------------
-- Health Threshold Slider
--------------------------------------------------

local thresholdLabel = healthPage:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

thresholdLabel:SetPoint("TOPLEFT", 12, -110)
thresholdLabel:SetText("Health Warning Threshold")

local thresholdValue = healthPage:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)

thresholdValue:SetPoint("LEFT", thresholdLabel, "RIGHT", 12, 0)

local thresholdSlider = CreateFrame(
    "Slider",
    "OutOfHealzStandaloneHealthThresholdSlider",
    healthPage,
    "OptionsSliderTemplate"
)

thresholdSlider:SetPoint("TOPLEFT", 20, -145)
thresholdSlider:SetSize(280, 18)
thresholdSlider:SetMinMaxValues(10, 75)
thresholdSlider:SetValueStep(5)
thresholdSlider:SetObeyStepOnDrag(true)

thresholdSlider.Low:SetText("10%")
thresholdSlider.High:SetText("75%")

thresholdSlider:SetScript("OnValueChanged", function(self, value)
    local roundedValue = math.floor(value / 5 + 0.5) * 5

    thresholdValue:SetText(roundedValue .. "%")
    OutOfHealzDB.healthThreshold = roundedValue

    if OutOfHealz_UpdateHealthWarning then
        OutOfHealz_UpdateHealthWarning()
    end
end)

--------------------------------------------------
-- Refresh Health Settings
--------------------------------------------------

local function RefreshHealthSettings()
    healthCheckbox:SetChecked(
        OutOfHealzDB.healthWarningEnabled
    )

    thresholdSlider:SetValue(
        OutOfHealzDB.healthThreshold or 35
    )
end

settingsFrame:HookScript("OnShow", function()
    RefreshHealthSettings()
end)


--------------------------------------------------
-- Consumables Settings
--------------------------------------------------

local potionCheckbox = CreateFrame(
    "CheckButton",
    nil,
    consumablesPage,
    "UICheckButtonTemplate"
)

potionCheckbox:SetPoint("TOPLEFT", 12, -50)
potionCheckbox:SetSize(26, 26)
potionCheckbox.Text:SetText("Enable Health Potion Warning")

potionCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.healthPotionWarningEnabled = self:GetChecked()

    if OutOfHealz_UpdatePotionWarning then
        OutOfHealz_UpdatePotionWarning()
    end
end)

local healthstoneCheckbox = CreateFrame(
    "CheckButton",
    nil,
    consumablesPage,
    "UICheckButtonTemplate"
)

healthstoneCheckbox:SetPoint("TOPLEFT", 12, -95)
healthstoneCheckbox:SetSize(26, 26)
healthstoneCheckbox.Text:SetText("Enable Healthstone Warning")

healthstoneCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.healthstoneWarningEnabled = self:GetChecked()

    if OutOfHealz_UpdateHealthstoneWarning then
        OutOfHealz_UpdateHealthstoneWarning()
    end
end)

--------------------------------------------------
-- Detected Consumables
--------------------------------------------------

local detectedHeading = consumablesPage:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

detectedHeading:SetPoint("TOPLEFT", 12, -165)
detectedHeading:SetText("Detected Consumables")

local potionStatus = consumablesPage:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)

potionStatus:SetPoint("TOPLEFT", 12, -195)
potionStatus:SetWidth(400)
potionStatus:SetJustifyH("LEFT")

local healthstoneStatus = consumablesPage:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)

healthstoneStatus:SetPoint("TOPLEFT", 12, -225)
healthstoneStatus:SetWidth(400)
healthstoneStatus:SetJustifyH("LEFT")


--------------------------------------------------
-- Refresh Consumables Settings
--------------------------------------------------

local function GetDetectedItemName(itemID)
    if not itemID then
        return "None"
    end

    return C_Item.GetItemNameByID(itemID)
        or ("Item " .. itemID)
end

local function UpdateDetectedConsumables()
    local potionID = OutOfHealz_GetSelectedHealthPotionID
        and OutOfHealz_GetSelectedHealthPotionID()

    local healthstoneID = OutOfHealz_GetSelectedHealthstoneID
        and OutOfHealz_GetSelectedHealthstoneID()

    potionStatus:SetText(
        "Health Potion: " .. GetDetectedItemName(potionID)
    )

    healthstoneStatus:SetText(
        "Healthstone: " .. GetDetectedItemName(healthstoneID)
    )
end

local function RefreshConsumablesSettings()
    potionCheckbox:SetChecked(
        OutOfHealzDB.healthPotionWarningEnabled
    )

    healthstoneCheckbox:SetChecked(
        OutOfHealzDB.healthstoneWarningEnabled
    )

    UpdateDetectedConsumables()
end

settingsFrame:HookScript("OnShow", function()
    RefreshConsumablesSettings()
end)


--------------------------------------------------
-- Consumable Status Events
--------------------------------------------------

local consumableStatusEvents = CreateFrame("Frame")

consumableStatusEvents:RegisterEvent("BAG_UPDATE_DELAYED")
consumableStatusEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
consumableStatusEvents:RegisterEvent("GET_ITEM_INFO_RECEIVED")

consumableStatusEvents:SetScript("OnEvent", function()
    if settingsFrame:IsShown() then
        UpdateDetectedConsumables()
    end
end)


--------------------------------------------------
-- Display Settings
--------------------------------------------------

local scaleLabel = displayPage:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

scaleLabel:SetPoint("TOPLEFT", 12, -50)
scaleLabel:SetText("Warning Frame Scale")

local scaleValue = displayPage:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)

scaleValue:SetPoint("LEFT", scaleLabel, "RIGHT", 12, 0)

local scaleSlider = CreateFrame(
    "Slider",
    "OutOfHealzPositioningScaleSlider",
    displayPage,
    "OptionsSliderTemplate"
)

scaleSlider:SetPoint("TOPLEFT", 20, -90)
scaleSlider:SetSize(280, 18)
scaleSlider:SetMinMaxValues(0.5, 2.0)
scaleSlider:SetValueStep(0.05)
scaleSlider:SetObeyStepOnDrag(true)

scaleSlider.Low:SetText("50%")
scaleSlider.High:SetText("200%")

local function ApplyWarningScale(value)
    local frames = {
        OutOfHealzWarningFrame,
        OutOfHealzHealthWarningFrame,
        OutOfHealzHealthPotionFrame,
        OutOfHealzHealthstoneFrame
    }

    for _, frame in ipairs(frames) do
        if frame then
            frame:SetScale(value)
        end
    end
end

scaleSlider:SetScript("OnValueChanged", function(self, value)
    local roundedValue = math.floor(value * 20 + 0.5) / 20

    scaleValue:SetText(
        string.format("%d%%", math.floor(roundedValue * 100 + 0.5))
    )

    OutOfHealzDB.warningScale = roundedValue
    ApplyWarningScale(roundedValue)

    if OutOfHealz_SyncConsumableButtons then
        OutOfHealz_SyncConsumableButtons()
    end
end)

--------------------------------------------------
-- Refresh Positioning Settings
--------------------------------------------------

local function RefreshPositioningSettings()
    scaleSlider:SetValue(
        OutOfHealzDB.warningScale or 1
    )
end

settingsFrame:HookScript("OnShow", function()
    RefreshPositioningSettings()
end)


--------------------------------------------------
-- Automatic Warning Frame Preview
--------------------------------------------------

local previewWasUnlocked = false
local previewActive = false

settingsFrame:HookScript("OnShow", function()
    if InCombatLockdown() then
        return
    end

    if OutOfHealz_IsFrameUnlocked then
        previewWasUnlocked = OutOfHealz_IsFrameUnlocked()
    else
        previewWasUnlocked = false
    end

    previewActive = true

    if not previewWasUnlocked and OutOfHealz_UnlockWarningFrames then
        OutOfHealz_UnlockWarningFrames()
    end
end)

settingsFrame:HookScript("OnHide", function()
    if not previewActive then
        return
    end

    previewActive = false

    if InCombatLockdown() then
        return
    end

    if not previewWasUnlocked
        and OutOfHealz_LockWarningFrames then
        OutOfHealz_LockWarningFrames()
    end
end)

--------------------------------------------------
-- Public Window Controls
--------------------------------------------------


function OutOfHealz_OpenSettings()
    -- Close Blizzard's settings before opening ours.
    if SettingsPanel and SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)
    end

    
    if OutOfHealzDB
        and OutOfHealzDB.settingsWindowX
        and OutOfHealzDB.settingsWindowY then

        settingsFrame:ClearAllPoints()
        settingsFrame:SetPoint(
            "CENTER",
            UIParent,
            "CENTER",
            OutOfHealzDB.settingsWindowX,
            OutOfHealzDB.settingsWindowY
        )
    end


    settingsFrame:Show()
end


function OutOfHealz_CloseSettings()
    settingsFrame:Hide()
end

function OutOfHealz_ToggleSettings()
    if settingsFrame:IsShown() then
        OutOfHealz_CloseSettings()
    else
        OutOfHealz_OpenSettings()
    end
end

--------------------------------------------------
-- AddOn Compartment Launcher
--------------------------------------------------

function OutOfHealz_OnCompartmentClick(addonName, buttonName)
    if OutOfHealz_ToggleSettings then
        OutOfHealz_ToggleSettings()
    end
end

--------------------------------------------------
-- Native Blizzard Settings
--------------------------------------------------


function OutOfHealz_OpenNativeSettings()
    if Settings and Settings.OpenToCategory
        and OutOfHealzSettingsCategory then

        -- Close our standalone window first.
        OutOfHealz_CloseSettings()

        Settings.OpenToCategory(
            OutOfHealzSettingsCategory.ID
        )
    else
        print("|cffff0000OutOfHealz:|r Native settings unavailable.")
    end
end
