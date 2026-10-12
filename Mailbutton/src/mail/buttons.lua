local _, app = ...
local mail = { page = 1, buttons = {} }
app.mail = mail
local PAGE_SIZE = 8
local BUTTON_HEIGHT = 24
local CONTROL_WIDTH = 40
local CONTROL_GAP = 6
local MINIMUM_WIDTH = CONTROL_WIDTH * 3 + CONTROL_GAP * 2

local function button(parent, text, width, x, y, click)
    local frame = CreateFrame("Button", nil, parent)
    frame:SetSize(width, BUTTON_HEIGHT)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    -- Blizzard's panel art is three-sliced: fixed 12px caps, stretchable middle.
    -- Fixed-width end caps preserve the corners as recipient labels grow.
    local left = frame:CreateTexture(nil, "BACKGROUND")
    left:SetWidth(12)
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetTexCoord(0, 0.09375, 0, 0.6875)
    local right = frame:CreateTexture(nil, "BACKGROUND")
    right:SetWidth(12)
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetTexCoord(0.53125, 0.625, 0, 0.6875)
    local middle = frame:CreateTexture(nil, "BACKGROUND")
    middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
    middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
    middle:SetTexCoord(0.09375, 0.53125, 0, 0.6875)
    local function setState(state)
        local path = "Interface\\Buttons\\UI-Panel-Button-" .. state
        left:SetTexture(path)
        middle:SetTexture(path)
        right:SetTexture(path)
    end
    frame:SetScript("OnMouseDown", function(self)
        if self:IsEnabled() then
            setState("Down")
        end
    end)
    frame:SetScript("OnMouseUp", function(self)
        setState(self:IsEnabled() and "Up" or "Disabled")
    end)
    frame:SetScript("OnEnable", function()
        setState("Up")
    end)
    frame:SetScript("OnDisable", function()
        setState("Disabled")
    end)
    frame:SetScript("OnHide", function(self)
        setState(self:IsEnabled() and "Up" or "Disabled")
    end)
    setState("Up")
    frame:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    frame:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -2)
    label:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 2)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    frame:SetFontString(label)
    frame:SetNormalFontObject(GameFontNormal)
    frame:SetHighlightFontObject(GameFontHighlight)
    frame:SetDisabledFontObject(GameFontDisable)
    frame:SetText(text)
    frame:SetScript("OnClick", click)
    return frame
end

app.CreateButton = button

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
        dialog:SetSize(280, 130)
        dialog:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 0, -35)
        dialog:SetFrameStrata("DIALOG")
        local background = dialog:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetTexture("Interface\\Buttons\\WHITE8X8")
        background:SetVertexColor(0.08, 0.08, 0.08, 0.95)
        local label = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOP", 0, -8)
        label:SetText("Mail recipient (e.g. " .. app.recipients:Example() .. ")")
        local edit = CreateFrame("EditBox", nil, dialog)
        edit:SetSize(250, 28)
        edit:SetPoint("TOP", 0, -40)
        edit:SetFontObject(GameFontHighlight)
        edit:SetTextInsets(6, 6, 0, 0)
        local inputBackground = edit:CreateTexture(nil, "BACKGROUND")
        inputBackground:SetAllPoints()
        inputBackground:SetTexture("Interface\\Buttons\\WHITE8X8")
        inputBackground:SetVertexColor(0.2, 0.2, 0.2, 1)
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
        button(dialog, "Add", 120, 15, -85, accept)
        button(dialog, "Close", 120, 145, -85, function()
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
    panel:SetSize(MINIMUM_WIDTH + 36, 350)
    panel:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 0)
    self.panel = panel
    self.measurement = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.measurement:Hide()
    self.clear = button(panel, "Clear", MINIMUM_WIDTH, 0, 0, function()
        self:SetRecipient("")
    end)
    for index = 1, PAGE_SIZE do
        local row = button(panel, "", MINIMUM_WIDTH, 0, -index * 32, function(frame)
            self:SetRecipient(frame.recipient)
        end)
        row.remove = button(row, "X", 30, 0, 0, function()
            app.recipients:Remove(row.recipient)
        end)
        row.remove:ClearAllPoints()
        row.remove:SetPoint("TOPLEFT", row, "TOPRIGHT", 2, 0)
        self.buttons[index] = row
    end
    self.add = button(panel, "+", CONTROL_WIDTH, 0, -288, function()
        self:ShowDialog()
    end)
    self.removeToggle = button(panel, "-", CONTROL_WIDTH, CONTROL_WIDTH + CONTROL_GAP, -288, function()
        app.db.factionrealm.showRemoveButtons = not app.db.factionrealm.showRemoveButtons
        self:Refresh()
    end)
    self.options = button(panel, "", CONTROL_WIDTH, (CONTROL_WIDTH + CONTROL_GAP) * 2, -288, function()
        app.options:Open()
    end)
    local icon = self.options:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\WorldMap\\GEAR_64GREY")
    self.previous = button(panel, "<", 32, 0, -320, function()
        self.page = self.page - 1
        self:Refresh()
    end)
    self.next = button(panel, ">", 32, 38, -320, function()
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
    -- Measure every saved recipient, so changing pages cannot change column width.
    local width = MINIMUM_WIDTH
    self.measurement:SetText("Clear")
    width = math.max(width, math.ceil(self.measurement:GetStringWidth()) + 24)
    for _, name in ipairs(names) do
        self.measurement:SetText(name)
        width = math.max(width, math.ceil(self.measurement:GetStringWidth()) + 24)
    end
    self.clear:SetWidth(width)
    self.panel:SetWidth(width + 36)
    for _, row in ipairs(self.buttons) do
        row:SetWidth(width)
    end
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
