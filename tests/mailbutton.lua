local app = { logger = { chat = function() end } }
local function load(path)
    assert(loadfile(path))("Mailbutton", app)
end
load("Mailbutton/src/core/db.lua")
local db = { nameTable = { Alice = true, Ignored = false, [1] = "Bob", [2] = "Zímtschnecke" } }
app.NormalizeRecipients(db)
assert(db.nameTable.Alice and db.nameTable.Bob and db.nameTable["Zímtschnecke"])
assert(not db.nameTable.Ignored and not db.nameTable[1])
app.db = { factionrealm = db }
local refreshes = 0
app.mail = {
    Refresh = function()
        refreshes = refreshes + 1
    end,
}
load("Mailbutton/src/mail/recipients.lua")
assert(not app.recipients:Validate("!!!"))
assert(not app.recipients:Validate("Name-!!!"))
assert(not app.recipients:Validate("!!!-Realm"))
assert(not app.recipients:Validate("Name-"))
assert(app.recipients:Validate(string.rep("é", 12)))
assert(not app.recipients:Validate(string.rep("é", 13)))
assert(app.recipients:Validate("Zímtschnecke-" .. string.rep("é", 64)))
assert(not app.recipients:Validate("Name-" .. string.rep("é", 65)))
-- ASCII case folding stays useful without collapsing accented spellings.
assert(app.recipients:Add("Élodie"))
assert(app.recipients:Add("élodie"))
assert(db.nameTable["Élodie"] and db.nameTable["élodie"])
assert(app.recipients:Remove("ÉLODIE"))
assert(app.recipients:Remove("élodie"))
assert(app.recipients:Add("  Alt-Realm  "))
assert(app.recipients:Add("alice"))
assert(#app.recipients:List() == 4)
GetBuildInfo = function()
    return "", "", "", 16001
end
assert(app.recipients:Example() == "Sylvanas Windrunner")
assert(not app.recipients:Validate("!!! ???"))
assert(not app.recipients:Validate("Sylvanas !!!"))
assert(app.recipients:Validate(string.rep("é", 32) .. " " .. string.rep("a", 32)))
assert(not app.recipients:Validate(string.rep("é", 33) .. " Windrunner"))
assert(not app.recipients:Validate("Sylvanas " .. string.rep("a", 33)))
assert(not app.recipients:Add("Sylvanas"))
assert(not app.recipients:Add("Sylvanas Windrunner Extra"))
assert(app.recipients:Add("  Sylvanas Windrunner  "))
assert(db.nameTable["Sylvanas Windrunner"])
assert(app.recipients:Add("sylvanas windrunner"))
assert(app.recipients:Remove(" SYLVANAS WINDRUNNER "))
assert(not app.recipients:Add("Peter\tMaier"))
assert(not app.recipients:Add("|Hlink"))
assert(app.recipients:Remove(" ALICE "))
assert(not db.nameTable.Alice)
GetBuildInfo = function()
    return "", "", "", 120000
end
assert(app.recipients:Example() == "Sylvanas")
assert(not app.recipients:Add("Sylvanas Windrunner"))
-- Project identity survives interface changes; the legacy fallback accepts patches.
WOW_PROJECT_CAMELOT = 18
WOW_PROJECT_ID = WOW_PROJECT_CAMELOT
assert(app.recipients:IsDoubleNameClient())
assert(app.recipients:Validate("Sylvanas Windrunner"))
assert(not app.recipients:Validate("Sylvanas"))
GetBuildInfo = nil
assert(app.recipients:IsDoubleNameClient())
WOW_PROJECT_ID = 1
assert(not app.recipients:IsDoubleNameClient())
for _, interface in ipairs({ 16000, 16001, 16002, 16099, "16002" }) do
    GetBuildInfo = function()
        return "", "", "", interface
    end
    assert(app.recipients:IsDoubleNameClient())
    assert(app.recipients:Validate("Sylvanas Windrunner"))
    assert(not app.recipients:Validate("Sylvanas"))
end
for _, interface in ipairs({ 15999, 16100, 11508, 20505, 50502, 120001, "invalid" }) do
    GetBuildInfo = function()
        return "", "", "", interface
    end
    assert(not app.recipients:IsDoubleNameClient())
    assert(app.recipients:Validate("Sylvanas"))
    assert(not app.recipients:Validate("Sylvanas Windrunner"))
end
WOW_PROJECT_CAMELOT = nil
WOW_PROJECT_ID = nil
GetBuildInfo = nil
assert(not app.recipients:IsDoubleNameClient())
GetBuildInfo = function()
    return "", "", "", nil
end
assert(not app.recipients:IsDoubleNameClient())
GetBuildInfo = function()
    return "", "", "", 16002
end
assert(app.recipients:IsDoubleNameClient())
GetBuildInfo = function()
    return "", "", "", 120000
end
for i = 1, 12 do
    assert(app.recipients:Add("Alt" .. i))
end
assert(#app.recipients:List() == 15)
-- No mail frames at login: creating any frame is an error.
CreateFrame = function()
    error("premature frame creation")
end
load("Mailbutton/src/mail/buttons.lua")
app.mail:Refresh()
assert(not app.mail.panel)
-- Fake frame objects to exercise deferred creation, pages, selection and removal.
local methods = {}
function methods:SetText(text)
    self.text = text
end
function methods:GetText()
    return self.text
end
function methods:SetShown(value)
    if value then
        self:Show()
    else
        self:Hide()
    end
end
function methods:SetEnabled(value)
    self.enabled = value
    local callback = self[value and "OnEnable" or "OnDisable"]
    if callback then
        callback(self)
    end
end
function methods:Show()
    local changed = not self.shown
    self.shown = true
    if changed and self.OnShow then
        self.OnShow(self)
    end
end
function methods:Hide()
    local changed = self.shown
    self.shown = false
    if changed and self.OnHide then
        self.OnHide(self)
    end
end
function methods:SetScript(event, callback)
    self[event] = callback
end
function methods:SetSize(width, height)
    self.width, self.height = width, height
end
function methods:SetWidth(width)
    local changed = self.width ~= width
    self.width = width
    if changed and self.OnSizeChanged then
        self.OnSizeChanged(self, width, self.height)
    end
end
function methods:GetWidth()
    return rawget(self, "width") or 1920
end
function methods:GetRight()
    return rawget(self, "right") or 500
end
function methods:GetEffectiveScale()
    return rawget(self, "scale") or 1
end
function methods:GetParent()
    return self.parent
end
function methods:SetScale(scale)
    self.scale = scale
end
function methods:StopMovingOrSizing() end
function methods:RegisterEvent(event)
    self.events = self.events or {}
    self.events[event] = true
end
hooksecurefunc = function(object, method, callback)
    local original = object[method]
    assert(type(original) == "function")
    object[method] = function(...)
        original(...)
        callback(...)
    end
end
function methods:GetScript(event)
    return self[event]
end
function methods:HookScript(event, callback)
    local original = self[event]
    self[event] = function(...)
        if original then
            original(...)
        end
        callback(...)
    end
end
function methods:SetClampedToScreen(value)
    self.clamped = value
end
function methods:SetWordWrap(value)
    self.wordWrap = value
end
function methods:SetOwner(owner)
    self.owner = owner
end
function methods:IsOwned(owner)
    return rawget(self, "owner") == owner
end
function methods:GetStringWidth()
    return #(self.text or "") * 7
end
local frame
function methods:CreateFontString()
    return frame("FontString", self)
end
function methods:CreateTexture()
    return frame("Texture", self)
end
function methods:GetNormalTexture()
    return frame()
end
function methods:GetPushedTexture()
    return frame()
end
function methods:GetHighlightTexture()
    return frame()
end
function methods:SetFontString(label)
    self.label = label
end
function methods:SetPoint(...)
    self.anchor = { ... }
end
function methods:SetJustifyH(value)
    self.justifyH = value
end
-- Explicitly supported API surface: unknown methods must fail, never become no-ops.
for _, method in ipairs({
    "SetTexCoord",
    "SetTexture",
    "SetVertexColor",
    "SetAllPoints",
    "SetJustifyV",
    "SetNormalFontObject",
    "SetHighlightFontObject",
    "SetDisabledFontObject",
    "SetFontObject",
    "SetTextInsets",
    "SetAutoFocus",
    "SetMultiLine",
    "EnableMouseWheel",
    "EnableMouse",
    "SetFrameStrata",
}) do
    methods[method] = function(self, ...)
        self.calls[method] = { ... }
    end
end
function methods:IsEnabled()
    return self.enabled
end
function methods:GetText()
    return self.text or ""
end
function methods:SetFocus()
    self.focused = true
end
function methods:ClearFocus()
    self.focused = false
end
function methods:ClearAllPoints()
    self.anchor = nil
end
function methods:SetScrollChild(child)
    self.scrollChild = child
end
function methods:GetHeight()
    return self.height
end
function methods:GetVerticalScroll()
    return self.offset
end
function methods:GetVerticalScrollRange()
    return self.range
end
function methods:SetVerticalScroll(offset)
    self.offset = offset
end
function methods:SetHighlightTexture(texture)
    self.highlightTexture = texture
end
frame = function(kind, parent)
    local result = setmetatable({
        kind = kind,
        parent = parent,
        children = {},
        calls = {},
        shown = true,
        enabled = true,
        offset = 0,
        range = 200,
        height = 100,
    }, {
        __index = function(_, key)
            if methods[key] then
                return methods[key]
            end
            if key:match("^[A-Z]") and not key:match("^On") then
                error("Unsupported frame method: " .. key)
            end
        end,
    })
    if parent then
        parent.children[#parent.children + 1] = result
    end
    return result
end
CreateFrame = function(kind, _, parent)
    assert(kind == "Frame" or kind == "Button" or kind == "EditBox" or kind == "ScrollFrame")
    return frame(kind, parent)
end
local supported, unsupported = pcall(function()
    frame():SetTexure("typo")
end)
assert(not supported and unsupported:find("Unsupported frame method: SetTexure", 1, true))
UIParent = frame()
SendMailFrame = frame("Frame", UIParent)
GameTooltip = frame()
SendMailNameEditBox = frame()
app.mail:Refresh()
assert(app.mail.panel and app.mail.buttons[8].recipient)
assert(app.mail.summary.text == "Page 1/2 · 15 recipients")
assert(app.mail.search.shown)
app.mail.search:SetText("Alt1")
app.mail.search.OnTextChanged(app.mail.search)
assert(app.mail.summary.text == "Page 1/1 · 4/15 recipients")
assert(app.mail.buttons[1].recipient == "Alt1")
app.mail.search:SetText("[no match]")
app.mail.search.OnTextChanged(app.mail.search)
assert(not app.mail.buttons[1].shown and app.mail.search.shown)
assert(app.mail.summary.text == "Page 1/1 · 0/15 recipients")
app.mail.search:SetText("")
app.mail.search.OnTextChanged(app.mail.search)
assert(not app.mail.previous.enabled and app.mail.next.enabled)
app.mail.next.OnClick()
assert(app.mail.page == 2 and app.mail.previous.enabled and not app.mail.next.enabled)
local row = app.mail.buttons[1]
row.OnClick(row)
assert(SendMailNameEditBox.text == row.recipient)
assert(row.label and row.label.justifyH == "CENTER")
local removed = row.recipient
row.remove.OnClick()
assert(not db.nameTable[removed])
assert(app.mail.buttons[6].shown and not app.mail.buttons[7].shown)
assert(app.mail.undo.enabled)
app.mail.undo.OnClick()
assert(db.nameTable[removed] and not app.mail.undo.enabled)
assert(app.recipients:Remove(removed))
GetBuildInfo = function()
    return "", "", "", 16001
end
assert(app.recipients:Add("Sylvanas Windrunner"))
app.mail:SetRecipient("Sylvanas Windrunner")
assert(SendMailNameEditBox.text == "Sylvanas Windrunner")
assert(app.recipients:Remove("sylvanas windrunner"))
-- Shared name column grows and shrinks; the three footer controls stay fixed.
assert(app.mail.clear.width == 132 and app.mail.clear.height == 24)
assert(app.mail.add.width == 40 and app.mail.removeToggle.width == 40 and app.mail.options.width == 40)
local opened = false
app.options = {
    Open = function()
        opened = true
    end,
}
app.mail.options.OnClick()
assert(opened)
local longName = "AnexceptionallylongForever Recipient"
assert(app.recipients:Add(longName))
local expandedWidth = 240
assert(app.mail.clear.width == expandedWidth)
for _, recipientButton in ipairs(app.mail.buttons) do
    assert(recipientButton.width == expandedWidth and recipientButton.height == 24)
end
assert(app.mail.panel.clamped and app.mail.buttons[1].label.wordWrap == false)
app.mail.page = 2
app.mail:Refresh()
local clippedRow
for _, recipientButton in ipairs(app.mail.buttons) do
    if recipientButton.recipient == longName then
        clippedRow = recipientButton
    end
end
assert(clippedRow and clippedRow.clipped)
clippedRow.OnEnter(clippedRow)
assert(GameTooltip.shown and GameTooltip.text == longName)
clippedRow.OnLeave(clippedRow)
assert(not GameTooltip.shown)
clippedRow.OnClick(clippedRow)
assert(SendMailNameEditBox.text == longName)
SendMailFrame.right = 1800
SendMailFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 1800, 0)
assert(app.mail.panel.anchor[1] == "TOPRIGHT" and app.mail.panel.anchor[3] == "TOPLEFT")
SendMailFrame.right = 500
SendMailFrame:StopMovingOrSizing()
assert(app.mail.panel.anchor[1] == "TOPLEFT")
SendMailFrame:SetScale(4)
assert(app.mail.panel.anchor[1] == "TOPRIGHT")
SendMailFrame:SetScale(1)
assert(app.mail.panel:GetScript("OnUpdate") == nil)
assert(app.mail.panel.events.DISPLAY_SIZE_CHANGED and app.mail.panel.events.UI_SCALE_CHANGED)
local originalPosition = app.mail.Position
local positionChecks = 0
app.mail.Position = function(self)
    positionChecks = positionChecks + 1
    originalPosition(self)
end
UIParent.width = 600
app.mail.panel.OnEvent(app.mail.panel, "DISPLAY_SIZE_CHANGED")
assert(positionChecks == 1 and app.mail.side == "left")
UIParent.width = 1920
app.mail.panel.OnEvent(app.mail.panel, "UI_SCALE_CHANGED")
assert(positionChecks == 2 and app.mail.side == "right")
app.mail.panel.OnSizeChanged(app.mail.panel)
assert(positionChecks == 3)
app.mail:Refresh()
assert(positionChecks == 3, "unchanged recipients must not recheck positioning")
UIParent:SetScale(2)
assert(positionChecks == 4)
UIParent:SetScale(1)
assert(positionChecks == 5)
app.mail.Position = originalPosition
assert(app.mail.add.width == 40 and app.mail.removeToggle.width == 40 and app.mail.options.width == 40)
assert(app.recipients:Remove(longName))
assert(app.mail.clear.width == 132)
print("Recipient and responsive button layout tests passed")

assert(app.recipients:Import(" Sylvanas Windrunner\r\nAlt Realm\nalT realm\nZímtschnecke Windrunner\n", true))
assert(#app.recipients:List() == 3 and db.nameTable["Sylvanas Windrunner"])
local exported = app.recipients:Export()
assert(not app.recipients:Import("Good Name\n!!! ???", true))
assert(app.recipients:Export() == exported)
assert(not app.recipients:Import("Good Name\n|Hbad", true))
assert(app.recipients:Export() == exported)
assert(not app.recipients:Import("Bad\tName", false))
assert(app.recipients:Import("Another Name\nalt realm", false))
assert(#app.recipients:List() == 4 and db.nameTable["Alt Realm"])
assert(app.recipients:Import(exported, true))
assert(app.recipients:Export() == exported)
assert(not app.recipients:Import("", false))
assert(app.recipients:Import("", true))
assert(#app.recipients:List() == 0)
assert(not app.mail.search.shown)
local savedMap = db.nameTable
assert(app.recipients:Undo())
assert(db.nameTable == savedMap and app.recipients:Export() == exported)
assert(not app.recipients:Undo())
assert(app.recipients:Import("Another Name", true))
assert(not app.recipients:Import("|Hbad", true))
assert(app.recipients:Undo() and app.recipients:Export() == exported)
assert(app.recipients:Remove("Alt Realm"))
assert(not app.recipients:Remove("Missing Name"))
assert(app.recipients:Undo() and db.nameTable["Alt Realm"])
assert(app.recipients:Remove("Alt Realm"))
assert(app.recipients:Add("New Name"))
assert(not app.recipients:Undo() and db.nameTable["New Name"])
assert(app.recipients:Remove("New Name"))
assert(app.recipients:Import("Merged Name", false))
assert(not app.recipients:Undo() and db.nameTable["Merged Name"])
GetBuildInfo = function()
    return "", "", "", 120000
end
assert(app.recipients:Import("Sylvanas\nAlt-Realm", true))
local normalExport = app.recipients:Export()
assert(not app.recipients:Import("Sylvanas Windrunner", true))
assert(app.recipients:Export() == normalExport)
load("Mailbutton/src/options.lua")
local registered, openedCategory
Settings = {
    RegisterCanvasLayoutCategory = function(panel, name)
        registered = panel
        assert(name == "Mailbutton")
        return {
            GetID = function()
                return 42
            end,
        }
    end,
    RegisterAddOnCategory = function(category)
        assert(category:GetID() == 42)
    end,
    OpenToCategory = function(id)
        openedCategory = id
    end,
}
app.options:Register()
app.options:Open()
assert(registered == app.options.panel and openedCategory == 42)
app.options.panel = nil
app.options.category = nil
Settings = nil
InterfaceOptions_AddCategory = function(panel)
    registered = panel
end
InterfaceOptionsFrame_OpenToCategory = function(panel)
    openedCategory = panel
end
app.options:Register()
app.options:Open()
assert(registered == app.options.panel and openedCategory == registered)
print("Import/export and settings registration tests passed")

-- Fresh addon loaded in TOC order. Only Ace's registration/database boundaries are mocked.
app = {}
SendMailFrame, SendMailNameEditBox = nil, nil
Settings, InterfaceOptions_AddCategory, InterfaceOptionsFrame_OpenToCategory = nil, nil, nil
local databaseCalls, categoryCalls = 0, 0
local saved = {
    profile = { logLevel = "WARN" },
    factionrealm = { nameTable = { [1] = " Alice ", Bob = true }, showRemoveButtons = true },
}
local events, commands = {}, {}
local ace = {}
function ace:NewAddon(addon, name, console, event)
    assert(name == "Mailbutton" and console == "AceConsole-3.0" and event == "AceEvent-3.0")
    function addon:RegisterChatCommand(command, callback)
        commands[command] = callback
    end
    function addon:RegisterEvent(eventName, callback)
        events[eventName] = callback
    end
end
local database = {}
function database:New(name, defaults, defaultProfile)
    databaseCalls = databaseCalls + 1
    assert(name == "MailbuttonDB" and defaults == app.dbDefaults and defaultProfile == true)
    return saved
end
LibStub = function(name)
    if name == "AceAddon-3.0" then
        return ace
    end
    if name == "AceDB-3.0" then
        return database
    end
    error("Unsupported library: " .. name)
end
local function dispatch(callback, ...)
    if type(callback) == "string" then
        return app.addon[callback](app.addon, ...)
    end
    assert(type(callback) == "function")
    return callback(...)
end
local function command(name, input)
    return dispatch(commands[name], input or "")
end
local function event(name, ...)
    return dispatch(events[name], name, ...)
end
load("Mailbutton/src/core/logger.lua")
local messages = {}
function app.logger:chat(fmt, ...)
    messages[#messages + 1] = fmt:format(...)
end
load("Mailbutton/src/core/db.lua")
load("Mailbutton/src/core/ace.lua")
load("Mailbutton/src/mail/recipients.lua")
load("Mailbutton/src/mail/buttons.lua")
load("Mailbutton/src/options.lua")
load("Mailbutton/Mailbutton.lua")
assert(databaseCalls == 0 and app.db == nil and app.options.panel == nil)
InterfaceOptions_AddCategory = function()
    categoryCalls = categoryCalls + 1
end
app.addon:OnInitialize()
assert(databaseCalls == 1 and app.db == saved and app.addon.db == saved)
assert(saved.factionrealm.nameTable.Alice and saved.factionrealm.nameTable.Bob and not saved.factionrealm.nameTable[1])
assert(not saved.factionrealm.showRemoveButtons and app.logger:getLevelName() == "WARN")
assert(categoryCalls == 1 and not app.mail.panel)
app.options:Register()
assert(categoryCalls == 1)
app.addon:OnEnable()
assert(events.ADDON_LOADED and events.MAIL_SHOW and events.MAIL_CLOSED and not app.mail.panel)
event("ADDON_LOADED", "UnrelatedAddon")
assert(not app.mail.panel)
SendMailFrame = frame("Frame")
event("MAIL_SHOW")
assert(not app.mail.panel) -- Both mail frames are required.
SendMailNameEditBox = frame("EditBox")
event("ADDON_LOADED", "Blizzard_MailUI")
local panel = app.mail.panel
assert(panel and panel.parent == SendMailFrame and panel.shown)
event("MAIL_SHOW")
assert(app.mail.panel == panel)
command("mb", "  ADD Charlie  ")
command("mbadd", "Delta")
assert(saved.factionrealm.nameTable.Charlie and saved.factionrealm.nameTable.Delta)
command("mailbutton", "remove CHARLIE")
command("mbremove", "delta")
assert(not saved.factionrealm.nameTable.Charlie and not saved.factionrealm.nameTable.Delta)
command("mb", "list")
assert(messages[#messages] == "Recipients: Alice, Bob")
command("mb", "loglevel debug")
assert(saved.profile.logLevel == "DEBUG" and app.logger:getLevelName() == "DEBUG")
command("mb", "loglevel invalid")
assert(saved.profile.logLevel == "DEBUG")
command("mb", "unknown")
assert(messages[#messages]:find("/mb add", 1, true))
local opened = 0
InterfaceOptionsFrame_OpenToCategory = function(category)
    assert(category == app.options.panel)
    opened = opened + 1
    category:Show()
end
command("mb", "")
command("mailbutton", "options")
assert(opened == 4)

-- Exercise actual options actions and scrolling callbacks, not just registration.
local optionsPanel, edit = app.options.panel, app.options.edit
local controls, scroll, status = {}, nil, nil
for _, child in ipairs(optionsPanel.children) do
    if child.kind == "Button" then
        controls[child.text] = child
    end
    if child.kind == "ScrollFrame" then
        scroll = child
    end
    if child.kind == "FontString" then
        status = child
    end
end
assert(controls.Save and controls.Import and controls.Export and scroll and status)
assert(edit:GetText() == "Alice\nBob")
edit:SetText("Carol\nDora")
edit:SetFocus()
controls.Save.OnClick()
assert(app.recipients:Export() == "Carol\nDora" and status.text == "Buttons saved." and not edit.focused)
edit:SetText("Erin\nCarol")
controls.Import.OnClick()
assert(app.recipients:Export() == "Carol\nDora\nErin" and status.text == "Recipients imported.")
local before = app.recipients:Export()
edit:SetText("Valid\n|Hbad")
edit:SetFocus()
controls.Save.OnClick()
assert(app.recipients:Export() == before and edit:GetText() == "Valid\n|Hbad" and edit.focused)
assert(status.text:find("Enter", 1, true))
scroll:SetVerticalScroll(100)
controls.Export.OnClick()
assert(edit:GetText() == before and scroll.offset == 0)
scroll.OnSizeChanged(scroll, 0)
assert(edit.width == 1)
scroll.OnMouseDown()
assert(edit.focused)
scroll.OnMouseWheel(scroll, -20)
assert(scroll.offset == scroll.range)
scroll.OnMouseWheel(scroll, 20)
assert(scroll.offset == 0)
edit.OnCursorChanged(edit, 0, -150, 0, 20)
assert(scroll.offset == 70)
edit.OnCursorChanged(edit, 0, -10, 0, 20)
assert(scroll.offset == 10)
edit.OnEscapePressed()
assert(not edit.focused)
edit:SetFocus()
optionsPanel:Hide()
assert(not edit.focused)

app.mail.removeToggle.OnClick()
app.mail.add.OnClick()
assert(saved.factionrealm.showRemoveButtons and app.mail.dialog.shown and app.mail.edit.focused)
event("MAIL_CLOSED")
assert(not saved.factionrealm.showRemoveButtons and not app.mail.dialog.shown and not app.mail.edit.focused)
for _, row in ipairs(app.mail.buttons) do
    assert(not row.remove.shown)
end
app.mail.add.OnClick()
app.addon:OnDisable()
assert(not panel.shown and not app.mail.dialog.shown and not app.mail.edit.focused)
-- AceConsole commands remain usable while disabled; they must not revive the mail UI.
command("mbadd", "DisabledAlt")
assert(saved.factionrealm.nameTable.DisabledAlt and not panel.shown)
app.addon:OnEnable()
assert(panel.shown and app.mail.panel == panel and not app.mail.dialog.shown)
event("MAIL_SHOW")
assert(app.mail.panel == panel and app.mail.buttons[4].recipient)
print("Lifecycle, command dispatch and options interaction tests passed")
