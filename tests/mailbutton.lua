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
    self.shown = value
end
function methods:SetEnabled(value)
    self.enabled = value
end
function methods:Show()
    self.shown = true
end
function methods:Hide()
    self.shown = false
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
    return frame()
end
function methods:CreateTexture()
    return frame()
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
frame = function()
    return setmetatable({}, {
        __index = function(_, key)
            return methods[key] or function() end
        end,
    })
end
CreateFrame = function()
    return frame()
end
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
