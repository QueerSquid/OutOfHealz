--------------------------------------------------
-- OutOfHealz Options UI
--------------------------------------------------

local addonName = "OutOfHealz"

local optionsPanel = CreateFrame("Frame", "OutOfHealzOptionsPanel")
optionsPanel.name = addonName

--------------------------------------------------
-- Helper Functions
--------------------------------------------------

local function CreateCheckbox(parent, name, label, tooltip, anchor, xOffset, yOffset)
    local checkbox = CreateFrame(
        "CheckButton",
        name,
        parent,
        "InterfaceOptionsCheckButtonTemplate"
    )

    checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", xOffset or 0, yOffset or -10)
    checkbox.Text:SetText(label)
    checkbox.tooltipText = tooltip

    return checkbox
end

local function CreateSlider(parent, name, label, minValue, maxValue, step, anchor, xOffset, yOffset)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")

    slider:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", xOffset or 0, yOffset or -24)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(240)

    slider.Text:SetText(label)
    slider.Low:SetText(tostring(minValue))
    slider.High:SetText(tostring(maxValue))

    slider.valueText = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slider.valueText:SetPoint("TOP", slider, "BOTTOM", 0, -4)

    return slider
end

--------------------------------------------------
-- Header
--------------------------------------------------

local title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("OutOfHealz")

local subtitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Healer range awareness and survivability warnings.")

local version = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontDisable")
version:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)

local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Unknown"
version:SetText("Version " .. addonVersion)

local info = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
info:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -20)
info:SetText("Configure the options below to customize OutOfHealz.")
info:SetJustifyH("LEFT")

--------------------------------------------------
-- Scrollable Settings Content
--------------------------------------------------

local scrollFrame = CreateFrame(
    "ScrollFrame",
    "OutOfHealzNativeScrollFrame",
    optionsPanel,
    "UIPanelScrollFrameTemplate"
)

scrollFrame:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -12)
scrollFrame:SetPoint("BOTTOMRIGHT", optionsPanel, "BOTTOMRIGHT", -30, 12)

local scrollContent = CreateFrame("Frame", nil, scrollFrame)
scrollContent:SetSize(560, 850)
scrollFrame:SetScrollChild(scrollContent)

--------------------------------------------------
-- Behavior Section
--------------------------------------------------

local behaviorHeader = scrollContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
behaviorHeader:SetPoint("TOPLEFT", 0, -12)
behaviorHeader:SetText("Behavior")

local soundCheckbox = CreateCheckbox(
    scrollContent,
    "OutOfHealzSoundCheckbox",
    "Enable Sound Alerts",
    "Enable or disable OutOfHealz audio warnings.",
    behaviorHeader,
    0,
    -10
)

soundCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.soundEnabled)

soundCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.soundEnabled = self:GetChecked()

    if OutOfHealzDB.soundEnabled then
        print("|cff00ff00OutOfHealz:|r Sound enabled.")
    else
        print("|cff00ff00OutOfHealz:|r Sound disabled.")
    end
end)

local instanceCheckbox = CreateCheckbox(
    scrollContent,
    "OutOfHealzInstanceCheckbox",
    "Instance Only",
    "Only enable OutOfHealz in dungeon and raid instances.",
    soundCheckbox,
    0,
    -8
)

instanceCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.instanceOnly)

instanceCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.instanceOnly = self:GetChecked()

    if OutOfHealzDB.instanceOnly then
        print("|cff00ff00OutOfHealz:|r Instance-only mode enabled.")
    else
        print("|cff00ff00OutOfHealz:|r Instance-only mode disabled.")
    end
end)

local pvpCheckbox = CreateCheckbox(
    scrollContent,
    "OutOfHealzPvPCheckbox",
    "Enable in PvP",
    "Allow OutOfHealz warnings in battlegrounds and arenas.",
    instanceCheckbox,
    0,
    -8
)

pvpCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.pvpEnabled)

pvpCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.pvpEnabled = self:GetChecked()

    if OutOfHealzDB.pvpEnabled then
        print("|cff00ff00OutOfHealz:|r PvP warnings enabled.")
    else
        print("|cff00ff00OutOfHealz:|r PvP warnings disabled.")
    end
end)

--------------------------------------------------
-- Minimap Button Visibility
--------------------------------------------------

