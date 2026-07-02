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
version:SetText("Version 1.1.0")

local info = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
info:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -20)
info:SetText("Configure the options below to customize OutOfHealz.")
info:SetJustifyH("LEFT")

--------------------------------------------------
-- Behavior Section
--------------------------------------------------

local behaviorHeader = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
behaviorHeader:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -24)
behaviorHeader:SetText("Behavior")

local soundCheckbox = CreateCheckbox(
    optionsPanel,
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
    optionsPanel,
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
    optionsPanel,
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
-- Warning Frame Section
--------------------------------------------------

local warningFrameHeader = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
warningFrameHeader:SetPoint("TOPLEFT", pvpCheckbox, "BOTTOMLEFT", 0, -24)
warningFrameHeader:SetText("Warning Frame")

local scaleSlider = CreateSlider(
    optionsPanel,
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
end)

optionsPanel:SetScript("OnShow", function()
    soundCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.soundEnabled)
    instanceCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.instanceOnly)
    pvpCheckbox:SetChecked(OutOfHealzDB and OutOfHealzDB.pvpEnabled)
    scaleSlider:SetValue(OutOfHealzDB.warningScale or 1)
    scaleSlider.valueText:SetText("Current Scale: " .. string.format("%.0f%%", (OutOfHealzDB.warningScale or 1) * 100))
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