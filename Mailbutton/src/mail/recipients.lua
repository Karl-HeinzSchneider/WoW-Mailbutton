local _, app = ...
local recipients = {}
app.recipients = recipients

-- One session-only snapshot; never add undo state to saved variables.
function recipients:Remember()
    self.undoNames = {}
    for name, enabled in pairs(app.db.factionrealm.nameTable) do
        self.undoNames[name] = enabled
    end
end

function recipients:Undo()
    if not self.undoNames then
        return false
    end
    local saved = app.db.factionrealm.nameTable
    for name in pairs(saved) do
        saved[name] = nil
    end
    for name, enabled in pairs(self.undoNames) do
        saved[name] = enabled
    end
    self.undoNames = nil
    app.mail:Refresh()
    return true
end

function recipients:IsDoubleNameClient()
    if type(GetBuildInfo) ~= "function" then
        return false
    end
    local _, _, _, interface = GetBuildInfo()
    return tonumber(interface) == 16001
end

function recipients:Example()
    return self:IsDoubleNameClient() and "Sylvanas Windrunner" or "Sylvanas"
end

function recipients:Validate(name)
    local valid = type(name) == "string" and not name:find("[|%c]")
    if valid then
        if self:IsDoubleNameClient() then
            valid = name:match("^%S+ %S+$") ~= nil
        else
            valid = name:match("^%S+$") ~= nil
        end
    end
    if not valid then
        return false,
            "Enter "
                .. (self:IsDoubleNameClient() and "a first and last name" or "a single name (optionally Name-Realm)")
                .. ", e.g. "
                .. self:Example()
                .. "."
    end
    return true
end

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
            local valid, message = self:Validate(name)
            if not valid then
                return false, message
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
        self:Remember()
        for name in pairs(saved) do
            saved[name] = nil
        end
    end
    for _, name in ipairs(names) do
        if not self:Find(name) then
            if not replace then
                self.undoNames = nil
            end
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
    local valid, message = self:Validate(name)
    if not valid then
        app.logger:chat(message)
        return false
    end
    -- Preserve UTF-8 spelling and realm capitalization instead of byte-wise title casing.
    if not self:Find(name) then
        self.undoNames = nil
        app.db.factionrealm.nameTable[name] = true
    end
    app.mail:Refresh()
    return true
end

function recipients:Remove(name)
    name = type(name) == "string" and name:match("^%s*(.-)%s*$") or ""
    local saved = self:Find(name)
    if saved then
        self:Remember()
        app.db.factionrealm.nameTable[saved] = nil
    end
    app.mail:Refresh()
    return saved ~= nil
end
