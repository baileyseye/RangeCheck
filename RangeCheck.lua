local RangeCheck = RangeCheckCore.RangeCheck or {}
RangeCheckCore.RangeCheck = RangeCheck

local checkFuncs = {}
local frame
local createFrame
local onUpdate
local dropdownFrame
local initializeDropdown

local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local isActive = false

local function setRange()
    RangeCheck:Show(10)
    isActive = true
end

local function toggleLocked()
    RangeCheckCore.Options.RangeFrameLocked = not RangeCheckCore.Options.RangeFrameLocked
end

function initializeDropdown(dropdownFrame, level, menu)
    local info
    
    if level == 1 then
        info = UIDropDownMenu_CreateInfo()
        info.text = "Lock Frame"
        if RangeCheckCore.Options.RangeFrameLocked then
            info.checked = true
        end

        info.func = toggleLocked
        UIDropDownMenu_AddButton(info, 1)
        
        info = UIDropDownMenu_CreateInfo()
        info.text = "Hide"
        info.notCheckable = true
        info.func = function()
            RangeCheck:Hide()
            isActive = false
        end

        UIDropDownMenu_AddButton(info, 1)
    end
end

function createFrame()
    local elapsed = 0

    frame = CreateFrame("GameTooltip", "RangeCheckFrame", UIParent, "GameTooltipTemplate")
    dropdownFrame = CreateFrame("Frame", "RangeCheckDropdown", frame, "UIDropDownMenuTemplate")

    frame:SetFrameStrata("MEDIUM")  
    frame:SetFrameLevel(5)          
    
    frame:SetPoint(RangeCheckDB.point or "CENTER", 
                  UIParent, 
                  RangeCheckDB.point or "CENTER", 
                  RangeCheckDB.posX or 50, 
                  RangeCheckDB.posY or -50)
                  
    frame:SetHeight(64)
    frame:SetWidth(64)
    frame:EnableMouse(true)
    frame:SetToplevel(true)
    frame:SetMovable()
    GameTooltip_OnLoad(frame)
    frame:SetPadding(16)

 local font, size, flags = frame.TextLeft2:GetFont()  

 for i = 2, 8 do
     if frame["TextLeft"..i] then
         frame["TextLeft"..i]:SetFont(font, size + 2, flags) 
     end
 end

    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if not RangeCheckCore.Options.RangeFrameLocked then
            self:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        ValidateFramePosition(self)
        local point, _, _, x, y = self:GetPoint(1)
        RangeCheckDB.posX = x
        RangeCheckDB.posY = y
        RangeCheckDB.point = point
    end)

    frame:SetScript("OnUpdate", function(self, e)
        if not isActive then return end 
        elapsed = elapsed + e
        if elapsed >= 0.5 and self.checkFunc then
            onUpdate(self, elapsed)
            elapsed = 0
        end
    end)

    frame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            UIDropDownMenu_Initialize(dropdownFrame, initializeDropdown, "MENU")
            ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 5, -10)
        end
    end)

        frame:SetScript("OnHide", function(self)
        if isActive then
            self:Show() 
        end
    end)


    return frame
end

function onUpdate(self, elapsed)
    if not isActive then return end 
    
    local color
    local j = 0

    self:ClearLines()
    self:AddLine("Кто в пакете", 1, 1, 1)  

    for i = 1, GetNumRaidMembers() do
        local uId = "raid"..i
        if not UnitIsUnit(uId, "player") and not UnitIsDeadOrGhost(uId) and self.checkFunc(uId) then
            j = j + 1
            color = RAID_CLASS_COLORS[select(2, UnitClass(uId))] or NORMAL_FONT_COLOR
            local icon = GetRaidTargetIndex(uId)
            local text = icon and ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t %s"):format(icon, UnitName(uId)) or UnitName(uId)
            self:AddLine(text, color.r, color.g, color.b)
            if j >= 7 then break end
        end
    end

    self:Show()
end

checkFuncs[10] = function(uId)
    return CheckInteractDistance(uId, 3)
end

function RangeCheck:Show()
    frame = frame or createFrame()
    frame.checkFunc = checkFuncs[10]  
    frame.range = 10
    frame:Show()
    frame:SetOwner(UIParent, "ANCHOR_PRESERVE")
    isActive = true 
    onUpdate(frame, 0)
end

function RangeCheck:Hide()
    if frame then 
        frame:Hide()
        isActive = false 
    end
end

function RangeCheck:IsShown()
    return frame and frame:IsShown() and isActive
end

SLASH_RANGECHECK1 = "/showrange"
SlashCmdList["RANGECHECK"] = function()
    if RangeCheck:IsShown() then
        RangeCheck:Hide()
    else
        RangeCheck:Show()
    end
end
