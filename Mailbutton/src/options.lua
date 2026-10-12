local _, app = ...
local options = {}
app.options = options

function options:Register()
    if self.panel then
        return
    end
    local panel = CreateFrame("Frame")
    panel.name = "Mailbutton"
    panel:Hide()
    self.panel = panel
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Mailbutton")
    local help = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    help:SetPoint("TOPLEFT", 16, -48)
    help:SetPoint("TOPRIGHT", -16, -48)
    help:SetJustifyH("LEFT")
    help:SetText(
        "Recipient buttons for this faction and realm. One recipient per line (e.g. "
            .. app.recipients:Example()
            .. ").\n"
            .. (app.recipients:IsDoubleNameClient() and "Use exactly a first and last name.\n" or "Use a single name, optionally Name-Realm.\n")
            .. "Edit, add or delete lines, then Save to replace your buttons.\nExport loads your saved list; use Ctrl+A / Ctrl+C to copy.\nPaste with Ctrl+V; Import adds names without removing existing buttons."
    )
    local scroll = CreateFrame("ScrollFrame", nil, panel)
    scroll:SetPoint("TOPLEFT", help, "BOTTOMLEFT", 0, -12)
    scroll:SetPoint("BOTTOMRIGHT", -16, 85)
    local background = scroll:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetTexture("Interface\\Buttons\\WHITE8X8")
    background:SetVertexColor(0.12, 0.12, 0.12, 1)
    local edit = CreateFrame("EditBox", nil, scroll)
    self.edit = edit
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(GameFontHighlight)
    edit:SetTextInsets(8, 8, 8, 8)
    edit:SetSize(400, 260)
    scroll:SetScrollChild(edit)
    scroll:SetScript("OnSizeChanged", function(_, width)
        edit:SetWidth(math.max(1, width))
    end)
    scroll:EnableMouseWheel(true)
    scroll:EnableMouse(true)
    scroll:SetScript("OnMouseDown", function()
        edit:SetFocus()
    end)
    scroll:SetScript("OnMouseWheel", function(_, delta)
        scroll:SetVerticalScroll(
            math.max(0, math.min(scroll:GetVerticalScrollRange(), scroll:GetVerticalScroll() - delta * 30))
        )
    end)
    edit:SetScript("OnCursorChanged", function(_, _, y, _, height)
        local offset = scroll:GetVerticalScroll()
        y = -y
        if y < offset then
            scroll:SetVerticalScroll(math.max(0, y))
        elseif y + height > offset + scroll:GetHeight() then
            scroll:SetVerticalScroll(y + height - scroll:GetHeight())
        end
    end)
    edit:SetScript("OnEscapePressed", function()
        edit:ClearFocus()
    end)
    panel:SetScript("OnHide", function()
        edit:ClearFocus()
    end)
    local status = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    status:SetPoint("BOTTOMLEFT", 16, 16)
    status:SetPoint("BOTTOMRIGHT", -16, 16)
    status:SetJustifyH("LEFT")
    local function export()
        edit:SetText(app.recipients:Export())
        scroll:SetVerticalScroll(0)
        status:SetText("Saved list loaded. Ctrl+A / Ctrl+C to copy.")
    end
    panel:SetScript("OnShow", export)
    local function apply(replace)
        local ok, message = app.recipients:Import(edit:GetText(), replace)
        status:SetText(ok and (replace and "Buttons saved." or "Recipients imported.") or message)
        if ok then
            edit:SetText(app.recipients:Export())
            edit:ClearFocus()
        end
    end
    local function action(text, x, callback)
        local control = app.CreateButton(panel, text, 100, 0, 0, callback)
        control:ClearAllPoints()
        control:SetPoint("BOTTOMLEFT", x, 48)
    end
    action("Save", 16, function()
        apply(true)
    end)
    action("Import", 124, function()
        apply(false)
    end)
    action("Export", 232, export)
    action("Undo", 340, function()
        if app.recipients:Undo() then
            edit:SetText(app.recipients:Export())
            edit:ClearFocus()
            scroll:SetVerticalScroll(0)
            status:SetText("Previous recipient list restored.")
        else
            status:SetText("Nothing to undo. Undo lasts until the next list edit or reload.")
        end
    end)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        self.category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(self.category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

function options:Open()
    if self.category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(self.category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.panel)
        InterfaceOptionsFrame_OpenToCategory(self.panel)
    else
        app.logger:chat("Open Mailbutton in the Blizzard addon options.")
    end
end
