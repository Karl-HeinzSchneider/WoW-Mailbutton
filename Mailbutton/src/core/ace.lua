local appName, app = ...
local addon = {}
LibStub("AceAddon-3.0"):NewAddon(addon, appName, "AceConsole-3.0", "AceEvent-3.0")
app.addon = addon

function addon:OnInitialize()
    app.db = LibStub("AceDB-3.0"):New("MailbuttonDB", app.dbDefaults, true)
    self.db = app.db
    app.NormalizeRecipients(app.db.factionrealm)
    app.logger:setLevel(app.db.profile.logLevel)
    app.options:Register()
    self:RegisterChatCommand("mailbutton", "OnSlashCommand")
    self:RegisterChatCommand("mb", "OnSlashCommand")
    self:RegisterChatCommand("mbadd", function(input)
        app.recipients:Add(input)
    end)
    self:RegisterChatCommand("mbremove", function(input)
        app.recipients:Remove(input)
    end)
end

function addon:OnEnable()
    app.mail.suspended = false
    self:RegisterEvent("ADDON_LOADED", "RefreshMail")
    self:RegisterEvent("MAIL_SHOW", "RefreshMail")
    self:RegisterEvent("MAIL_CLOSED", function()
        app.db.factionrealm.showRemoveButtons = false
        app.mail:CloseDialog()
        app.mail:Refresh()
    end)
    self:RefreshMail()
end

function addon:RefreshMail()
    app.mail:Refresh()
end

function addon:OnDisable()
    app.mail.suspended = true
    app.mail:Hide()
end

function addon:OnSlashCommand(input)
    local command, name = input:match("^%s*(%S*)%s*(.-)%s*$")
    command = command:lower()
    if command == "add" then
        app.recipients:Add(name)
    elseif command == "remove" then
        app.recipients:Remove(name)
    elseif command == "list" then
        app.logger:chat("Recipients: %s", table.concat(app.recipients:List(), ", "))
    elseif command == "loglevel" then
        if app.logger:setLevel(name) then
            app.db.profile.logLevel = app.logger:getLevelName()
        end
    elseif command == "" or command == "options" then
        app.options:Open()
    else
        app.logger:chat("/mb add <recipient>, /mb remove <recipient>, /mb list. Also: /mbadd, /mbremove.")
    end
end
