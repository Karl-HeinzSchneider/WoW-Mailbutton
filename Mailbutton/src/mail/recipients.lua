local _, app = ...
local recipients = {}
app.recipients = recipients

function recipients:List()
    local names = {}
    for name, enabled in pairs(app.db.factionrealm.nameTable) do
        if enabled then
            names[#names + 1] = name
        end
    end
    table.sort(names)
    return names
end

function recipients:Find(name)
    for saved in pairs(app.db.factionrealm.nameTable) do
        if saved:lower() == name:lower() then
            return saved
        end
    end
end

function recipients:Add(name)
    name = type(name) == "string" and name:match("^%s*(.-)%s*$") or ""
    if name == "" or name:find("[%s|%c]") then
        app.logger:chat("Enter a character name, optionally followed by -Realm (without spaces).")
        return false
    end
    -- Preserve UTF-8 spelling and realm capitalization instead of byte-wise title casing.
    if not self:Find(name) then
        app.db.factionrealm.nameTable[name] = true
    end
    app.mail:Refresh()
    return true
end

function recipients:Remove(name)
    name = type(name) == "string" and name:match("^%s*(.-)%s*$") or ""
    local saved = self:Find(name)
    if saved then
        app.db.factionrealm.nameTable[saved] = nil
    end
    app.mail:Refresh()
    return saved ~= nil
end
