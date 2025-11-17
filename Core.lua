local addonName, addonTable = ...;
local MB = LibStub('AceAddon-3.0'):NewAddon('MailButton', 'AceConsole-3.0')
local L = LibStub("AceLocale-3.0"):NewLocale("MailButton", "enUS", true)

addonTable.MB = MB;
addonTable.L = LibStub("AceLocale-3.0"):GetLocale("MailButton");

local defaults = {profile = {bestnumber = 42}}

function MB:OnInitialize()
    -- Called when the addon is loaded
    self:Print('MailButton OnInitialize!')
    self.db = LibStub('AceDB-3.0'):New('MailbuttonDB', defaults, true)
    local db = self.db.profile
    -- self:SetupOptions()
    -- self:RegisterSlashCommands()
    -- self:InitVersionCheck()
    self:SetupButtons()
end

function MB:OnEnable()
    -- Called when the addon is enabled
    self:Print('MailButton enabled!')
    -- self:ShowStartMessage()
end

function MB:OnDisable()
    -- Called when the addon is disabled
end

-- function MB:UpdateState(state)
--     self.state = state;
--     self:Update();
-- end

function MB:Update()
    self:Print('MailButton Update()')

    local db = self.db.factionrealm;
    local showRemoveButtons = db.showRemoveButtons;

    db.nameTable = db.nameTable or {};
    local nameTable = db.nameTable;
    table.sort(nameTable)
    local count = #nameTable

    local buttonTable = self.ButtonTable

    for i = 1, count do
        --
        local btn = buttonTable[i];
        btn.removeBtn:SetShown(not showRemoveButtons)
        -- btn:Show()
    end

    for i = count + 1, 8 do
        --
        local btn = buttonTable[i];
        btn.removeBtn:SetShown(not showRemoveButtons)
        -- btn:Hide()
    end
end

function MB:RemoveToggleClicked()
    self:Print('MailButton RemoveToggleClicked()')

    local db = self.db.factionrealm;
    -- local showRemoveButtons = db.showRemoveButtons;
    db.showRemoveButtons = not db.showRemoveButtons;

    self:Update()
end

local function setMailName(name)
    SendMailNameEditBox:SetText(name)
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
        btn:SetScript('OnClick', function(_, button)
            setMailName('')
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
            btn:SetScript('OnClick', function(_, button)
                -- btnNameClicked(index)
            end)

            local remove = CreateFrame('Button', 'MailButtonButtonRemove' .. index, btn, 'UIPanelButtonTemplate')
            remove:SetSize(sizeY, sizeY)
            remove:SetPoint('RIGHT', btn, sizeY, 0)
            remove:SetText('X')
            remove:SetScript('OnClick', function(self, button)
                -- btnRemoveClicked(index)
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
        btn:SetScript('OnClick', function(_, button)
            -- btnPlusClicked()
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
        btn:SetScript('OnClick', function(_, button)
            -- btnRemoveToggleClicked()
            self:RemoveToggleClicked()
        end)
    end
end

