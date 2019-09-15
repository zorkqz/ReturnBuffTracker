local ReturnBuffTracker = LibStub("AceAddon-3.0"):NewAddon("ReturnBuffTracker", "AceConsole-3.0")

local defaults = {
	profile = {
		position = nil,
		width = 180,
		hideNotInRaid = true,
		deactivatedBars = {  }
	}
}

local classNames = {
	WARRIOR = "Warrior",
	ROGUE = "Rogue",
	HUNTER = "Hunter",
	WARLOCK = "Warlock",
	PRIEST = "Priest",
	PALADIN = "Paladin",
	DRUID = "Druid",
	MAGE = "Mage"
}

local Buffs = {

	[01] = { name = "Alive", shortName = "Alive", func = "CheckAlive", color = { r = 0.3, g = 1, b = 0.3 } },
	
	[02] = { name = "Healer Mana", shortName = "Healer", optionText = "Healer Mana", func = "CheckMana", color = { r = 0.4, g = 0.6, b = 1 },
				classes = { "PRIEST", "PALADIN", "DRUID" } },
	
	[03] = { name = "DPS Mana", shortName = "DPS", optionText = "DPS Mana", func = "CheckMana", color = { r = 0.2, g = 0.2, b = 1 },
				classes = { "HUNTER", "WARLOCK", "MAGE" } },

	[04] = { name = "Arcane Intellect", shortName = "Intellect", color = { r = 0.41, g = 0.8, b = 0.94 },
				buffNames = { "Arcane Intellect", "Arcane Brilliance" },
				classes = { "HUNTER", "WARLOCK", "PRIEST", "PALADIN", "DRUID", "MAGE" } },
			
	[05] = { name = "Mark of the Wild", shortName = "MotW", color = { r = 1.0, g = 0.49, b = 0.04 },
				buffNames = { "Mark of the Wild", "Gift of the Wild" } },
			
	[06] = { name = "Power Word: Fortitude", shortName = "Fortitude", color = { r = 1.0, g = 1.0, b = 1.0 },
				buffNames = { "Power Word: Fortitude", "Prayer of Fortitude" } },
	
	[07] = { name = "Divine Spirit", shortName = "Divine Spirit", color = { r = 1.0, g = 1.0, b = 1.0 },
				buffNames = { "Divine Spirit", "Prayer of Spirit" },
				classes = { "PRIEST", "PALADIN", "DRUID", "MAGE" } },
	
	[08] = { name = "Shadow Protection", shortName = "Shadow Protection", color = { r = 0.6, g = 0.6, b = 0.6 },
				buffNames = { "Shadow Protection", "Prayer of Shadow Protection" } },
			
	[09] = { name = "Blessing of Kings", shortName = "Kings", color = { r = 0.96, g = 0.55, b = 0.73 },
				buffNames = { "Blessing of Kings", "Greater Blessing of Kings" },
				missingMode = "class" },	
			
	[10] = { name = "Blessing of Salvation", shortName = "Salvation", color = { r = 0.96, g = 0.55, b = 0.73 },
				buffNames = { "Blessing of Salvation", "Greater Blessing of Salvation" },
				missingMode = "class" },		

	[11] = { name = "Blessing of Wisdom", shortName = "Wisdom", color = { r = 0.96, g = 0.55, b = 0.73 },
				buffNames = { "Blessing of Wisdom", "Greater Blessing of Wisdom" },
				classes = {"HUNTER", "WARLOCK", "PRIEST", "PALADIN", "DRUID", "MAGE"},
				missingMode = "class" },

	[12] = { name = "Blessing of Might", shortName = "Might", color = { r = 0.96, g = 0.55, b = 0.73 },
				buffNames = { "Blessing of Might", "Greater Blessing of Might" },
				classes = {"WARRIOR", "ROGUE"},
				missingMode = "class" },

	[13] = { name = "Blessing of Light", shortName = "Light", color = { r = 0.96, g = 0.55, b = 0.73 },
				buffNames = { "Blessing of Light", "Greater Blessing of Light" },
				missingMode = "class" },	
				
	[14] = { name = "Blessing of Sanctuary", shortName = "Sanctuary", color = { r = 0.96, g = 0.55, b = 0.73 },
				buffNames = { "Blessing of Sanctuary", "Greater Blessing of Sanctuary" },
				missingMode = "class" },	

	[15] = { name = "Rallying Cry of the Dragonslayer", shortName = "Dragonslayer", color = { r = 0, g = 0, b = 0 } },	
	
	[16] = { name = "Songflower Serenade", shortName = "Songflower", color = { r = 0, g = 0, b = 0 } },	
	
	[17] = { name = "Greater Fire Protection Potion", shortName = "Fire Protection", color = { r = 1, g = 0, b = 0 } },	
	
	[18] = { name = "In Combat", shortName = "In Combat", color = { r = 1, g = 1, b = 1 }, func = "CheckInCombat" },	
	
	[19] = { name = "Soulstone Resurrection", shortName = "Soulstones", color = { r = 0.58, g = 0.51, b = 0.79 }, func = "CheckSoulstones" },			
}



function ReturnBuffTracker:OnInitialize()

	ReturnBuffTracker.OptionBarNames = {}
	for k, buff in ipairs(Buffs) do
		ReturnBuffTracker.OptionBarNames[buff.optionText or buff.text or buff.name] = buff.optionText or buff.text or buff.name
	end

	ReturnBuffTracker.db = LibStub("AceDB-3.0"):New("ReturnBuffTrackerDB", defaults, true)

	ReturnBuffTracker:SetupOptions()	
	ReturnBuffTracker:CreateMainFrame()
	
	for k, buff in ipairs(Buffs) do
		buff.bar = ReturnBuffTracker:CreateInfoBar(buff.text or buff.shortName, buff.color.r, buff.color.g, buff.color.b)
	end
	ReturnBuffTracker:UpdateBars()
	
	ReturnBuffTracker.nextTime = 0
	ReturnBuffTracker.updateFrame = CreateFrame("Frame")
	ReturnBuffTracker.updateFrame:SetScript("OnUpdate", ReturnBuffTracker.OnUpdate)
