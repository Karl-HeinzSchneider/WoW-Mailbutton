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
assert(app.recipients:Add("  Alt-Realm  "))
assert(app.recipients:Add("alice"))
assert(#app.recipients:List() == 4)
GetBuildInfo = function()
    return "", "", "", 16001
end
assert(app.recipients:Example() == "Sylvanas Windrunner")
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
    self.width = width
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
SendMailFrame = frame()
SendMailNameEditBox = frame()
app.mail:Refresh()
assert(app.mail.panel and app.mail.buttons[8].recipient)
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
local expandedWidth = #longName * 7 + 24
assert(app.mail.clear.width == expandedWidth)
for _, recipientButton in ipairs(app.mail.buttons) do
    assert(recipientButton.width == expandedWidth and recipientButton.height == 24)
end
assert(app.mail.add.width == 40 and app.mail.removeToggle.width == 40 and app.mail.options.width == 40)
assert(app.recipients:Remove(longName))
assert(app.mail.clear.width == 132)
print("Recipient and responsive button layout tests passed")

assert(app.recipients:Import(" Sylvanas Windrunner\r\nAlt Realm\nalT realm\nZímtschnecke Windrunner\n", true))
assert(#app.recipients:List() == 3 and db.nameTable["Sylvanas Windrunner"])
local exported = app.recipients:Export()
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
