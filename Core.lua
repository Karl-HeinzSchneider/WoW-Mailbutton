local addonName, addonTable = ...;
local MB = LibStub('AceAddon-3.0'):NewAddon('MailButton', 'AceConsole-3.0')
local L = LibStub("AceLocale-3.0"):NewLocale("MailButton", "enUS", true)

addonTable.MB = MB;
addonTable.L = LibStub("AceLocale-3.0"):GetLocale("MailButton");

local defaults = {profile = {bestnumber = 42}, factionrealm = {showRemoveButtons = false, nameTable = {}}}

function MB:OnInitialize()
    -- Called when the addon is loaded
    -- self:Print('MailButton OnInitialize!')
    self.db = LibStub('AceDB-3.0'):New('MailbuttonDB', defaults, true)
    local db = self.db.profile
    -- self:SetupOptions()
    -- self:RegisterSlashCommands()
    -- self:InitVersionCheck()
    self:SetupButtons()
    self:SetupCommands()
end

function MB:OnEnable()
    -- Called when the addon is enabled
    -- self:Print('MailButton enabled!')
    -- self:ShowStartMessage()

    local db = self.db.factionrealm;
    db.showRemoveButtons = false;

    self:Update()
end

function MB:OnDisable()
    -- Called when the addon is disabled
end

-- function MB:UpdateState(state)
--     self.state = state;
--     self:Update();
-- end

function MB:Update()
    -- self:Print('MailButton Update()')

    -- DevTools_Dump(self.db.factionrealm)

    local db = self.db.factionrealm;
    local showRemoveButtons = db.showRemoveButtons;

    -- db.nameTable = db.nameTable or {};
    local nameTable = db.nameTable;
    table.sort(nameTable)

    local buttonTable = self.ButtonTable

    local index = 1;
    for k, v in pairs(nameTable) do
        -- print(k, v, index)
        --
        -- local btn = buttonTable[i];
        local btn = buttonTable[index]
        btn.removeBtn:SetShown(showRemoveButtons)
        btn:Show()
        btn:SetText(k)

        index = index + 1;
    end

    for i = index, 8 do
        --
        -- print('h', i)
        local btn = buttonTable[i];
        btn.removeBtn:SetShown(showRemoveButtons)
        btn:Hide()
    end
end

function MB:AddButtonClicked()
    local popup = StaticPopup_Show('MAILBUTTON_PLUS')
end

function MB:RemoveToggleClicked()
    -- self:Print('MailButton RemoveToggleClicked()')

    local db = self.db.factionrealm;
    -- local showRemoveButtons = db.showRemoveButtons;
    db.showRemoveButtons = not db.showRemoveButtons;

    self:Update()
end

local function capitalizeFirst(name)
    if not name or name == "" then return name end
    return string.upper(string.sub(name, 1, 1)) .. string.lower(string.sub(name, 2))
end

function MB:AddCharacter(name)
    local db = self.db.factionrealm;
    local nameTable = db.nameTable;

    name = capitalizeFirst(name)
    nameTable[name] = true;
end

function MB:RemoveCharacter(name)
    local db = self.db.factionrealm;
    local nameTable = db.nameTable;

    name = capitalizeFirst(name)
    nameTable[name] = nil;
end

function MB:SetMailName(name)
    SendMailNameEditBox:SetText(name)
    SendMailNameEditBox:ClearFocus()
end

function MB:SetupButtons()
    local maxButtons = 8

    local sizeX = 100
    local sizeY = 40
    local paddingLeft = 5
    local paddingRight = 5
    local paddingTop = 3
    local paddingBottom = 0

    local index = 0;

    -- clear
    do
        local btn = CreateFrame('Button', 'MailButtonClearButton', SendMailFrame, 'UIPanelButtonTemplate')
        btn:SetSize(sizeX, sizeY)
        btn:SetPoint('TOPRIGHT', SendMailFrame, sizeX / 2 + paddingLeft, paddingTop)
        btn:SetText('Clear')
        btn:SetScript('OnClick', function(self, button)
            MB:SetMailName('')
        end)
    end

    -- buttons
    do
        local buttonTable = {}
        for i = 1, maxButtons do
            index = i;
            local btn = CreateFrame('Button', 'MailButtonButton' .. index, SendMailFrame, 'UIPanelButtonTemplate')
            btn:SetSize(sizeX, sizeY)
            btn:SetPoint('TOPRIGHT', SendMailFrame, sizeX / 2 + paddingLeft,
                         -1 * index * (sizeY + paddingBottom) + paddingTop)
            btn:SetText('EMPTY')
            btn:SetScript('OnClick', function(self, button)
                MB:SetMailName(self:GetText())
            end)

            local remove = CreateFrame('Button', 'MailButtonButtonRemove' .. index, btn, 'UIPanelButtonTemplate')
            remove:SetSize(sizeY, sizeY)
            remove:SetPoint('RIGHT', btn, sizeY, 0)
            remove:SetText('X')
            remove:SetScript('OnClick', function(self, button)
                MB:RemoveCharacter(btn:GetText())
                MB:Update()
            end)

            btn.removeBtn = remove
            -- btn.removeBtn:Hide()

            table.insert(buttonTable, btn)
        end
        self.ButtonTable = buttonTable;
    end

    -- add button
    do
        index = maxButtons + 1;
        local btn = CreateFrame('Button', 'MailButtonAddButton', SendMailFrame, 'UIPanelButtonTemplate')
        btn:SetSize(sizeX / 2, sizeY)
        btn:SetPoint('TOPRIGHT', SendMailFrame, paddingLeft, -1 * index * (sizeY + paddingBottom) + paddingTop)
        btn:SetText('+')
        btn:SetScript('OnClick', function(self, button)
            MB:AddButtonClicked()
        end)
    end

    -- remove button
    do
        index = maxButtons + 1;
        local btn = CreateFrame('Button', 'MailButtonRemoveButton', SendMailFrame, 'UIPanelButtonTemplate')
        btn:SetSize(sizeX / 2, sizeY)
        btn:SetPoint('TOPRIGHT', SendMailFrame, sizeX / 2 + paddingLeft,
                     -1 * index * (sizeY + paddingBottom) + paddingTop)
        btn:SetText('-')
        btn:SetScript('OnClick', function(self, button)
            MB:RemoveToggleClicked()
        end)
    end
end

function MB:SetupCommands()
end

-- popup
-- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes
StaticPopupDialogs['MAILBUTTON_PLUS'] = {
    text = 'Enter Charactername to add as Button',
    button1 = 'Add',
    button2 = 'Close',
    OnShow = function(self, data)
        self.editBox = self.editBox or self.EditBox
        self.editBox:SetText('')
        self.editBox:SetAutoFocus(true)
    end,
    OnAccept = function(self, data, data2)
        local text = self.editBox:GetText()
        if text and not (text == '') then
            MB:AddCharacter(text)
            MB:Update()
        else
            MB:Print('ERROR - input correct Charactername!')
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    hasEditBox = true
}

-- StaticPopupDialogs['MAILBUTTON_REMOVE'] = {
--     text = 'Remove XY?',
--     button1 = 'Remove',
--     button2 = 'Close',
--     OnShow = function(self, data)
--     end,
--     OnAccept = function(self, data, data2)
--         removeButtonName(data)
--         updateButtons()
--         removeShown = false
--         showRemoveButtons(removeShown)
--     end,
--     OnCancel = function(self, data, data2)
--         removeShown = false
--         showRemoveButtons(removeShown)
--     end,
--     timeout = 0,
--     whileDead = true,
--     hideOnEscape = true
-- }

