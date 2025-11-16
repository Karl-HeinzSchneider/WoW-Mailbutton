-- Vars
-- local buttonNames = {"Zímtschnecke", "test"}
local buttonTable = nil
local clearButton = nil
local plusButton = nil
local removeButton = nil

local maxButtons = 8
local removeShown = false

local sizeX = 100
local sizeY = 40
local paddingLeft = 5
local paddingRight = 5
local paddingTop = 3
local paddingBottom = 0

local colorTable = {
    ['yellow'] = '|c00ffff00',
    ['green'] = '|c0000ff00',
    ['orange'] = '|c00ffc400',
    ['red'] = '|c00ff0000'
}

-- Frame

local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')

function frame:OnEvent(event, arg1)
    if event == 'ADDON_LOADED' and arg1 == 'Mailbutton' then
        local version = GetAddOnMetadata('Mailbutton', 'Version')

        printAddonMessage(
            'Addon ' .. strColor('v' .. version, 'yellow') .. ' Loaded, type ' .. strColor('/mb', 'green') ..
                ' for command list')

        -- default Value
        if buttonNames == nil then buttonNames = {} end

        updateButtons()
    end
end
frame:SetScript('OnEvent', frame.OnEvent)

-- Buttons

function updateButtons()
    if clearButton == nil then clearButton = addClearButton() end

    if buttonTable == nil then
        buttonTable = {}
        for i = 1, maxButtons do
            local newBtn = addButton(i)
            table.insert(buttonTable, newBtn)
        end
    end

    if plusButton == nil then plusButton = addPlusButton(maxButtons + 1) end

    if removeButton == nil then removeButton = addRemoveToggleButton(maxButtons + 1) end

    for index, v in ipairs(buttonTable) do
        local btn = buttonTable[index]

        if buttonNames[index] then
            btn:SetText(buttonNames[index])
            btn:Show()
        else
            btn:SetText('EMPTY')
            btn:Hide()
        end
    end
end

function addClearButton()
    local btn = CreateFrame('Button', 'mbClearButton', SendMailFrame, 'UIPanelButtonTemplate')
    btn:SetSize(sizeX, sizeY)
    btn:SetPoint('TOPRIGHT', SendMailFrame, sizeX / 2 + paddingLeft, paddingTop)
    btn:SetText('Clear')
    btn:SetScript('OnClick', function(self, button)
        btnClearClicked()
    end)

    return btn
end

function addButton(index)
    local btn = CreateFrame('Button', 'mbButton' .. index, SendMailFrame, 'UIPanelButtonTemplate')
    btn:SetSize(sizeX, sizeY)
    btn:SetPoint('TOPRIGHT', SendMailFrame, sizeX / 2 + paddingLeft, -1 * index * (sizeY + paddingBottom) + paddingTop)
    btn:SetText('EMPTY')
    btn:SetScript('OnClick', function(self, button)
        btnNameClicked(index)
    end)

    local remove = CreateFrame('Button', 'mbButtonRemove' .. index, btn, 'UIPanelButtonTemplate')
    remove:SetSize(sizeY, sizeY)
    remove:SetPoint('RIGHT', btn, sizeY, 0)
    remove:SetText('X')
    remove:SetScript('OnClick', function(self, button)
        btnRemoveClicked(index)
    end)

    btn.removeBtn = remove
    btn.removeBtn:Hide()

    return btn
end

function addPlusButton(index)
    local btn = CreateFrame('Button', 'mbAddButton', SendMailFrame, 'UIPanelButtonTemplate')
    btn:SetSize(sizeX / 2, sizeY)
    btn:SetPoint('TOPRIGHT', SendMailFrame, paddingLeft, -1 * index * (sizeY + paddingBottom) + paddingTop)
    btn:SetText('+')
    btn:SetScript('OnClick', function(self, button)
        btnPlusClicked()
    end)

    return btn
end

function addRemoveToggleButton(index)
    local btn = CreateFrame('Button', 'mbRemoveButton', SendMailFrame, 'UIPanelButtonTemplate')
    btn:SetSize(sizeX / 2, sizeY)
    btn:SetPoint('TOPRIGHT', SendMailFrame, sizeX / 2 + paddingLeft, -1 * index * (sizeY + paddingBottom) + paddingTop)
    btn:SetText('-')
    btn:SetScript('OnClick', function(self, button)
        btnRemoveToggleClicked()
    end)

    return btn
end

-- Button functions

function btnClearClicked()
    setMailName('')
end

function btnNameClicked(index)
    setMailName(buttonNames[index])
end

function btnPlusClicked()
    local popup = StaticPopup_Show('MAILBUTTON_PLUS')
end

function btnRemoveToggleClicked()
    removeShown = not removeShown
    showRemoveButtons(removeShown)
end

function btnRemoveClicked(index)
    if buttonNames[index] then
        local name = buttonNames[index]

        local popup = StaticPopup_Show('MAILBUTTON_REMOVE')
        if popup then
            popup.text:SetText('Remove Mailbutton for ' .. strColor(name, 'yellow') .. '?')
            popup.data = name
        end
    end
end

