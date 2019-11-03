local ReturnBuffTracker = LibStub("AceAddon-3.0"):GetAddon("ReturnBuffTracker")

local options = nil
local function getOptions()
    if options then return options end

    options = {
        type = "group",
        name = "Return Buff Tracker",
        args = {
            general = {
                type = "group",
                name = "General",
                inline = true,
                args = {
                    description = {
                        name = "",
                        type = "description",
                        image = "Interface\\AddOns\\ReturnBuffTracker\\media\\return",
                        imageWidth = 64,
                        imageHeight = 64,
                        width = "half",
                        order = 1
                    },
                    descriptiontext = {
                        name = "Return Buff Tracker by Irpa\nDiscord: https://discord.gg/SZYAKFy\nGithub: https://github.com/zorkqz/ReturnBuffTracker\n",
                        type = "description",
                        width = "full",
                        order = 1.1
                    },
                    headerGlobalSettings = {
                        name = "Global Settings",
                        type = "header",
                        width = "double",
                        order = 2
                    },
                    hideNotInRaid = {
                        name = "Hide when not in raid",
                        desc = "The buff tracker does not work outside of raids.",
                        type = "toggle",
                        order = 3,
                        get = function(self)
                            return ReturnBuffTracker.db.profile.hideNotInRaid
                        end,
                        set = function(self, value)
                            ReturnBuffTracker.db.profile.hideNotInRaid = value
                            ReturnBuffTracker:CheckHideIfNotInRaid()
                        end
                    },
                    headerBars = {
                        name = "Bars to show",
                        type = "header",
                        width = "double",
                        order = 4
                    },
                    playerBuffs = {
                        name = "Player buffs",
                        type = "group",
                        order = 5,
                        args = {

                            bars = {
                                type = "multiselect",
                                name = "",
                                desc = "",
                                order = 6,
                                values = ReturnBuffTracker.OptionBarNames,
                                get = function(self, bar)
                                    return
                                        not ReturnBuffTracker.db.profile
                                            .deactivatedBars[bar]
                                end,
                                set = function(self, bar, value)
                                    ReturnBuffTracker.db.profile.deactivatedBars[bar] =
                                        not value
                                    ReturnBuffTracker:UpdateBars()
                                end
                            },
                        }
                    },
                    worldBuffs = {
                        name = "World Buffs",
                        type = "group",
                        order = 6,
                        args = {

                            bars = {
                                type = "multiselect",
                                name = "",
                                desc = "",
                                order = 6,
                                values = ReturnBuffTracker.OptionBarNames,
                                get = function(self, bar)
                                    return
                                        not ReturnBuffTracker.db.profile
                                            .deactivatedBars[bar]
                                end,
                                set = function(self, bar, value)
                                    ReturnBuffTracker.db.profile.deactivatedBars[bar] =
                                        not value
                                    ReturnBuffTracker:UpdateBars()
                                end
                            },
                        }
                    },
                    consumables = {
                        name = "Consumables",
                        type = "group",
                        order = 7,
                        args = {

                            bars = {
                                type = "multiselect",
                                name = "",
                                desc = "",
                                order = 6,
                                values = ReturnBuffTracker.OptionBarNames,
                                get = function(self, bar)
                                    return
                                        not ReturnBuffTracker.db.profile
                                            .deactivatedBars[bar]
                                end,
                                set = function(self, bar, value)
                                    ReturnBuffTracker.db.profile.deactivatedBars[bar] =
                                        not value
                                    ReturnBuffTracker:UpdateBars()
                                end
                            },
                        }
                    }

                }
            }
        }
    }

    return options
end

function ReturnBuffTracker:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(
            ReturnBuffTracker.optFrames.ReturnBuffTracker)
        -- Workaround: https://www.wowinterface.com/forums/showthread.php?t=54599
        InterfaceOptionsFrame_OpenToCategory(
            ReturnBuffTracker.optFrames.ReturnBuffTracker)
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(ReturnBuffTracker,
                                                  "ReturnBuffTracker",
                                                  "ReturnBuffTracker", input)
    end
end

function ReturnBuffTracker:SetupOptions()
    ReturnBuffTracker.optFrames = {}
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ReturnBuffTracker",
                                                          getOptions)
    ReturnBuffTracker.optFrames.ReturnBuffTracker =
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ReturnBuffTracker",
                                                        "Return Buff Tracker",
                                                        nil, "general")
    ReturnBuffTracker:RegisterChatCommand("ReturnBuffTracker", "ChatCommand")
    ReturnBuffTracker:RegisterChatCommand("rbt", "ChatCommand")
end