local minimapCheckbox = CreateFrame(
    "CheckButton",
    "OutOfHealzNativeMinimapCheckbox",
    scrollContent,
    "InterfaceOptionsCheckButtonTemplate"
)

minimapCheckbox:SetPoint("TOPLEFT", pvpCheckbox, "BOTTOMLEFT", 0, -10)
minimapCheckbox.Text:SetText("Show Minimap Button")

minimapCheckbox.tooltipText =
    "Show or hide the OutOfHealz minimap launcher."

minimapCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.showMinimapButton = self:GetChecked()

    if OutOfHealz_UpdateMinimapButton then
        OutOfHealz_UpdateMinimapButton()
    end
end)

--------------------------------------------------
-- Health Warning Section
--------------------------------------------------

local healthWarningHeader = scrollContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
healthWarningHeader:SetPoint("TOPLEFT", minimapCheckbox, "BOTTOMLEFT", 0, -24)
healthWarningHeader:SetText("Health Warning")

local healthWarningCheckbox = CreateCheckbox(
    scrollContent,
    "OutOfHealzHealthWarningCheckbox",
    "Enable Low Health Warning",
    "Display a warning when your health falls below the configured threshold.",
    healthWarningHeader,
    0,
    -10
)

healthWarningCheckbox:SetChecked(
    OutOfHealzDB and OutOfHealzDB.healthWarningEnabled
)

healthWarningCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.healthWarningEnabled = self:GetChecked()

    if OutOfHealz_UpdateHealthWarning then
        OutOfHealz_UpdateHealthWarning()
    end
end)

local healthThresholdSlider = CreateSlider(
    scrollContent,
    "OutOfHealzHealthThresholdSlider",
    "Low Health Threshold",
    10,
    75,
    5,
    healthWarningCheckbox,
    0,
    -24
)

healthThresholdSlider:SetValue(
    OutOfHealzDB.healthThreshold or 35
)

healthThresholdSlider.valueText:SetText(
    "Current Threshold: " .. tostring(OutOfHealzDB.healthThreshold or 35) .. "%"
)

healthThresholdSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)

    OutOfHealzDB.healthThreshold = value

    healthThresholdSlider.valueText:SetText(
        "Current Threshold: " .. value .. "%"
    )

    if OutOfHealz_UpdateHealthWarning then
        OutOfHealz_UpdateHealthWarning()
    end
end)

local healthPotionCheckbox = CreateCheckbox(
    scrollContent,
    "OutOfHealzHealthPotionCheckbox",
    "Enable Health Potion Reminder",
    "Show a clickable healing potion reminder when you fall below the configured low health threshold.",
    healthThresholdSlider,
    0,
    -28
)

healthPotionCheckbox:SetChecked(
    OutOfHealzDB and OutOfHealzDB.healthPotionWarningEnabled
)

healthPotionCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.healthPotionWarningEnabled = self:GetChecked()

    if OutOfHealz_UpdatePotionWarning then
        OutOfHealz_UpdatePotionWarning()
    end
end)

local healthstoneCheckbox = CreateCheckbox(
    scrollContent,
    "OutOfHealzHealthstoneCheckbox",
    "Enable Healthstone Reminder",
    "Show a clickable Healthstone reminder when you fall below the configured low health threshold.",
    healthPotionCheckbox,
    0,
    -24
)

healthstoneCheckbox:SetChecked(
    OutOfHealzDB and OutOfHealzDB.healthstoneWarningEnabled
)

healthstoneCheckbox:SetScript("OnClick", function(self)
    OutOfHealzDB.healthstoneWarningEnabled = self:GetChecked()

    if OutOfHealz_UpdateHealthstoneWarning then
        OutOfHealz_UpdateHealthstoneWarning()
    end
end)

local potionDetectedText = scrollContent:CreateFontString(
    nil, "ARTWORK", "GameFontHighlightSmall"
)
potionDetectedText:SetPoint(
    "TOPLEFT", healthPotionCheckbox, "BOTTOMLEFT", 26, -2
)
potionDetectedText:SetText("Detected: None")

local healthstoneDetectedText = scrollContent:CreateFontString(
    nil, "ARTWORK", "GameFontHighlightSmall"
)
healthstoneDetectedText:SetPoint(
    "TOPLEFT", healthstoneCheckbox, "BOTTOMLEFT", 26, -2
)
healthstoneDetectedText:SetText("Detected: None")