--
function showRemoveButtons(bShow)
    for index, v in ipairs(buttonTable) do
        local btn = buttonTable[index]
        local removeBtn = btn.removeBtn

        if buttonNames[index] then
            if bShow then
                removeBtn:Show()
            else
                removeBtn:Hide()
            end
        else
        end
    end
end

-- popup
-- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes
StaticPopupDialogs['MAILBUTTON_PLUS'] = {
    text = 'Enter Charactername to add as Button',
    button1 = 'Add',
    button2 = 'Close',
    OnShow = function(self, data)
        self.editBox:SetText('')
        self.editBox:SetAutoFocus(true)
    end,
    OnAccept = function(self, data, data2)
        local text = self.editBox:GetText()
        if text and not (text == '') then
            addButtonName(text)
            updateButtons()
        else
            printAddonMessage('ERROR - input correct Charactername!')
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    hasEditBox = true
}

StaticPopupDialogs['MAILBUTTON_REMOVE'] = {
    text = 'Remove XY?',
    button1 = 'Remove',
    button2 = 'Close',
    OnShow = function(self, data)
    end,
    OnAccept = function(self, data, data2)
        removeButtonName(data)
        updateButtons()
        removeShown = false
        showRemoveButtons(removeShown)
    end,
    OnCancel = function(self, data, data2)
        removeShown = false
        showRemoveButtons(removeShown)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}
-- Util WoW

function setMailName(name)
    SendMailNameEditBox:SetText(name)
end

function printAddonMessage(str)
    local pre = 'Mailbutton:  '
    pre = strColor(pre, 'yellow')
    print(pre .. str)
end

function listCommands()
    printAddonMessage('Commands:')

    local commandTable = {}
    commandTable[1] = {['cmd'] = '/mb', ['arg'] = nil, ['descr'] = 'to display Help (THIS)'}
    commandTable[2] = {['cmd'] = '/mbadd', ['arg'] = 'charactername', ['descr'] = 'to add Mailbutton'}
    commandTable[3] = {['cmd'] = '/mbremove', ['arg'] = 'charactername', ['descr'] = 'to remove Mailbutton'}

    for index, v in ipairs(commandTable) do
        local cmdMessage = strColor(v['cmd'], 'green')

        if v['arg'] then cmdMessage = cmdMessage .. ' ' .. strColor(v['arg'], 'orange') end

        cmdMessage = cmdMessage .. ' ' .. v['descr']

        printAddonMessage(cmdMessage)
    end
end

function strColor(str, color)
    if colorTable[color] then
        local color = colorTable[color]
        return color .. str .. '|r'
    end

    return str
end

-- Tablestuff

function addButtonName(name)
    name = makeUppercase(name)
    if tableHasEntry(buttonNames, name) then
        printAddonMessage('...')
    else
        table.insert(buttonNames, name)
        table.sort(buttonNames)
        printAddonMessage('added ' .. strColor(name, 'orange') .. '!')
    end
end

function removeButtonName(name)
    name = makeUppercase(name)
    if tableHasEntry(buttonNames, name) then
        tableRemoveEntry(buttonNames, name)
        printAddonMessage('removed ' .. strColor(name, 'orange') .. '!')
    else
        printAddonMessage('...')
    end
end

-- Util

function tableHasEntry(t, entry)
    for _, v in ipairs(t) do if v == entry then return true end end
    return false
end

function tableRemoveEntry(t, entry)
    for index, v in ipairs(t) do
        -- print(index .. '-' .. v)
        if v == entry then
            -- print('FOUND ' .. v .. " - " ..index)
            table.remove(t, index)
            return
        end
    end
end

function makeUppercase(str)
    return str:sub(1, 1):upper() .. str:sub(2)
end

-- SLASH commands

-- Info
SLASH_INFO1 = '/mb'
SlashCmdList['INFO'] = function(arg1)
    -- cmds
    listCommands()
    -- overview
    if buttonNames[1] then
        local nameStr = ''
        for _, name in ipairs(buttonNames) do nameStr = nameStr .. strColor(name, 'orange') .. ', ' end
        nameStr = nameStr:sub(1, -3)
        printAddonMessage('current Buttons: ' .. nameStr)
    else
        -- local notFoundMessage = 'no Buttons found - use /mbadd NAME to add Buttons!'
        -- printAddonMessage(notFoundMessage)
    end
end

-- Add Button
SLASH_ADD1 = '/mbadd'
SlashCmdList['ADD'] = function(arg1)
    -- overview
    if (string.len(arg1) < 1) then
        printAddonMessage(strColor('/mbadd', 'red') .. ' - Name Missing!')
    else
        -- printAddonMessage('/mbadd ' .. arg1)
        addButtonName(arg1)
        updateButtons()
    end
end

-- Remove Button
SLASH_REMOVE1 = '/mbremove'
SlashCmdList['REMOVE'] = function(arg1)
    -- overview
    if (string.len(arg1) < 1) then
        printAddonMessage(strColor('/mbremove', 'red') .. ' - Name Missing!')
    else
        -- printAddonMessage('/mbremove ' .. arg1)
        removeButtonName(arg1)
        updateButtons()
    end
end
