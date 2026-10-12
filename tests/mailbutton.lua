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
assert(app.recipients:Add("  Peter Maier  "))
assert(db.nameTable["Peter Maier"])
assert(app.recipients:Add("peter maier"))
assert(app.recipients:Remove(" PETER MAIER "))
assert(not app.recipients:Add("Peter\tMaier"))
assert(not app.recipients:Add("|Hlink"))
assert(app.recipients:Remove(" ALICE "))
assert(not db.nameTable.Alice)
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
assert(app.recipients:Add("Peter Maier"))
app.mail:SetRecipient("Peter Maier")
assert(SendMailNameEditBox.text == "Peter Maier")
assert(app.recipients:Remove("peter maier"))
print("Recipient migration, full names and deferred mail UI tests passed")