local function GetDetectedItemName(itemID)
    if not itemID then
        return "None"
    end

    return C_Item.GetItemNameByID(itemID) or ("Item " .. itemID)
end

local function UpdateDetectedConsumables()
    local potionID = OutOfHealz_GetSelectedHealthPotionID
        and OutOfHealz_GetSelectedHealthPotionID()
    
    local healthstoneID = OutOfHealz_GetSelectedHealthstoneID
        and OutOfHealz_GetSelectedHealthstoneID()

    potionDetectedText:SetText(
        "Detected: " .. GetDetectedItemName(potionID)
    )

    healthstoneDetectedText:SetText(
        "Detected: " .. GetDetectedItemName(healthstoneID)
    )
end

--------------------------------------------------
-- Warning Frame Section
--------------------------------------------------

local warningFrameHeader = scrollContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
warningFrameHeader:SetPoint("TOPLEFT", healthstoneDetectedText, "BOTTOMLEFT", -26, -24)
warningFrameHeader:SetText("Warning Frame")

local scaleSlider = CreateSlider(
    scrollContent,
    "OutOfHealzScaleSlider",
    "Warning Scale",
    0.5,
    2.0,
    0.05,
    warningFrameHeader,
    0,
    -24
)

scaleSlider:SetValue(OutOfHealzDB.warningScale or 1)
scaleSlider.valueText:SetText("Current Scale: " .. string.format("%.0f%%", (OutOfHealzDB.warningScale or 1) * 100))

scaleSlider:SetScript("OnValueChanged", function(self, value)
    value = tonumber(string.format("%.2f", value))

    OutOfHealzDB.warningScale = value
    scaleSlider.valueText:SetText("Current Scale: " .. string.format("%.0f%%", value * 100))

    if OutOfHealzWarningFrame then
        OutOfHealzWarningFrame:SetScale(value)
    end

    if OutOfHealzHealthWarningFrame then
        OutOfHealzHealthWarningFrame:SetScale(value)
    end

    if OutOfHealzHealthPotionFrame then
        OutOfHealzHealthPotionFrame:SetScale(value)
    end

    if OutOfHealzHealthstoneFrame then
        OutOfHealzHealthstoneFrame:SetScale(value)
    end

    if OutOfHealz_SyncConsumableButtons then
        OutOfHealz_SyncConsumableButtons()
    end
end)

local consumableStatusEvents = CreateFrame("Frame")
consumableStatusEvents:RegisterEvent("BAG_UPDATE_DELAYED")
consumableStatusEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
consumableStatusEvents:RegisterEvent("GET_ITEM_INFO_RECEIVED")

consumableStatusEvents:SetScript("OnEvent", function()
    if optionsPanel:IsShown() then
        UpdateDetectedConsumables()
    end
end)

optionsPanel:SetScript("OnShow", function()
    scrollFrame:SetVerticalScroll(0)
        -- Prevent both configuration interfaces from being visible.
    if OutOfHealz_CloseSettings then
        OutOfHealz_CloseSettings()
    end

    soundCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.soundEnabled)
    instanceCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.instanceOnly)
    pvpCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.pvpEnabled)

    minimapCheckbox:SetChecked(
        OutOfHealzDB.showMinimapButton ~= false
    )

    healthWarningCheckbox:SetChecked(
        OutOfHealzDB and OutOfHealzDB.healthWarningEnabled
    )

    healthThresholdSlider:SetValue(
        OutOfHealzDB.healthThreshold or 35
    )

    healthThresholdSlider.valueText:SetText(
        "Current Threshold: " .. tostring(OutOfHealzDB.healthThreshold or 35) .. "%"
    )

    healthPotionCheckbox:SetChecked(
        OutOfHealzDB and OutOfHealzDB.healthPotionWarningEnabled
    )

    healthstoneCheckbox:SetChecked(
        OutOfHealzDB and OutOfHealzDB.healthstoneWarningEnabled
    )

    scaleSlider:SetValue(OutOfHealzDB.warningScale or 1)
    UpdateDetectedConsumables()

    scaleSlider.valueText:SetText(
        "Current Scale: " .. string.format("%.0f%%", (OutOfHealzDB.warningScale or 1) * 100)
    )
end)

--------------------------------------------------
-- Registration
--------------------------------------------------

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, addonName)
    Settings.RegisterAddOnCategory(category)

    OutOfHealzSettingsCategory = category
else
    InterfaceOptions_AddCategory(optionsPanel)
end