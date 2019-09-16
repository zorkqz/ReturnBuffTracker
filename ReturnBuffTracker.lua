local ReturnBuffTracker = LibStub("AceAddon-3.0"):NewAddon("ReturnBuffTracker", "AceConsole-3.0")

local defaults = {
    profile = {
        position = nil,
        width = 180,
        hideNotInRaid = true,
        deactivatedBars = {  }
    }
}

function ReturnBuffTracker:OnInitialize()

    ReturnBuffTracker.OptionBarNames = {}
    for k, buff in ipairs(ReturnBuffTracker.Buffs) do
        ReturnBuffTracker.OptionBarNames[buff.optionText or buff.text or buff.name] = buff.optionText or buff.text or buff.name
    end

    ReturnBuffTracker.db = LibStub("AceDB-3.0"):New("ReturnBuffTrackerDB", defaults, true)

    ReturnBuffTracker:SetupOptions()    
    ReturnBuffTracker:CreateMainFrame()
    
    for k, buff in ipairs(ReturnBuffTracker.Buffs) do
        buff.bar = ReturnBuffTracker:CreateInfoBar(buff.text or buff.shortName, buff.color.r, buff.color.g, buff.color.b)
    end
    ReturnBuffTracker:UpdateBars()
    
    ReturnBuffTracker.nextBuff = 1
    ReturnBuffTracker.nextTime = 0
    ReturnBuffTracker.updateFrame = CreateFrame("Frame")
    ReturnBuffTracker.updateFrame:SetScript("OnUpdate", ReturnBuffTracker.OnUpdate)
end

function ReturnBuffTracker:UpdateBars()
    local idx = 0
    for k, buff in ipairs(ReturnBuffTracker.Buffs) do
        if ReturnBuffTracker.db.profile.deactivatedBars[buff.optionText or buff.text or buff.name] then
            buff.bar:SetIndex(nil)
        else
            buff.bar:SetIndex(idx)
            idx = idx + 1
        end
    end
    ReturnBuffTracker:SetHeightForBars(idx)
end

function ReturnBuffTracker:OnUpdate()
    local currentTime = GetTime()
    if currentTime < ReturnBuffTracker.nextTime then
        return
    end
    ReturnBuffTracker.nextTime = currentTime + 0.1
    
    if not ReturnBuffTracker:CheckHideIfNotInRaid() then
        return
    end
    
    buff = ReturnBuffTracker.Buffs[ReturnBuffTracker.nextBuff]
    ReturnBuffTracker.nextBuff = ReturnBuffTracker.nextBuff + 1
    if ReturnBuffTracker.nextBuff > 19 then
        ReturnBuffTracker.nextBuff = 1
    end
    
    value = 0
    maxValue = 1
    tooltip = nil
    if buff.func then
        value, maxValue = ReturnBuffTracker[buff.func](ReturnBuffTracker, buff)
    else
        value, maxValue, tooltip = ReturnBuffTracker:CheckBuff(buff)
    end
    if value and maxValue and maxValue > 0 then
        buff.bar:Update(value, maxValue, tooltip)
    else
        buff.bar:Update(0, 1, nil)
    end
        
end

function ReturnBuffTracker:Contains(tab, val)
    if not tab then
        return true
    end

    for key, value in pairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function ReturnBuffTracker:CheckHideIfNotInRaid()
    if not ReturnBuffTracker.db.profile.hideNotInRaid or IsInRaid() then
        ReturnBuffTracker.mainFrame:Show()
        return true
    else
        ReturnBuffTracker.mainFrame:Hide()
        return false
    end
end

