local _, ns = ...
local RangeCheckCore = {
    Options = {
        RangeFrameX = 50,
        RangeFrameY = -50,
        RangeFramePoint = "CENTER",
        RangeFrameLocked = false,
    },
    Revision = 1,
    Version = "1.0",
}

RangeCheckDB = RangeCheckDB or {
    posX = 50,
    posY = -50,
    point = "CENTER"
}


local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

function RangeCheckCore:RegisterEvents() end
function RangeCheckCore:UnregisterEvents() end
function RangeCheckCore:AddMsg(text) print("RangeCheck:", text) end

function RangeCheckCore:GetDistance(uId, range)
    if range == 10 then
        return CheckInteractDistance(uId, 3)
    end
    return false
end

function RangeCheckCore:Cleanup()
    if RangeCheck and RangeCheck.frame then
        local point, _, _, x, y = RangeCheck.frame:GetPoint(1)
        self.Options.RangeFrameX = x
        self.Options.RangeFrameY = y
        self.Options.RangeFramePoint = point
    end
    
    if RangeCheck then
        RangeCheck:Hide()
        RangeCheck.frame = nil
    end
end

function RangeCheckCore:RegisterEvents()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGOUT")
    f:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_LOGOUT" then
            self:Cleanup()
        end
    end)
end

_G.RangeCheckCore = RangeCheckCore
RangeCheckCore:RegisterEvents()
