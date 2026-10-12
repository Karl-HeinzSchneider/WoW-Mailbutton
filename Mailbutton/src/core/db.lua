local _, app = ...
app.dbDefaults = {
    profile = { logLevel = "INFO", bestnumber = 42 },
    factionrealm = { showRemoveButtons = false, nameTable = {} },
}

-- Preserve the historical name -> true map and accept old array-shaped entries.
function app.NormalizeRecipients(db)
    local names = {}
    if type(db.nameTable) == "table" then
        for key, value in pairs(db.nameTable) do
            local name = type(key) == "string" and value and key or type(key) == "number" and value
            if type(name) == "string" then
                name = name:match("^%s*(.-)%s*$")
                if name ~= "" then
                    names[name] = true
                end
            end
        end
    end
    db.nameTable = names
    db.showRemoveButtons = false
end
