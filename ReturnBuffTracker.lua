local ReturnBuffTracker = LibStub("AceAddon-3.0"):NewAddon("ReturnBuffTracker",
                                                           "AceConsole-3.0")

local defaults = {
    profile = {
        position = nil,
        width = 180,
        hideNotInRaid = true,
        deactivatedBars = {}
    }
}

function ReturnBuffTracker:OnInitialize()

    ReturnBuffTracker.OptionBarNames = {}
    for i, v in pairs(ReturnBuffTracker.Constants.BarOptionGroups) do
        ReturnBuffTracker.OptionBarNames[i] = {}
    end

    for k, buff in pairs(ReturnBuffTracker.Buffs) do
        if (buff.buffOptionsGroup) then
            ReturnBuffTracker.OptionBarNames[buff.buffOptionsGroup][buff.optionText or
                buff.text or buff.name] =
                buff.optionText or buff.text or buff.name
        else

        end

    end

    ReturnBuffTracker.db = LibStub("AceDB-3.0"):New("ReturnBuffTrackerDB",
                                                    defaults, true)

    ReturnBuffTracker:SetupOptions()
    ReturnBuffTracker:CreateMainFrame()

    local buffbars = {}
    for k, group in pairs(ReturnBuffTracker.Constants.BarOptionGroups) do
        buffbars[group] = {}
    end

    for k, buff in ipairs(ReturnBuffTracker.Buffs) do
        tinsert(buffbars[buff.buffOptionsGroup], buff)
        buff.bar = ReturnBuffTracker:CreateInfoBar(buff.text or buff.shortName,
                                                   buff.color.r, buff.color.g,
                                                   buff.color.b)
    end

    ReturnBuffTracker:UpdateBars()

    ReturnBuffTracker.nextBuff = 1
    ReturnBuffTracker.nextTime = 0
    ReturnBuffTracker.updateFrame = CreateFrame("Frame")
    ReturnBuffTracker.updateFrame:SetScript("OnUpdate",
                                            ReturnBuffTracker.OnUpdate)
end

function ReturnBuffTracker:UpdateBars()
    local idx = 0
    for k, buff in ipairs(ReturnBuffTracker.Buffs) do
        if ReturnBuffTracker.db.profile.deactivatedBars[buff.optionText or
            buff.text or buff.name] then
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
    if currentTime < ReturnBuffTracker.nextTime then return end
    ReturnBuffTracker.nextTime = currentTime + 0.1

    if not ReturnBuffTracker:CheckHideIfNotInRaid() then return end

    buff = ReturnBuffTracker.Buffs[ReturnBuffTracker.nextBuff]
    ReturnBuffTracker.nextBuff = ReturnBuffTracker.nextBuff + 1
    if ReturnBuffTracker.nextBuff > table.getn(ReturnBuffTracker.Buffs) then
        ReturnBuffTracker.nextBuff = 1
    end

    if ReturnBuffTracker.db.profile.deactivatedBars[buff.optionText or buff.text or
        buff.name] then return end

    local value = 0
    local maxValue = 1
    local tooltip = nil
    local buffInfo = nil
    if buff.func then
        value, maxValue = ReturnBuffTracker[buff.func](ReturnBuffTracker, buff)
    else
        value, maxValue, _, buffInfo = ReturnBuffTracker:CheckBuff(buff)
        if buffInfo.PlayersWithoutBuff[2] then
            --print(buffInfo.PlayersWithoutBuff[2].name)
           -- buff.bar.buffButton:SetAttribute("unit",
            --                                 "viking")
        else
           -- buff.bar.buffButton:SetAttribute("unit", "Hunex")
        end

    end

    if buffInfo then
        tooltip = ReturnBuffTracker:BuildTooltip(buffInfo)
    end

    if value and maxValue and maxValue > 0 then
        buff.bar:Update(value, maxValue,
                        tooltip)
    else
        buff.bar:Update(0, 1, nil)
    end

end

function ReturnBuffTracker:BuildTooltip(buffInfo)
    local tooltip = {}
    if IsShiftKeyDown() then
        tinsert(tooltip, "Players with buff:")
        for _, p in ipairs(buffInfo.PlayersWithBuff) do
            tinsert(tooltip, p.name)
        end
    else
        tinsert(tooltip, "Players without buff:")
        for _, p in ipairs(buffInfo.PlayersWithoutBuff) do
            tinsert(tooltip, p.name)
        end
    end

    return tooltip
end

function ReturnBuffTracker:Contains(tab, val)
    if not tab then return true end

    for key, value in pairs(tab) do if value == val then return true end end

    return false
end

function ReturnBuffTracker:CheckHideIfNotInRaid()
    if not ReturnBuffTracker.db.profile.hideNotInRaid or IsInRaid() then
        if not ReturnBuffTracker.mainFrame:IsVisible() then
            ReturnBuffTracker.mainFrame:Show()
        end
        return true
    else
        if ReturnBuffTracker.mainFrame:IsVisible() then
            ReturnBuffTracker.mainFrame:Hide()
        end
        return false
    end
end

