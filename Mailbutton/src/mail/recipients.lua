local _, app = ...
local recipients = {}
app.recipients = recipients

function recipients:Export()
    return table.concat(self:List(), "\n")
end

-- Validate the whole paste before changing saved data. Spaces belong to names.
function recipients:Import(text, replace)
    if type(text) ~= "string" then
        return false, "Paste a list of recipients first."
    end
    local names, seen = {}, {}
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        local name = line:match("^%s*(.-)%s*$")
        if name ~= "" then
            if name:find("[|%c]") then
                return false, "Invalid recipient: use one name per line without links or tabs."
            end
            if not seen[name:lower()] then
                names[#names + 1] = name
                seen[name:lower()] = true
            end
        end
    end
    if #names == 0 and not replace then
        return false, "Paste at least one recipient to import."
    end
    local saved = app.db.factionrealm.nameTable
    if replace then
        for name in pairs(saved) do
            saved[name] = nil
        end
    end
    for _, name in ipairs(names) do
        if not self:Find(name) then
            saved[name] = true
        end
    end
    app.mail:Refresh()
    return true
end

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
    if name == "" or name:find("[|%c]") then
        app.logger:chat("Enter a mail recipient, e.g. Peter Maier on Forever or Name-Realm on other clients.")
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
