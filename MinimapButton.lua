
--------------------------------------------------
-- OutOfHealz Minimap Button
--------------------------------------------------

local button = CreateFrame("Button", "OutOfHealzMinimapButton", Minimap)
button:SetSize(32, 32)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
button:RegisterForDrag("LeftButton")
button:SetMovable(true)
button:SetClampedToScreen(true)

--------------------------------------------------
-- Button Artwork
--------------------------------------------------

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetSize(20, 20)
icon:SetPoint("CENTER")
icon:SetTexture("Interface\\Icons\\INV_Potion_54")

local border = button:CreateTexture(nil, "OVERLAY")
border:SetSize(54, 54)
border:SetPoint("TOPLEFT")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

--------------------------------------------------
-- Position and Visibility
--------------------------------------------------

local function UpdatePosition()
    local angle = math.rad(
        (OutOfHealzDB and OutOfHealzDB.minimapAngle) or 350
    )

    local radius = 105

    button:ClearAllPoints()
    button:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        math.cos(angle) * radius,
        math.sin(angle) * radius
    )
end

local function UpdateVisibility()
    if OutOfHealzDB and OutOfHealzDB.showMinimapButton == false then
        button:Hide()
    else
        button:Show()
    end
end

--------------------------------------------------
-- Click Actions
--------------------------------------------------

button:SetScript("OnClick", function(_, mouseButton)
    if mouseButton == "LeftButton" then
        if OutOfHealz_ToggleSettings then
            OutOfHealz_ToggleSettings()
        end

    elseif mouseButton == "RightButton" then
        if OutOfHealz_OpenNativeSettings then
            OutOfHealz_OpenNativeSettings()
        end
    end
end)

--------------------------------------------------
-- Tooltip
--------------------------------------------------

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("OutOfHealz", 1, 1, 1)

    GameTooltip:AddLine(
        "Left-click: |cffffd100Open Settings|r",
        1, 1, 1
    )

    GameTooltip:AddLine(
        "Right-click: |cffffd100Blizzard Settings|r",
        1, 1, 1
    )

    GameTooltip:AddLine(
        "Drag: |cffffd100Move Minimap Button|r",
        1, 1, 1
    )

    GameTooltip:Show()
end)

button:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

--------------------------------------------------
-- Drag Positioning
--------------------------------------------------

button:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        if not OutOfHealzDB then
            return
        end

        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        x, y = x / scale, y / scale

        local centerX, centerY = Minimap:GetCenter()

        if not centerX or not centerY then
            return
        end

        local angle = math.deg(
            math.atan2(y - centerY, x - centerX)
        )

        OutOfHealzDB.minimapAngle = angle
        UpdatePosition()
    end)
end)

button:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

--------------------------------------------------
-- Initialization
--------------------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")

events:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    UpdatePosition()
    UpdateVisibility()
end)

OutOfHealz_UpdateMinimapButton = function()
    UpdatePosition()
    UpdateVisibility()
end
