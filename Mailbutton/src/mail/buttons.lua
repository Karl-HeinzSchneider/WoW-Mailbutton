local _, app = ...
local mail = { page = 1, buttons = {} }
app.mail = mail
local PAGE_SIZE = 8

local function button(parent, text, width, x, y, click)
    local frame = CreateFrame("Button", nil, parent)
    frame:SetSize(width, 30)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    frame:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    frame:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    frame:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    frame:SetNormalFontObject(GameFontNormal)
    frame:SetText(text)
    frame:SetScript("OnClick", click)
    return frame
end

function mail:SetRecipient(name)
    local edit = _G.SendMailNameEditBox
    if edit then
        edit:SetText(name)
        edit:ClearFocus()
    end
end

function mail:CloseDialog()
    if self.dialog then
        self.dialog:Hide()
    end
end

function mail:ShowDialog()
    if not self.dialog then
        local dialog = CreateFrame("Frame", nil, self.panel)
        dialog:SetSize(210, 100)
        dialog:SetPoint("TOPLEFT", self.panel, "TOPRIGHT", 5, 0)
        dialog:SetFrameStrata("DIALOG")
        local background = dialog:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetTexture("Interface\\Buttons\\WHITE8X8")
        background:SetVertexColor(0.08, 0.08, 0.08, 0.95)
        local label = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOP", 0, -8)
        label:SetText("Character[-Realm]")
        local edit = CreateFrame("EditBox", nil, dialog)
        edit:SetSize(190, 25)
        edit:SetPoint("TOP", 0, -30)
        edit:SetFontObject(GameFontHighlight)
        edit:SetAutoFocus(false)
        edit:SetScript("OnEscapePressed", function()
            dialog:Hide()
        end)
        local function accept()
            if app.recipients:Add(edit:GetText()) then
                dialog:Hide()
            end
        end
        edit:SetScript("OnEnterPressed", accept)
        dialog:SetScript("OnHide", function()
            edit:ClearFocus()
        end)
        button(dialog, "Add", 90, 5, -65, accept)
        button(dialog, "Close", 90, 110, -65, function()
            dialog:Hide()
        end)
        self.dialog, self.edit = dialog, edit
    end
    self.dialog:Show()
    self.edit:SetText("")
    self.edit:SetFocus()
end

function mail:Create()
    -- The mail UI can be loaded on demand; never create orphaned controls at login.
    local parent = _G.SendMailFrame
    if self.panel or not parent or not _G.SendMailNameEditBox then
        return
    end
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetSize(150, 330)
    panel:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 0)
    self.panel = panel
    button(panel, "Clear", 110, 0, 0, function()
        self:SetRecipient("")
    end)
    for index = 1, PAGE_SIZE do
        local row = button(panel, "", 110, 0, -index * 32, function(frame)
            self:SetRecipient(frame.recipient)
        end)
        row.remove = button(row, "X", 30, 112, 0, function()
            app.recipients:Remove(row.recipient)
        end)
        self.buttons[index] = row
    end
    button(panel, "+", 50, 0, -288, function()
        self:ShowDialog()
    end)
    button(panel, "-", 50, 60, -288, function()
        app.db.factionrealm.showRemoveButtons = not app.db.factionrealm.showRemoveButtons
        self:Refresh()
    end)
    self.previous = button(panel, "<", 50, 0, -320, function()
        self.page = self.page - 1
        self:Refresh()
    end)
    self.next = button(panel, ">", 50, 60, -320, function()
        self.page = self.page + 1
        self:Refresh()
    end)
end

function mail:Refresh()
    if not app.db then
        return
    end
    self:Create()
    if not self.panel then
        return
    end
    local names = app.recipients:List()
    local pages = math.max(1, math.ceil(#names / PAGE_SIZE))
    self.page = math.max(1, math.min(self.page, pages))
    for index, row in ipairs(self.buttons) do
        local name = names[(self.page - 1) * PAGE_SIZE + index]
        row.recipient = name
        row:SetText(name or "")
        row:SetShown(name ~= nil)
        row.remove:SetShown(name ~= nil and app.db.factionrealm.showRemoveButtons)
    end
    self.previous:SetShown(pages > 1)
    self.next:SetShown(pages > 1)
    self.previous:SetEnabled(self.page > 1)
    self.next:SetEnabled(self.page < pages)
    self.panel:Show()
end

function mail:Hide()
    self:CloseDialog()
    if self.panel then
        self.panel:Hide()
    end
end