end

function ReturnBuffTracker:UpdateBars()
	local idx = 0
	for k, buff in ipairs(Buffs) do
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
	ReturnBuffTracker.nextTime = currentTime + 1
	
	if not ReturnBuffTracker:CheckHideIfNotInRaid() then
		return
	end
	
	for k, buff in ipairs(Buffs) do
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
		
end

function ReturnBuffTracker:CheckAlive()

	tooltip = {}
	tooltip[1] = "Dead: "
	tooltip[2] = "no one."
	local j = 2

	local aliveNumber = 0
	local totalNumber = 0
	for i = 1,40 do
		name = GetRaidRosterInfo(i)
		if name then
			totalNumber = totalNumber + 1
			if not UnitIsDeadOrGhost("raid" .. i) then
				aliveNumber = aliveNumber + 1
			else
				tooltip[j] = name
				j = j + 1
			end
		end		
	end
	return aliveNumber, totalNumber, tooltip
end

function ReturnBuffTracker:CheckMana(buff)
	local mana = 0
	local totalMana = 0
	for i = 1,40 do
		_, _, _, _, _, class = GetRaidRosterInfo(i)
		if class and ReturnBuffTracker:Contains(buff.classes, class) then	
			local unitPower = UnitPower("raid" .. i, 0)
			local unitPowerMax = UnitPowerMax("raid" .. i, 0)
			if unitPower and unitPowerMax and unitPowerMax > 0 then
				mana = mana + (unitPower / unitPowerMax)
				totalMana = totalMana + 1
			end
		end	
	end

	return mana, totalMana
end

function ReturnBuffTracker:CheckInCombat(buff)
	
	local inCombat = 0
	local total = 0
	local players = {}
	
	for i = 1,40 do
		name, _, group = GetRaidRosterInfo(i)
		if name and not UnitIsDead("raid" .. i) then
			total = total + 1
			if UnitAffectingCombat("raid" .. i) then
				inCombat = inCombat + 1
			else
				players[name] = { name = name, group = group }
			end
		end		
	end
	
	tooltip = {}
	tooltip[1] = "Not in Combat: "
	tooltip[2] = "no one."
		
	groups = {}	
	for k, player in pairs(players) do 
		if not groups[player.group] then
			groups[player.group] = { count = 0, text = "Group " .. player.group .. ":" }
		end
		groups[player.group].count = groups[player.group].count + 1
		if groups[player.group].count > 3 then
			groups[player.group].text = "Group " .. player.group
		else
			groups[player.group].text = groups[player.group].text .. " " .. player.name
		end
		
		for i, group in ipairs(groups) do
			tooltip[i + 1] = group.text
		end
	end
	
	return inCombat, total, tooltip
end

function ReturnBuffTracker:CheckSoulstones(buff)

	tooltip = {}
	tooltip[1] = "Soulstones: "
	tooltip[2] = "none."
	local j = 2
	
	for i = 1,40 do
		name = GetRaidRosterInfo(i)
		if name and ReturnBuffTracker:CheckUnitBuff("raid" .. i, buff) then
			tooltip[j] = name
			j = j + 1
		end		
	end

	return 1, 1, tooltip
end

function ReturnBuffTracker:CheckBuff(buff)
	local buffs = 0
	local totalBuffs = 0
	local missingBuffs = {}
	
	for i = 1,40 do
		name, _, group, _, _, class = GetRaidRosterInfo(i)
		if class and ReturnBuffTracker:Contains(buff.classes, class) then
			totalBuffs = totalBuffs + 1
			if ReturnBuffTracker:CheckUnitBuff("raid" .. i, buff) then
				buffs = buffs + 1
			else
				missingBuffs[name] = { name = name, group = group, class = class }
			end
		end	
	end
		
	tooltip = {}
	tooltip[1] = "Missing " .. buff.name .. ": "
	tooltip[2] = "no one."
		
	groups = {}	
	
    if buff.missingMode == "class" then
        for k, player in pairs(missingBuffs) do 
            if not groups[player.class] then
                groups[player.class] = { text = classNames[player.class] .. ":" }
            end
            groups[player.class].text = groups[player.class].text .. " " .. player.name
        end
    
        local i = 2
        for _, group in pairs(groups) do
            tooltip[i] = group.text
            i = i + 1
        end
    
    else
        
        for k, player in pairs(missingBuffs) do 
            if not groups[player.group] then
                groups[player.group] = { count = 0, text = "Group " .. player.group .. ":" }
            end
            groups[player.group].text = groups[player.group].text .. " " .. player.name
        end
                                  
        local j = 2
        for i, group in pairs(groups) do        
            tooltip[j] = group.text
            j = j + 1
        end
	end		
	
    --ReturnBuffTracker:Print("" .. buff.name .. ": " .. buffs .. "/" .. totalBuffs)
	return buffs, totalBuffs, tooltip
end

function ReturnBuffTracker:CheckUnitBuff(unit, buff)	
	for i = 1,40 do
		b = UnitBuff(unit, i);
		if (buff.buffNames and ReturnBuffTracker:Contains(buff.buffNames, b)) or buff.name == b then
			return true
		end
	end
	return false
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

